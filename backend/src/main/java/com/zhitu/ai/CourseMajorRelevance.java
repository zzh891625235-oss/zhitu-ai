package com.zhitu.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * B 站公开课的「专业相关度」判定——课程推荐的唯一事实来源。
 *
 * <p>为什么不复用 {@link CompetitionMajorMatcher}：竞赛按 19 个学科大类匹配是合理的
 * （学科竞赛本来就按大类组织），但 {@link MajorDirection} 的「理科基础类」关键词是
 * {@code 数学|物理|化学|生物科学|…|统计|心理|计算科学}，把「心理学」和「数学与应用数学」
 * 「应用统计学」归进了同一个方向。套到课程推荐上，就会出现「机器学习（适合数学/统计专业）」
 * 被判成与「心理学」同方向、标 80 分「与你所在专业方向相关」的错配。
 *
 * <p>课程推荐只认名字层面的近亲专业，不再使用学科大类推断：
 * <ol>
 *   <li>100 分：suitable_major 里精确列出了该专业；</li>
 *   <li>80 分：列出的是近亲专业（「应用心理学」之于「心理学」、「教育心理学」之于「心理学」）；</li>
 *   <li>60 分：suitable_major 含 "*" 的真·全专业通用课；</li>
 *   <li>不推荐：其余一律跳过——宁可少推，不可错推。</li>
 * </ol>
 *
 * <p>Controller 页面推荐与 Agent 的 {@code search_bilibili_courses} 工具共用本类，
 * 避免两处各写一套判断后出现「页面说对口、AI 说不对口」的矛盾。
 */
public final class CourseMajorRelevance {

    public static final int EXACT = 100;
    public static final int RELATED = 80;
    public static final int OPEN = 60;
    public static final int NOT_MATCH = -1;

    private static final ObjectMapper MAPPER = new ObjectMapper();

    /** 过于泛化的词根，不能单独作为「近亲专业」的依据 */
    private static final Set<String> GENERIC = new HashSet<>(Arrays.asList(
            "学", "工程", "科学", "技术", "管理", "医学", "文学", "设计", "艺术",
            "教育", "经济", "数学", "物理", "化学", "计算机", "信息"));

    /** 常见修饰前缀，去掉后「应用心理学」≈「心理学」 */
    private static final String[] MODIFIERS = {"应用", "基础", "现代", "理论"};

    private CourseMajorRelevance() {}

    private static List<String> parse(String suitableMajorJson) {
        if (suitableMajorJson == null || suitableMajorJson.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try {
            return MAPPER.readValue(suitableMajorJson, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return null;
        }
    }

    /** 该课程对当前专业的分数：100 精确 / 80 近亲 / 60 真通用 / -1 不推荐 */
    public static int score(String suitableMajorJson, String majorName) {
        List<String> list = parse(suitableMajorJson);
        // 脏数据或空清单：宁可不推，也不冒充通用课
        if (list == null || list.isEmpty()) return NOT_MATCH;
        boolean openToAll = list.contains("*");
        if (majorName == null || majorName.trim().isEmpty()) {
            return openToAll ? OPEN : NOT_MATCH;
        }
        String mine = majorName.trim();
        for (String s : list) {
            if (!"*".equals(s) && mine.equals(s.trim())) return EXACT;
        }
        for (String s : list) {
            if (!"*".equals(s) && closelyRelated(mine, s)) return RELATED;
        }
        return openToAll ? OPEN : NOT_MATCH;
    }

    /** 命中的近亲专业名，用于生成可解释的推荐理由；无命中返回 null */
    public static String relatedMajor(String suitableMajorJson, String majorName) {
        List<String> list = parse(suitableMajorJson);
        if (list == null || majorName == null || majorName.trim().isEmpty()) return null;
        for (String s : list) {
            if (!"*".equals(s) && closelyRelated(majorName.trim(), s)) return s.trim();
        }
        return null;
    }

    /** 推荐理由，与 {@link #score} 一一对应，保证每条推荐都能说清依据 */
    public static String reason(int score, String suitableMajorJson, String majorName) {
        if (score == EXACT) return "与你的专业「" + majorName + "」直接对口";
        if (score == RELATED) {
            String hit = relatedMajor(suitableMajorJson, majorName);
            return "面向「" + (hit == null ? "相近专业" : hit) + "」等近亲专业，可作为拓展方向";
        }
        return "大学生通用技能，任何专业都建议掌握";
    }

    /**
     * 名字层面的近亲判定：去掉修饰前缀后相同，或一方是另一方 ≥2 字的连续子串。
     * 刻意不做「同学科大类」推断——那正是本次错配的根源。
     */
    static boolean closelyRelated(String a, String b) {
        if (a == null || b == null) return false;
        String ca = core(a), cb = core(b);
        if (ca.isEmpty() || cb.isEmpty()) return false;
        if (ca.equals(cb)) return true;                    // 应用心理学 ≈ 心理学
        String shortOne = ca.length() <= cb.length() ? ca : cb;
        String longOne = ca.length() <= cb.length() ? cb : ca;
        if (shortOne.length() < 2 || GENERIC.contains(shortOne)) return false;
        return longOne.contains(shortOne);                 // 教育心理学 ⊃ 心理学
    }

    private static String core(String name) {
        String s = name.trim().replaceAll("[\\s()（）·、,，]", "");
        for (String prefix : MODIFIERS) {
            if (s.length() > prefix.length() && s.startsWith(prefix)) {
                return s.substring(prefix.length());
            }
        }
        return s;
    }

    /** 专业名里用于「贴合度加权」的后缀，长后缀优先 */
    private static final String[] CORE_SUFFIXES = {
            "科学与技术", "及其自动化", "与行政学", "工程", "技术", "科学", "学", "类", "专业"};

    /**
     * 同为 100 分课程之间的排序权重：<b>不改变展示分数</b>，只决定谁排在前面。
     *
     * <p>「精确列出专业」只能说明这门课适合该专业，不能说明它是核心课还是拓展课。
     * 例如「人力资源管理概论」也列了心理学，但它不该排在「普通心理学」前面。
     * 因此叠加两个信号：课程标题 / 关键词命中专业核心词（+60），以及
     * 适配专业清单足够聚焦（≤8 门 +20，≤20 门 +10）。
     *
     * @return 0~80 的贴合度权重，越大越贴合
     */
    public static int fitness(String title, String keywords, String suitableMajorJson, String majorName) {
        if (majorName == null || majorName.trim().isEmpty()) return 0;
        String token = coreToken(majorName.trim());
        if (token.isEmpty()) return 0;
        String text = (title == null ? "" : title) + " " + (keywords == null ? "" : keywords);
        int value = text.contains(token) ? 60 : 0;
        List<String> list = parse(suitableMajorJson);
        if (list != null) {
            int n = list.size();
            if (n <= 8) value += 20;
            else if (n <= 20) value += 10;
        }
        return value;
    }

    /** 心理学→心理，口腔医学→口腔，临床医学→临床，计算机科学与技术→计算，法学→法 */
    static String coreToken(String majorName) {
        String s = majorName.trim();
        for (String suffix : CORE_SUFFIXES) {
            if (s.length() > suffix.length() && s.endsWith(suffix)) {
                s = s.substring(0, s.length() - suffix.length());
                break;
            }
        }
        if (s.length() > 1 && "医文教科工".contains(s.substring(s.length() - 1))) {
            s = s.substring(0, s.length() - 1);
        }
        return s.length() > 2 ? s.substring(0, 2) : s;
    }
}
