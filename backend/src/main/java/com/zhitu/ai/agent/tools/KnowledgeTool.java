package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.ai.rag.RagService;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 检索平台本地知识库（RAG）。
 *
 * 这个工具是 Agent 的「外脑」：回答涉及方法论、政策流程、备考节奏、赛事常识时，
 * 先从这里取回带编号的资料片段，模型再照着资料回答。
 * 前端会把本次真正用到的片段做成「引用」展示出来，用户可以逐条核对，
 * 这也是本项目处理 AI 可信度问题的主要手段。
 */
@Component
public class KnowledgeTool extends JsonTool {

    private final RagService ragService;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;

    public KnowledgeTool(RagService ragService, StudentProfileMapper profileMapper, MajorMapper majorMapper) {
        this.ragService = ragService;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    @Override
    public String name() {
        return "search_knowledge_base";
    }

    @Override
    public String description() {
        return "在本地知识库中检索与问题相关的资料片段，来源包括平台内的竞赛库、课程库、专业库，"
                + "以及人工维护的大学成长方法语料（保研流程、考研节奏、秋招时间线、简历写法、竞赛选择等）。"
                + "当问题涉及流程、方法论、时间节点、具体赛事或课程信息时必须先调用它。"
                + "返回结果每条带编号，回答时请引用编号，不要使用未出现在结果中的内容。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("query", ToolSchemas.prop("string", "检索关键词或问题，建议写成完整短句"));
        props.put("topK", ToolSchemas.intProp("返回多少条资料，默认 4"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        String query = str(arguments, "query", "");
        int topK = Math.max(1, Math.min(8, integer(arguments, "topK", 4)));
        if (query.isEmpty()) {
            return json(Collections.singletonMap("error", "缺少检索关键词 query"));
        }

        String majorName = null;
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        if (p != null && p.getMajorId() != null) {
            Major m = majorMapper.selectById(p.getMajorId());
            majorName = m == null ? null : m.getName();
        }

        List<RagService.Citation> hits = ragService.search(query, majorName, topK);
        List<Map<String, Object>> list = new ArrayList<>();
        for (RagService.Citation c : hits) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("source", c.getSource());
            item.put("title", c.getTitle());
            item.put("text", c.getText().length() > 400 ? c.getText().substring(0, 400) + "…" : c.getText());
            item.put("relevance", c.getScore());
            list.add(item);
        }
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("query", query);
        out.put("hitCount", list.size());
        out.put("documents", list);
        if (list.isEmpty()) {
            out.put("message", "知识库中没有与该问题高度相关的资料，请依据常识回答并明确说明这是通用建议");
        }
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "platform:knowledge_base";
    }
}
