package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.AiPlan;
import com.zhitu.mapper.AiPlanMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 读取已生成的 AI 四年规划。
 *
 * Agent 要给学生「下一步做什么」，必须先知道之前那份规划写到了哪里，
 * 否则每次都从大一重来一遍，学生很快就不信了。
 */
@Component
public class PlanTool extends JsonTool {

    private final AiPlanMapper aiPlanMapper;

    public PlanTool(AiPlanMapper aiPlanMapper) {
        this.aiPlanMapper = aiPlanMapper;
    }

    @Override
    public String name() {
        return "get_four_year_plan";
    }

    @Override
    public String description() {
        return "读取该学生已经生成过的大学四年分阶段规划（大一到大四的目标、课程、技能、竞赛与风险提醒）。"
                + "当需要回答「我接下来该做什么」「规划要不要调整」时调用，回答要与已有规划保持一致，不要另起一套。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        return ToolSchemas.emptyObject();
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        AiPlan plan = aiPlanMapper.selectOne(
                new LambdaQueryWrapper<AiPlan>()
                        .eq(AiPlan::getUserId, userId)
                        .eq(AiPlan::getPlanType, "FOUR_YEAR")
                        .orderByDesc(AiPlan::getId)
                        .last("LIMIT 1"));

        Map<String, Object> out = new LinkedHashMap<>();
        if (plan == null) {
            out.put("generated", false);
            out.put("message", "该学生还没有生成四年规划，需要在「四年规划」页面一键生成");
            return json(out);
        }
        out.put("generated", true);
        out.put("updatedAt", String.valueOf(plan.getUpdatedAt()));
        String content = plan.getContent();
        out.put("content", content == null ? "" : (content.length() > 1200 ? content.substring(0, 1200) + "…" : content));
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "private:ai_plan";
    }
}
