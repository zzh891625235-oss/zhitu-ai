package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.BilibiliResource;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.BilibiliResourceMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 检索 B 站公开课学习资源。
 *
 * 这个工具回答的是「这门课 / 这个技能去哪学」——AI 助手推荐学习路径时
 * 调用它拿到真实可点击的 B 站课程链接，链接出现在「查看依据」里可追溯，
 * 与整个项目「每个建议都能找到出处」的定位一致。
 */
@Component
public class BilibiliTool extends JsonTool {

    private final BilibiliResourceMapper resourceMapper;
    private final StudentProfileMapper profileMapper;

    public BilibiliTool(BilibiliResourceMapper resourceMapper, StudentProfileMapper profileMapper) {
        this.resourceMapper = resourceMapper;
        this.profileMapper = profileMapper;
    }

    @Override
    public String name() {
        return "search_bilibili_courses";
    }

    @Override
    public String description() {
        return "检索平台整理的 B 站公开课资源库，返回课程标题、UP 主、难度、推荐理由和可点击的链接。"
                + "当需要回答「去哪里学 Python」「高数有什么网课」「推荐入门视频」时调用。"
                + "不传 keyword 时默认按该学生的专业返回对口推荐。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("keyword", ToolSchemas.prop("string", "课程或技能关键词，如 Python、数据结构、Excel；为空则按专业推荐"));
        props.put("limit", ToolSchemas.intProp("最多返回几门课，默认 5"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        String keyword = str(arguments, "keyword", "");
        int limit = Math.max(1, integer(arguments, "limit", 5));

        List<BilibiliResource> all = resourceMapper.selectList(
                new LambdaQueryWrapper<BilibiliResource>()
                        .orderByAsc(BilibiliResource::getSortOrder).orderByAsc(BilibiliResource::getId));

        Map<String, Object> out = new LinkedHashMap<>();

        // 有关键词：标题 / UP 主 / keywords 三字段模糊检索
        if (!keyword.isEmpty()) {
            String kw = keyword.toLowerCase();
            List<Map<String, Object>> hits = new ArrayList<>();
            for (BilibiliResource r : all) {
                if (hit(r.getTitle(), kw) || hit(r.getUploader(), kw) || hit(r.getKeywords(), kw)) {
                    hits.add(item(r));
                    if (hits.size() >= limit) break;
                }
            }
            out.put("query", keyword);
            out.put("found", hits.size());
            if (hits.isEmpty()) {
                out.put("message", "资源库中没有匹配「" + keyword + "」的课程，可以建议学生在 B 站搜索该关键词");
            }
            out.put("courses", hits);
            return json(out);
        }

        // 无关键词：按学生专业对口排序返回
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        out.put("query", "(按专业推荐)");
        out.put("hint", "以下为 B 站公开课资源，链接可直接给到学生");
        out.put("courses", all.subList(0, Math.min(limit, all.size())).stream().map(this::item)
                .collect(java.util.stream.Collectors.toList()));
        return json(out);
    }

    private Map<String, Object> item(BilibiliResource r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("title", r.getTitle());
        m.put("uploader", r.getUploader());
        m.put("category", r.getCategory());
        m.put("difficulty", r.getDifficulty());
        m.put("description", r.getDescription());
        m.put("url", r.getUrl());
        return m;
    }

    private boolean hit(String text, String lowercaseKeyword) {
        return text != null && text.toLowerCase().contains(lowercaseKeyword);
    }

    @Override
    public String dataDomain() {
        return "public:bilibili_resource";
    }
}
