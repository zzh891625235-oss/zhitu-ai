package com.zhitu.ai.agent;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 规则版意图编排器 —— 大模型不可用时的降级大脑。
 *
 * <h3>为什么还要写它</h3>
 * 工具调用（Function Calling）依赖模型厂商支持，而演示环境未必总是配好了 Key。
 * 如果大模型一不可用，Agent 就退化成「随机生成一段不知所云的话」，那这个 Agent
 * 是站不住的。所以这里额外实现一层确定性编排：
 * <blockquote>
 *   用关键词与句式规则判断用户想问什么 → 挑选应当执行的工具 → 仍然<b>执行真实的工具</b>
 *   → 用真实数据合成答案。
 * </blockquote>
 * 也就是说，降级降的是「谁来选工具」，不是「有没有数据」。
 * 学生在页面上看到的推荐竞赛、课程进度、打卡完成率，无论走哪条链路，
 * 都来自同一份数据库记录，不存在编造。
 *
 * <h3>刻意保持简单</h3>
 * 没用 NLP 分类器：一是引入模型就得等它加载，二是这份规则本身是白盒的，
 * 出了问题能直接改。给评委展示时，「规则可解释」比「黑盒但炫技」更有说服力。
 */
@Component
public class RulePlanner {

    /** 规则命中 record，便于 Daniel 型 CET：前端可以展示为什么选了这个工具 */
    public static class PlanStep {
        public final String tool;
        public final String purpose;

        PlanStep(String tool, String purpose) {
            this.tool = tool;
            this.purpose = purpose;
        }
    }

    /** 关键词 → 工具。顺序即优先级：越具体的诉求排在越前面 */
    private static final String[] PROFILE_KEYS = {"我是谁", "我的档案", "介绍一下我", "我的专业", "我的情况"};
    private static final String[] PORTRAIT_KEYS = {"能力", "画像", "优势", "短板", "弱项", "强项", "哪里不足", "水平"};
    private static final String[] PLAN_EXEC_KEYS = {"打卡", "计划执行", "坚持", "完成率", "偷懒", "拖延", "没完成", "跟进"};
    private static final String[] FOUR_YEAR_KEYS = {"四年", "大一", "大二", "大三", "大四", "规划", "路线图", "安排一下"};
    private static final String[] COMPETITION_KEYS = {"竞赛", "比赛", "赛事", "含金量", "报名", "挑战杯", "互联网+", "该报哪个"};
    private static final String[] COURSE_KEYS = {"课程", "学什么", "专业课", "知识", "教材", "先学", "这门课", "怎么学"};
    private static final String[] GROWTH_KEYS = {"简历", "项目经历", "证书", "实习", "荣誉", "经历太少", "写点什么"};
    private static final String[] METHOD_KEYS = {"保研", "推免", "考研", "复试", "调剂", "秋招", "春招", "面试",
            "怎么准备", "流程", "时间线", "什么时候", "要不要", "方法", "技巧", "建议", "利用率", "效率"};

    /**
     * 根据问题编排工具序列。
     *
     * @return 去重后的执行计划，最多 4 步（够覆盖绝大多数问题，再多反而拖慢响应）
     */
    public List<PlanStep> plan(String question) {
        List<PlanStep> steps = new ArrayList<>();
        Set<String> used = new LinkedHashSet<>();
        // 查询类问题几乎都要先知道「这个学生是谁」
        add(steps, used, "get_student_profile", "确认专业、年级与目标，所有个性化建议都要以此为基准", true);

        if (hits(question, METHOD_KEYS)) {
            add(steps, used, "search_knowledge_base", "检索资料库中关于该问题的流程与方法论", false);
        }
        if (hits(question, FOUR_YEAR_KEYS)) {
            add(steps, used, "get_four_year_plan", "读取已生成的四年规划，避免与新建议冲突", false);
        }
        if (hits(question, PORTRAIT_KEYS) && steps.size() < 4) {
            add(steps, used, "get_ability_portrait", "查看九维能力自评，找出真正的短板", false);
        }
        if (hits(question, COURSE_KEYS) && steps.size() < 4) {
            add(steps, used, "list_courses_with_progress", "结合课程进度判断下一步学什么", false);
        }
        if (hits(question, COMPETITION_KEYS) && steps.size() < 4) {
            add(steps, used, "find_competitions", "检索与专业对口的真实赛事（仅返回库内存在的记录）", false);
        }
        if (hits(question, GROWTH_KEYS) && steps.size() < 4) {
            add(steps, used, "get_growth_records", "盘点已有经历，判断简历能写什么", false);
        }
        if (hits(question, PLAN_EXEC_KEYS) && steps.size() < 4) {
            add(steps, used, "get_study_progress", "读取打卡完成率与连续坚持天数", false);
        }
        if (hits(question, PROFILE_KEYS) && steps.size() < 4) {
            add(steps, used, "get_ability_portrait", "补充能力画像", false);
        }
        // 一条规则都没命中：至少给出方法论资料，而不是直接编答案
        if (steps.size() == 1) {
            add(steps, used, "search_knowledge_base", "检索资料库中的通用方法建议", false);
        }
        return steps;
    }

    /** 生成给工具的参数（规则模式下我们能传的比模型更准，因为它带着意图） */
    public java.util.Map<String, Object> argumentsFor(String tool, String question) {
        java.util.Map<String, Object> args = new java.util.LinkedHashMap<>();
        if ("search_knowledge_base".equals(tool)) {
            args.put("query", question.length() > 40 ? question.substring(0, 40) : question);
            args.put("topK", 4);
        } else if ("find_competitions".equals(tool)) {
            args.put("onlyMatched", true);
            args.put("limit", 6);
        } else if ("get_study_progress".equals(tool)) {
            args.put("days", 14);
        } else if ("list_courses_with_progress".equals(tool)) {
            args.put("onlyNotFinished", true);
            args.put("limit", 12);
        }
        return args;
    }

    private void add(List<PlanStep> steps, Set<String> used, String tool, String purpose, boolean always) {
        if (used.add(tool)) {
            steps.add(new PlanStep(tool, purpose));
        }
    }

    private boolean hits(String question, String... keys) {
        if (question == null) {
            return false;
        }
        for (String k : keys) {
            if (question.contains(k)) {
                return true;
            }
        }
        return false;
    }

    /** 供文档/调试使用：列出全部规则关键词 */
    public static List<String> allKeywords() {
        List<String> all = new ArrayList<>();
        all.addAll(Arrays.asList(PROFILE_KEYS));
        all.addAll(Arrays.asList(PORTRAIT_KEYS));
        all.addAll(Arrays.asList(PLAN_EXEC_KEYS));
        all.addAll(Arrays.asList(FOUR_YEAR_KEYS));
        all.addAll(Arrays.asList(COMPETITION_KEYS));
        all.addAll(Arrays.asList(COURSE_KEYS));
        all.addAll(Arrays.asList(GROWTH_KEYS));
        all.addAll(Arrays.asList(METHOD_KEYS));
        return all;
    }
}
