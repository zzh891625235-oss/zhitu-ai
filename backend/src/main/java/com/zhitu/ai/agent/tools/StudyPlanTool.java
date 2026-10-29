package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.StudyPlan;
import com.zhitu.mapper.StudyPlanMapper;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.*;

/**
 * 读取学习计划的执行情况（打卡完成率、连续坚持天数）。
 *
 * 「计划定了但执行不下去」是大学生最普遍的痛点，而这个工具给 Agent 提供了
 * 真实的执行数据——模型看到的是 42.8% 的完成率，而不是学生自述的「我还行」，
 * 因此给出的调整建议才会落到具体的行为上。
 */
@Component
public class StudyPlanTool extends JsonTool {

    private final StudyPlanMapper studyPlanMapper;

    public StudyPlanTool(StudyPlanMapper studyPlanMapper) {
        this.studyPlanMapper = studyPlanMapper;
    }

    @Override
    public String name() {
        return "get_study_progress";
    }

    @Override
    public String description() {
        return "读取最近 N 天的学习计划打卡情况：完成条数、完成率、连续打卡天数、未完成任务列表。"
                + "当需要回答「我执行得怎么样」「计划要不要调整」「怎么坚持下去」时调用。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("days", ToolSchemas.intProp("回溯天数，默认 14 天"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        int days = Math.max(1, Math.min(60, integer(arguments, "days", 14)));
        LocalDate from = LocalDate.now().minusDays(days);

        List<StudyPlan> plans = studyPlanMapper.selectList(
                new LambdaQueryWrapper<StudyPlan>()
                        .eq(StudyPlan::getUserId, userId)
                        .ge(StudyPlan::getPlanDate, from)
                        .orderByDesc(StudyPlan::getPlanDate));

        int total = plans.size();
        int done = 0;
        List<Map<String, Object>> pending = new ArrayList<>();
        Map<String, int[]> byDate = new TreeMap<>();
        for (StudyPlan sp : plans) {
            boolean finished = sp.getIsCompleted() != null && sp.getIsCompleted() == 1;
            if (finished) {
                done++;
            } else if (pending.size() < 8) {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("date", String.valueOf(sp.getPlanDate()));
                item.put("content", sp.getContent());
                pending.add(item);
            }
            String d = String.valueOf(sp.getPlanDate());
            int[] stat = byDate.get(d);
            if (stat == null) {
                stat = new int[2];
                byDate.put(d, stat);
            }
            stat[0]++;
            if (finished) {
                stat[1]++;
            }
        }

        // 连续打卡：从今天/昨天往回数，统计「当天有任务且全部完成」的连续天数
        int streak = 0;
        LocalDate cursor = LocalDate.now();
        Set<String> doneAllDays = new HashSet<>();
        Set<String> anyDays = new HashSet<>();
        for (Map.Entry<String, int[]> e : byDate.entrySet()) {
            anyDays.add(e.getKey());
            if (e.getValue()[0] == e.getValue()[1]) {
                doneAllDays.add(e.getKey());
            }
        }
        while (doneAllDays.contains(cursor.toString())
                || (!anyDays.contains(cursor.toString()) && cursor.isAfter(LocalDate.now().minusDays(days)))) {
            if (doneAllDays.contains(cursor.toString())) {
                streak++;
            }
            cursor = cursor.minusDays(1);
            if (cursor.isBefore(from)) {
                break;
            }
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("rangeDays", days);
        out.put("totalTasks", total);
        out.put("completedTasks", done);
        out.put("completionRate", total == 0 ? 0 : Math.round(done * 1000.0 / total) / 10.0);
        out.put("streakDays", streak);
        out.put("pendingTasks", pending);
        if (total == 0) {
            out.put("message", "这段时间还没有任何学习计划，建议先在「学习计划」页生成本周计划");
        }
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "private:study_plan";
    }
}
