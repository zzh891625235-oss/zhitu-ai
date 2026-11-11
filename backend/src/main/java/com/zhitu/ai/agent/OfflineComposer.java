package com.zhitu.ai.agent;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zhitu.ai.CompetitionRegistrationLink;
import com.zhitu.ai.rag.RagService;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 离线答案合成器。
 *
 * <p>当大模型不可用（没配 Key、额度耗尽、网络不通）时，由它接手最后一步：
 * 把工具取回的<b>真实数据</b>组织成一段可读的建议。
 *
 * <p>它和大模型的区别只有一点：<b>每一句话都必须能在工具结果里找到出处</b>，
 * 不允许修辞性的发挥。代价是文风朴素，收益是永远不会编造假数据——
 * 这正是「AI 兜底机制」应该有的样子：功能降级，诚实不降级。
 */
@Component
public class OfflineComposer {

    private static final Map<String, String> LEVEL_LABEL = new LinkedHashMap<>();

    static {
        LEVEL_LABEL.put("BEGINNER", "入门");
        LEVEL_LABEL.put("ELEMENTARY", "了解");
        LEVEL_LABEL.put("INTERMEDIATE", "熟练");
        LEVEL_LABEL.put("ADVANCED", "精通");
    }

    private final ObjectMapper om = new ObjectMapper();

    public String compose(String question, List<ToolOutcome> outcomes, List<RagService.Citation> citations) {
        Map<String, JsonNode> data = new LinkedHashMap<>();
        for (ToolOutcome o : outcomes) {
            if (!o.isSuccess() || o.getResult() == null) {
                continue;
            }
            try {
                data.put(o.getTool(), om.readTree(o.getResult()));
            } catch (Exception ignored) {
                // 某个工具结果不是合法 JSON 时跳过它，其它部分照常输出
            }
        }

        StringBuilder sb = new StringBuilder();
        sb.append(leadSentence(question, data)).append("\n\n");

        List<String> sections = new ArrayList<>();
        String profile = renderProfile(data.get("get_student_profile"));
        if (profile != null) {
            sections.add("### 先看清你现在的位置\n" + profile);
        }
        String portrait = renderPortrait(data.get("get_ability_portrait"));
        if (portrait != null) {
            sections.add("### 你的能力结构\n" + portrait);
        }
        String exec = renderStudy(data.get("get_study_progress"));
        if (exec != null) {
            sections.add("### 计划执行得怎么样\n" + exec);
        }
        String courses = renderCourses(data.get("list_courses_with_progress"));
        if (courses != null) {
            sections.add("### 课程进度\n" + courses);
        }
        String comps = renderCompetitions(data.get("find_competitions"));
        if (comps != null) {
            sections.add("### 可以报的赛事\n" + comps);
        }
        String growth = renderGrowth(data.get("get_growth_records"));
        if (growth != null) {
            sections.add("### 已经攒下的经历\n" + growth);
        }
        String knowledge = renderKnowledge(data.get("search_knowledge_base"));
        if (knowledge != null) {
            sections.add("### 相关方法资料\n" + knowledge);
        }

        for (String s : sections) {
            sb.append(s).append("\n\n");
        }

        List<String> actions = nextActions(data);
        if (!actions.isEmpty()) {
            sb.append("### 建议你接下来做这三件事\n");
            for (int i = 0; i < actions.size(); i++) {
                sb.append(i + 1).append(". ").append(actions.get(i)).append('\n');
            }
            sb.append('\n');
        }

        sb.append("> 本次回答由**本地规则编排 + 真实数据**合成（未调用大模型）。\n")
          .append("> 在「API 设置」中填入自己的 Key 后，同一套工具会交给大模型来自主调用，回答会更贴合你的个人情况。\n");
        return sb.toString();
    }

    // ================================================================
    // 各数据块渲染
    // ================================================================

    private String leadSentence(String question, Map<String, JsonNode> data) {
        JsonNode profile = data.get("get_student_profile");
        String who = "";
        if (profile != null && profile.path("initialized").asBoolean(false)) {
            String major = profile.path("major").asText("");
            String grade = profile.path("grade").asText("");
            who = (!major.isEmpty() || !grade.isEmpty())
                    ? "结合你填写的档案（" + appendNonEmpty(major, grade, "·") + "），"
                    : "结合你填写的档案，";
        }
        if (data.containsKey("find_competitions")) {
            return who + "我从平台竞赛库里筛出了与你的专业真正对口的赛事，下面每一场都能点进官网核实。";
        }
        if (data.containsKey("list_courses_with_progress")) {
            return who + "我按你的专业课程地图和学习进度，排了下一步该推进的内容。";
        }
        if (data.containsKey("get_study_progress")) {
            return who + "我把你最近两周的打卡数据拉出来看了一下。";
        }
        if (data.containsKey("get_growth_records")) {
            return who + "我先盘了一遍你成长档案里已经沉淀的经历。";
        }
        if (data.containsKey("get_four_year_plan")) {
            return who + "你的四年规划已经生成过，我按已有规划把重点挑出来了。";
        }
        if (data.containsKey("search_knowledge_base")) {
            return who + "这个问题在资料库里有现成的方法论，我把要点摘出来了。";
        }
        return "我按你档案里的情况整理了一下，下面是可以直接执行的建议。";
    }

    private String renderProfile(JsonNode n) {
        if (n == null) {
            return null;
        }
        if (!n.path("initialized").asBoolean(false)) {
            return "- 你的成长档案还没有填写，专业、年级、目标这些关键信息缺失\n"
                 + "- 建议先到「档案初始化」补全，之后所有推荐才会真正贴合你";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("- 院校专业：").append(nvl(n.path("school").asText("未填写")))
          .append(" · ").append(nvl(n.path("major").asText("未填写"))).append('\n');
        sb.append("- 当前年级：").append(nvl(n.path("grade").asText("未填写")))
          .append(" · GPA：").append(nvl(n.path("gpa").asText("未填写"))).append('\n');
        String goal = n.path("careerGoal").asText("");
        if (!goal.isEmpty()) {
            sb.append("- 发展方向：").append(goal).append('\n');
        }
        return sb.toString();
    }

    private String renderPortrait(JsonNode n) {
        if (n == null || !n.path("available").asBoolean(false)) {
            return null;
        }
        JsonNode skills = n.path("skills");
        if (!skills.isArray() || skills.size() == 0) {
            return null;
        }
        List<String> weak = new ArrayList<>();
        List<String> strong = new ArrayList<>();
        for (JsonNode s : skills) {
            String name = s.path("skill").asText("");
            String level = s.path("level").asText("BEGINNER");
            if ("BEGINNER".equals(level) || "ELEMENTARY".equals(level)) {
                weak.add(name + "（" + LEVEL_LABEL.getOrDefault(level, level) + "）");
            } else {
                strong.add(name + "（" + LEVEL_LABEL.getOrDefault(level, level) + "）");
            }
        }
        StringBuilder sb = new StringBuilder();
        sb.append("- 共 ").append(skills.size()).append(" 项能力自评");
        if (!weak.isEmpty()) {
            sb.append("\n- **需要补的短板**：").append(join(weak, 4));
        }
        if (!strong.isEmpty()) {
            sb.append("\n- 已经不错的部分：").append(join(strong, 4));
        }
        if (!weak.isEmpty()) {
            sb.append("\n- 优先级建议：先把「").append(firstSkill(weak)).append("」补到熟练，再动其它项");
        }
        return sb.toString();
    }

    private String renderStudy(JsonNode n) {
        if (n == null) {
            return null;
        }
        int total = n.path("totalTasks").asInt(0);
        if (total == 0) {
            return "- 近 ".concat(n.path("rangeDays").asText("14")).concat(" 天没有任何学习计划\n")
                 + "- 建议先在「学习计划」页生成一周计划，任务颗粒度拆到 30 分钟能完成";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("- 近 ").append(n.path("rangeDays").asText("14")).append(" 天：共 ")
          .append(total).append(" 项任务，完成 ").append(n.path("completedTasks").asInt(0)).append(" 项\n");
        sb.append("- 完成率 **").append(n.path("completionRate").asDouble(0)).append("%**")
          .append("，连续坚持 ").append(n.path("streakDays").asInt(0)).append(" 天\n");
        JsonNode pending = n.path("pendingTasks");
        if (pending.isArray() && pending.size() > 0) {
            sb.append("- 还没做的事：");
            List<String> items = new ArrayList<>();
            for (int i = 0; i < Math.min(3, pending.size()); i++) {
                items.add(pending.get(i).path("content").asText(""));
            }
            sb.append(join(items, 3));
        }
        double rate = n.path("completionRate").asDouble(0);
        if (rate < 60) {
            sb.append("\n- 完成率偏低，多半是计划排得太满：先按 70% 的量重排，比咬牙硬扛更容易坚持");
        } else if (rate >= 85) {
            sb.append("\n- 执行得很稳，可以适当加量，把时间投到弱项上");
        }
        return sb.toString();
    }

    private String renderCourses(JsonNode n) {
        if (n == null || !n.path("available").asBoolean(false)) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        sb.append("- 本专业课程共 ").append(n.path("totalCourses").asInt(0)).append(" 门，已完成 ")
          .append(n.path("finishedCourses").asInt(0)).append(" 门\n");
        sb.append("- 平均学习进度 **").append(n.path("averageProgress").asDouble(0)).append("%**\n");
        JsonNode arr = n.path("courses");
        if (arr.isArray() && arr.size() > 0) {
            JsonNode first = arr.get(0);
            sb.append("- 建议先推进：").append(first.path("name").asText(""))
              .append("（建议学期 ").append(nvl(first.path("semester").asText("未标注")))
              .append("，难度 ").append(nvl(first.path("difficulty").asText("未标注")))
              .append("，当前 ").append(first.path("progress").asInt(0)).append("%）\n");
            if (arr.size() > 1) {
                List<String> more = new ArrayList<>();
                for (int i = 1; i < Math.min(4, arr.size()); i++) {
                    more.add(arr.get(i).path("name").asText(""));
                }
                sb.append("- 排在后面的还有：").append(join(more, 3));
            }
        }
        return sb.toString();
    }

    private String renderCompetitions(JsonNode n) {
        if (n == null) {
            return null;
        }
        JsonNode arr = n.path("competitions");
        if (!arr.isArray() || arr.size() == 0) {
            return "- 暂时没有筛到与你的专业对口的赛事，可以先补充或修改档案里的专业信息再试一次";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("- 对口赛事共 ").append(n.path("total").asInt(arr.size())).append(" 场，评分最高的几场是：\n");
        for (int i = 0; i < Math.min(4, arr.size()); i++) {
            JsonNode c = arr.get(i);
            String level = c.path("matchLevel").asText("");
            String tag = "EXACT".equals(level) ? "精确对口" : ("OPEN".equals(level) ? "不限专业" : "同大类");
            sb.append("  ").append(i + 1).append(". **").append(c.path("name").asText("")).append("**");
            if (!c.path("score").isNull()) {
                sb.append(" · 匹配度 ").append(c.path("score").asInt(0)).append(" 分（").append(tag).append("）");
            } else {
                sb.append("（").append(tag).append("）");
            }
            sb.append('\n');
            JsonNode reasons = c.path("reasons");
            if (reasons.isArray() && reasons.size() > 0) {
                List<String> rs = new ArrayList<>();
                for (int k = 0; k < Math.min(2, reasons.size()); k++) {
                    rs.add(reasons.get(k).asText(""));
                }
                sb.append("     理由：").append(join(rs, 2)).append('\n');
            }
            if (!c.path("daysLeft").isNull()) {
                sb.append("     距报名截止：").append(c.path("daysLeft").asInt(0)).append(" 天\n");
            }
            String regUrl = c.path("registrationUrl").asText("");
            if (regUrl.isEmpty()) {
                // 兼容旧版工具结果：按赛事名现场解析，保证离线答案也能给出报名入口
                regUrl = CompetitionRegistrationLink.urlByName(
                        c.path("name").asText(""), c.path("officialUrl").asText(""));
            }
            String regLabel = c.path("registrationLabel").asText("查看报名安排");
            sb.append("     报名入口（").append(regLabel).append("）：").append(regUrl).append('\n');
            String url = c.path("officialUrl").asText("");
            if (!url.isEmpty()) {
                sb.append("     官网：").append(url).append('\n');
            }
        }
        sb.append("- 以上全部取自平台竞赛库，名称、官网与报名入口均为平台真实解析结果，不做列表之外的推荐");
        return sb.toString();
    }

    private String renderGrowth(JsonNode n) {
        if (n == null) {
            return null;
        }
        JsonNode stats = n.path("statistics");
        StringBuilder sb = new StringBuilder();
        boolean empty = true;
        String[] keys = {"PROJECT", "COMPETITION", "CERTIFICATE", "INTERNSHIP", "HONOR"};
        String[] labels = {"项目经历", "竞赛获奖", "证书", "实习经历", "荣誉奖项"};
        for (int i = 0; i < keys.length; i++) {
            int v = stats.path(keys[i]).asInt(0);
            if (v > 0) {
                empty = false;
                sb.append("- ").append(labels[i]).append("：").append(v).append(" 条\n");
            }
        }
        if (empty) {
            sb.append("- 成长档案目前是空的，简历自然会「没东西可写」\n")
              .append("- 建议先把做过的课程设计、实验报告、社团项目按「项目」类型补进去，哪怕只有 2 条");
            return sb.toString();
        }
        JsonNode records = n.path("records");
        if (records.isArray() && records.size() > 0) {
            List<String> titles = new ArrayList<>();
            for (int i = 0; i < Math.min(3, records.size()); i++) {
                titles.add(records.get(i).path("title").asText(""));
            }
            sb.append("- 最近记录：").append(join(titles, 3));
        }
        return sb.toString();
    }

    private String renderKnowledge(JsonNode n) {
        if (n == null) {
            return null;
        }
        JsonNode arr = n.path("documents");
        if (!arr.isArray() || arr.size() == 0) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < Math.min(3, arr.size()); i++) {
            JsonNode d = arr.get(i);
            sb.append(i + 1).append(". **").append(d.path("title").asText("")).append("**\n");
            String text = d.path("text").asText("");
            text = text.replace("\n", " ").replaceAll("\\s+", " ").trim();
            sb.append("   ").append(text.length() > 180 ? text.substring(0, 180) + "…" : text).append('\n');
        }
        return sb.toString();
    }

    private List<String> nextActions(Map<String, JsonNode> data) {
        List<String> actions = new ArrayList<>();
        JsonNode profile = data.get("get_student_profile");
        if (profile != null && !profile.path("initialized").asBoolean(false)) {
            actions.add("去「档案初始化」把专业、年级、发展补全，这是所有个性化建议的前提");
        }
        JsonNode comps = data.get("find_competitions");
        if (comps != null && comps.path("competitions").isArray() && comps.path("competitions").size() > 0) {
            actions.add("挑 1 场最对口的赛事，在「竞赛中心」看报名截止日，倒推备赛计划");
        }
        JsonNode courses = data.get("list_courses_with_progress");
        if (courses != null && courses.path("courses").isArray() && courses.path("courses").size() > 0) {
            actions.add("把「" + courses.path("courses").get(0).path("name").asText("") + "」推进 20%，再到「学习计划」打卡");
        }
        JsonNode study = data.get("get_study_progress");
        if (study != null && study.path("totalTasks").asInt(0) == 0) {
            actions.add("在「学习计划」生成一周任务，颗粒度拆到 30 分钟能完成");
        } else if (study != null && study.path("completionRate").asDouble(100) < 60) {
            actions.add("把下周计划量减到 70%，先把连续打卡的天数续起来");
        }
        JsonNode growth = data.get("get_growth_records");
        if (growth != null && growth.path("total").asInt(0) == 0) {
            actions.add("补 2 条成长档案记录，之后简历才有内容可生成");
        }
        if (actions.isEmpty()) {
            actions.add("把你的问题说得更具体一点，比如「我大二该开始准备哪个竞赛」");
            actions.add("补充或更新一下档案里的自评数据，让分析结果更准");
        }
        return actions.subList(0, Math.min(3, actions.size()));
    }

    // ================================================================
    // 小工具
    // ================================================================

    private String appendNonEmpty(String a, String b, String sep) {
        List<String> parts = new ArrayList<>();
        if (a != null && !a.isEmpty()) {
            parts.add(a);
        }
        if (b != null && !b.isEmpty()) {
            parts.add(b);
        }
        return join(parts, 2);
    }

    private String join(List<String> items, int max) {
        StringBuilder sb = new StringBuilder();
        int n = Math.min(max, items.size());
        for (int i = 0; i < n; i++) {
            if (i > 0) {
                sb.append("、");
            }
            sb.append(items.get(i));
        }
        return sb.toString();
    }

    private String firstSkill(List<String> skills) {
        String s = skills.get(0);
        int idx = s.indexOf("（");
        return idx > 0 ? s.substring(0, idx) : s;
    }

    private String nvl(String s) {
        return s == null || s.isEmpty() ? "未填写" : s;
    }
}
