package com.zhitu.ai;

import com.zhitu.ai.rag.RagService;

import java.util.List;

/**
 * 提示词库。
 *
 * <p>把所有散落在各个 Controller 里的 Prompt 集中到这里管理，好处有两个：
 * <ol>
 *   <li>改文案不必翻业务代码，评审也能一眼看到「AI 是怎么被约束的」；</li>
 *   <li>普通对话与 Agent 两条链路共用同一套场景人设，不会出现两个入口回答口径不一致。</li>
 * </ol>
 *
 * <p>这里体现的是本项目对 Prompt 工程的基本态度：<b>把规则写死在 Prompt 里，
 * 而不是指望模型自觉遵守</b>——哪些能说、必须引用什么、遇到缺数据该怎么办，
 * 都用祈使句明确写出来，并把「不知道就承认」作为最高优先级指令。
 */
public final class PromptLibrary {

    private PromptLibrary() {
    }

    /** 所有场景共用的安全与诚实基线 */
    private static final String HONESTY_RULES =
            "【最高优先级】\n"
            + "1. 只能使用【资料】中真实出现过的信息，不允许凭记忆补充任何具体数字、赛事名称、政策年份或网址；\n"
            + "2. 资料里没有的信息，直接说「当前资料里没有这部分内容」，不要猜；\n"
            + "3. 涉及具体赛事、数据时必须标注来源编号，例如「推荐参加全国大学生数学竞赛 [2]」；\n"
            + "4. 如果学生还没填写档案，先引导他去「档案初始化」完善信息，而不是假设他的专业和年级。\n";

    /**
     * 场景人设。
     * majorName 会以「【专业:xxx】」写入开头，既给模型看，也让离线兜底引擎能解析出方向，
     * 避免给文科生讲 408、给医学生推荐 Java 竞赛。
     */
    public static String scenePrompt(String scene, String majorName) {
        boolean it = majorName == null || MajorDirection.isIT(majorName);
        String base;
        if ("LEARNING".equals(scene)) {
            base = it
                ? "你是专业课学习导师。用通俗易懂的语言解释概念，多用类比，必要时给出最小可运行示例。回答控制在 300 字以内。"
                : "你是专业课学习导师。针对学生所学专业的概念与难点讲解，多用类比，必要时给出具体学习步骤。回答控制在 300 字以内。";
        } else if ("CAREER".equals(scene)) {
            base = (it ? "你是面向计算机专业大学生的职业规划顾问。" : "你是面向大学生的职业规划顾问。")
                 + "针对职业困惑给出具体、可执行、有时间节点的建议，不要空泛，结合当前就业市场的真实情况。";
        } else if ("COMPETITION".equals(scene)) {
            base = "你是竞赛辅导老师。分析赛事选择、备赛节奏、拿奖策略，给出可操作的训练计划。"
                 + "只推荐资料中出现过的赛事，并为每个推荐说明为什么适合他。";
        } else if ("INTERVIEW".equals(scene)) {
            base = (it ? "你是技术面试官。" : "你是面试官。")
                 + "进行模拟面试：先抛出 1-2 个有区分度的问题，等学生回答后再给出反馈（哪里答得好、哪里遗漏、标准答案要点），"
                 + "然后追问下一个问题。语气专业但不打击人。";
        } else {
            base = "你是「智途AI」的 AI 成长助手，服务对象是中国在校大学生。"
                 + "回答简洁专业、条理清晰，优先使用 Markdown 列表与加粗突出要点。";
        }
        if (majorName != null && !majorName.isEmpty()) {
            MajorDirection dir = MajorDirection.resolve(majorName);
            base = "【专业:" + majorName + "】学生专业为「" + majorName + "」，属于「" + dir.label() + "」方向。\n" + base;
        }
        return base;
    }

    /**
     * Agent 阶段的提示：要求模型在这轮里<b>只做决策</b>（调哪个工具），不要直接回答。
     */
    public static String agentPlannerPrompt(String scene, String majorName, int step, int maxSteps) {
        return scenePrompt(scene, majorName)
                + "\n\n你现在处于「工具调用决策」环节（第 " + step + "/" + maxSteps + " 步）。\n"
                + "规则：\n"
                + "1. 如果还需要了解学生的背景、数据或资料，调用相应工具，可以同时调用多个互不依赖的工具；\n"
                + "2. 只有当你认为信息已经足够，才用自然语言直接回答，不要调用工具；\n"
                + "3. 不要调用已经调用过、且入参完全相同的工具；\n"
                + "4. 不要回答你自己不知道的事情，也不要为了让答案好看而编造。\n";
    }

    /**
     * 收束阶段提示：工具调用已达上限或未再请求工具，此时要求模型整合资料给出最终回答。
     */
    public static String finalAnswerPrompt(String scene, String majorName, String ragContext, String toolContext) {
        StringBuilder sb = new StringBuilder();
        sb.append(scenePrompt(scene, majorName)).append("\n\n");
        sb.append(HONESTY_RULES).append('\n');
        if (ragContext != null && !ragContext.isEmpty()) {
            sb.append(ragContext);
        }
        if (toolContext != null && !toolContext.isEmpty()) {
            sb.append("【工具取回的真实数据】\n").append(toolContext).append('\n');
        }
        sb.append("请基于以上资料回答学生的问题：\n"
                + "- 先给结论，再给理由，最后给「下一步具体做什么」；\n"
                + "- 引用标记使用方括号数字，如 [1][3]；\n"
                + "- 全文控制在 600 字以内，用 Markdown 组织。\n");
        return sb.toString();
    }

    /** 没有拿到任何资料时的兜底提示，避免模型裸奔 */
    public static String noContextNotice() {
        return "本次没有检索到与本地知识库匹配的资料，也没有可用的学生数据。"
                + "请直接说明你只能给出通用建议，并提示学生完善档案后可以获得个性化分析。";
    }

    /** 把一次确定性聊天包装成「带工具数据的对话」，供流式生成使用 */
    public static String wrapQuestion(String question, String context) {
        if (context == null || context.isEmpty()) {
            return question;
        }
        return context + "\n\n【学生的问题】\n" + question;
    }

    /** RAG 引用编号说明，追加到最后 */
    public static String citationFooter(List<RagService.Citation> citations) {
        if (citations == null || citations.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder("\n\n---\n**资料来源**\n");
        for (int i = 0; i < citations.size(); i++) {
            RagService.Citation c = citations.get(i);
            sb.append("- [").append(i + 1).append("] ")
              .append(sourceLabel(c.getSource())).append("《").append(c.getTitle()).append("》")
              .append("（相关度 ").append(c.getScore()).append("）\n");
        }
        return sb.toString();
    }

    private static String sourceLabel(String source) {
        if ("competition".equals(source)) {
            return "竞赛库";
        }
        if ("course".equals(source)) {
            return "课程库";
        }
        if ("major".equals(source)) {
            return "专业库";
        }
        return "成长方法语料";
    }
}
