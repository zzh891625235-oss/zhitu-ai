package com.zhitu.ai.guard;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * AI 安全与可控性护栏。
 *
 * <p>大模型一旦直接面对用户输入，就会同时遇到三类风险：
 * <ol>
 *   <li><b>Prompt 注入</b>：用户让模型「忽略上面的指令」「把系统提示词打印出来」；</li>
 *   <li><b>有害输出</b>：违法、暴力、自伤、色情等内容的生成请求；</li>
 *   <li><b>幻觉</b>：模型凭空编出平台里根本不存在的赛事、政策年份、官网链接。</li>
 * </ol>
 *
 * <p>本类是所有 AI 入口的统一前置/后置关卡：
 * <ul>
 *   <li>{@link #verifyInput} —— 入口护栏：注入检测 + 违规内容拦截 + 长度限制；</li>
 *   <li>{@link #maskSecrets} —— 出口护栏：抹掉可能被模型记住并复读的密钥/手机号；</li>
 *   <li>{@link #suspectClaims} —— 后置校验：回答里提到的事实是否能在资料来源里找到；</li>
 *   <li>{@link #extractJson} —— 结构化输出修复：从混杂文本里抢救 JSON，配合上层重试。</li>
 * </ul>
 *
 * <p>所有判定都是可解释的：被拦截时一定返回具体原因，前端可以原样展示给用户，
 * 而不是一句含糊的「请求不合法」。
 */
@Component
public class AiGuard {

    private static final Logger log = LoggerFactory.getLogger(AiGuard.class);

    /** 单次提问的最大字符数，超过后摘要截断，防止 Prompt 被撑爆 */
    public static final int MAX_QUESTION_LENGTH = 2000;

    /**
     * Prompt 注入特征。
     * 这里不追求「识别所有攻击」——那做不到；目标是挡住绝大多数常见的越权话术，
     * 剩下的交给「工具只读 + 输出必须落在知识库范围内」这两条硬约束兜底。
     */
    private static final Pattern[] INJECTION_PATTERNS = {
            Pattern.compile("(?i)ignore\\s+(all\\s+)?(previous|prior|above)\\s+(instructions|prompts?)"),
            Pattern.compile("(?i)disregard\\s+(the\\s+)?(previous|prior|system)"),
            Pattern.compile("(?i)(reveal|print|show|repeat|output)\\s+(your\\s+)?(system\\s+prompt|instructions|prompt)"),
            Pattern.compile("(?i)(忽略|无视|忘记|不要管)(.{0,6})(以上|上面|之前|前面)(.{0,6})(指令|提示|规则|要求)"),
            Pattern.compile("(?i)(显示|输出|打印|复述|泄露)(.{0,8})(系统提示|提示词|system\\s*prompt)"),
            Pattern.compile("(?i)(你现在是|请扮演|act\\s+as|roleplay).{0,20}(管理员|开发者|developer|admin|DAN)"),
            Pattern.compile("(?i)you\\s+are\\s+(now\\s+)?(DAN|an\\s+AI\\s+without\\s+restrictions)"),
            Pattern.compile("(?i)(绕过|bypass|jailbreak|越狱)"),
    };

    /** 违规内容关键词（违法、暴力、自伤、色情等），命中即拒答 */
    private static final String[] BLOCKED_TOPICS = {
            "制毒", "毒品", "赌博作弊", "洗钱", "黑客攻击教学", "入侵他人",
            "自杀", "自残", "如何伤害", "制作炸", "管制刀具",
            "色情", "淫秽", "招嫖", "裸聊",
            "代考", "替考", "作弊发答案", "买卖答案", "论文代写购买",
    };

    /**
     * 疑似「事实」的模式：必须是看起来像专名的结尾（赛事、锦标赛等），
     * 而不是「做一个计划」「好好学习」这类普通短语。
     *
     * 早期版本把「计划 / 奖学金 / 资格证」也算进来，结果把「倒推备赛计划」
     * 当成了一条事实 claim，误报率很高；现在只保留能作为专名后缀的词。
     */
    private static final Pattern CLAIM_PATTERN =
            Pattern.compile("[\\u4e00-\\u9fa5A-Za-z0-9]{2,18}"
                    + "(?:大赛|锦标赛|公开赛|邀请赛|挑战赛|竞赛|联赛|杯赛|杯)");

    /**
     * 出现在这些口语表达式里的「专名」通常只是泛指，不是具体事实。
     * 例如「我从平台竞赛库里筛出了……」里的「平台竞赛」并不是某个赛事名。
     */
    private static final String[] CLAIM_STOPWORDS = {
            "我", "你", "我们", "他", "以上", "以下", "这个", "那个", "什么", "哪些", "怎么",
            "建议", "可以", "应该", "看看", "有没有", "计划里", "全部", "所有", "相关", "参加", "报名"
    };

    private static final Pattern SECRET_PATTERN = Pattern.compile("(?i)(sk-[A-Za-z0-9]{8,}|Bearer\\s+[A-Za-z0-9._\\-]{8,})");
    private static final Pattern PHONE_PATTERN = Pattern.compile("(?<!\\d)1[3-9]\\d{9}(?!\\d)");

    private final ObjectMapper objectMapper = new ObjectMapper();

    // ================================================================
    // 入口护栏
    // ================================================================

    /** 输入校验结论 */
    public static class InputVerdict {
        private final boolean allowed;
        private final String reason;
        private final String sanitized;

        public InputVerdict(boolean allowed, String reason, String sanitized) {
            this.allowed = allowed;
            this.reason = reason;
            this.sanitized = sanitized;
        }

        public boolean isAllowed() {
            return allowed;
        }

        public String getReason() {
            return reason;
        }

        /** 净化后的输入（去控制字符、截断到最大长度） */
        public String getSanitized() {
            return sanitized;
        }
    }

    /**
     * 校验用户输入。
     *
     * @return 通过时 {@code allowed=true}；被拦截时带上可读的 reason
     */
    public InputVerdict verifyInput(String question) {
        if (question == null || question.trim().isEmpty()) {
            return new InputVerdict(false, "提问内容不能为空", "");
        }
        String text = question.replaceAll("[\\p{Cntrl}&&[^\r\n\t]]", "").trim();
        if (text.length() > MAX_QUESTION_LENGTH) {
            text = text.substring(0, MAX_QUESTION_LENGTH);
        }

        for (Pattern p : INJECTION_PATTERNS) {
            Matcher m = p.matcher(text);
            if (m.find()) {
                log.warn("检测到疑似 Prompt 注入，已拦截：{}", m.group());
                return new InputVerdict(false,
                        "检测到尝试改写 AI 指令的内容，出于安全考虑无法处理。如果你只是想了解某个学习方法，换个说法再问一次就好。", text);
            }
        }
        for (String topic : BLOCKED_TOPICS) {
            if (text.contains(topic)) {
                log.warn("检测到违规内容请求，已拦截：{}", topic);
                return new InputVerdict(false,
                        "这个问题涉及违法、危险或不诚信的内容，我不能提供相关帮助。学业、求职、竞赛、备考方面的问题都可以继续问我。", text);
            }
        }
        return new InputVerdict(true, null, text);
    }

    // ================================================================
    // 出口护栏
    // ================================================================

    /** 抹掉密钥与手机号，避免模型复读用户之前填进来的敏感串 */
    public String maskSecrets(String text) {
        if (text == null) {
            return null;
        }
        String out = SECRET_PATTERN.matcher(text).replaceAll("[已屏蔽的密钥]");
        return PHONE_PATTERN.matcher(out).replaceAll("[已屏蔽手机号]");
    }

    /**
     * 事实一致性检查（防幻觉）。
     *
     * <p>把模型回答里出现的「赛事 / 计划 / 证书」类专名抽出来，与本次真正给过模型的
     * 资料做比对。凡是回答里有、资料里找不到的，返回给上层，由上层在前端标注
     * 「该内容未在资料库中命中，请二次核实」，而不是直接给用户看一个可能不存在的赛事名。
     *
     * @param answer      模型回答
     * @param knownFacts  本次检索/工具返回的全部事实来源（赛事名、标题等）
     */
    public List<String> suspectClaims(String answer, Collection<String> knownFacts) {
        List<String> suspects = new ArrayList<>();
        if (answer == null || answer.isEmpty()) {
            return suspects;
        }
        Set<String> joined = new HashSet<>();
        if (knownFacts != null) {
            for (String f : knownFacts) {
                if (f != null && !f.isEmpty()) {
                    joined.add(f);
                }
            }
        }
        Matcher m = CLAIM_PATTERN.matcher(answer);
        Set<String> seen = new HashSet<>();
        while (m.find()) {
            String claim = m.group().trim();
            if (claim.length() < 4 || !seen.add(claim)) {
                continue;
            }
            if (isGenericReference(claim) || isSupported(claim, joined)) {
                continue;
            }
            suspects.add(claim);
        }
        if (!suspects.isEmpty()) {
            log.info("事实一致性校验：检出 {} 个无法在资料中核实的说法 {}", suspects.size(), suspects);
        }
        return suspects;
    }

    /** 命中的是不是「泛指」，例如「上百个竞赛命名都叫 XX 挑战赛」这种口语表达 */
    private boolean isGenericReference(String claim) {
        for (String stop : CLAIM_STOPWORDS) {
            if (claim.contains(stop)) {
                return true;
            }
        }
        return false;
    }

    /** claim 能否在资料里找到支撑：完全一致、互相包含，或有 3 字以上的连续重合 */
    private boolean isSupported(String claim, Set<String> facts) {
        for (String f : facts) {
            if (f.equals(claim) || f.contains(claim) || claim.contains(f)) {
                return true;
            }
            if (longestCommonSubstring(claim, f) >= 3) {
                return true;
            }
        }
        return false;
    }

    /**
     * 最长公共子串长度。
     * 用「连续 3 字重合」而不是「有没有交集」来判定支持，是因为单字、双字的偶然重合
     * 在中文里太常见了，按后者几乎任何说法都会被判为「有来源」。
     */
    private int longestCommonSubstring(String a, String b) {
        if (a == null || b == null || a.isEmpty() || b.isEmpty()) {
            return 0;
        }
        int[] prev = new int[b.length() + 1];
        int best = 0;
        for (int i = 1; i <= a.length(); i++) {
            int[] cur = new int[b.length() + 1];
            for (int j = 1; j <= b.length(); j++) {
                if (a.charAt(i - 1) == b.charAt(j - 1)) {
                    cur[j] = prev[j - 1] + 1;
                    if (cur[j] > best) {
                        best = cur[j];
                    }
                }
            }
            System.arraycopy(cur, 0, prev, 0, cur.length);
        }
        return best;
    }

    // ================================================================
    // 结构化输出修复
    // ================================================================

    /**
     * 从模型输出中提取 JSON。
     *
     * <p>大模型即使被要求「只输出 JSON」，也常常在前面加一句「好的，这是结果：」
     * 或外面包一层 ```json 代码块。这里依次尝试：原样解析 → 剥代码块 → 截取首尾花括号，
     * 尽量在不重试的前提下把结果救回来；确实救不回来时返回 null，由调用方触发一次带
     * 错误提示的重试（见 {@link #repairHint}）。
     */
    public JsonNode extractJson(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        String text = raw.trim();
        String[] candidates = {
                text,
                stripCodeFence(text),
                braceSlice(text),
        };
        for (String c : candidates) {
            if (c == null || c.isEmpty()) {
                continue;
            }
            try {
                JsonNode node = objectMapper.readTree(c);
                if (node != null && !node.isNull() && (node.isObject() || node.isArray())) {
                    return node;
                }
            } catch (Exception ignored) {
                // 换下一个候选
            }
        }
        return null;
    }

    /** 构造「修复提示」：把错误信息回传模型，让它自己改正格式 */
    public String repairHint(String raw) {
        return "你上一次的输出无法被解析为 JSON（原始输出：`"
                + clip(raw, 200)
                + "`）。请严格只输出一个 JSON 对象，不要包含```代码块、说明文字、序号或 Markdown。";
    }

    private String stripCodeFence(String text) {
        Matcher m = Pattern.compile("```(?:json)?\\s*(.*?)```", Pattern.DOTALL).matcher(text);
        if (m.find()) {
            return m.group(1).trim();
        }
        return null;
    }

    private String braceSlice(String text) {
        int start = text.indexOf('{');
        int end = text.lastIndexOf('}');
        if (start >= 0 && end > start) {
            return text.substring(start, end + 1);
        }
        return null;
    }

    private static String clip(String s, int max) {
        if (s == null) {
            return "";
        }
        String t = s.replaceAll("\\s+", " ").trim();
        return t.length() <= max ? t : t.substring(0, max) + "…";
    }
}
