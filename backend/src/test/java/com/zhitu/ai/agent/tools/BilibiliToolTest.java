package com.zhitu.ai.agent.tools;

import com.zhitu.entity.BilibiliResource;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.BilibiliResourceMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * B 站公开课检索工具测试。
 *
 * 覆盖四条路径：
 * 1. 关键词命中（标题 / keywords 任一字段命中都算）；
 * 2. 关键词未命中时给出可降级提示，而不是空数组让模型瞎编；
 * 3. 无关键词时按专业默认推荐，返回真实可点击的链接；
 * 4. 按专业推荐时过滤掉不对口课程（回归：心理学不该拿到机器学习）。
 */
class BilibiliToolTest {

    private BilibiliResourceMapper resourceMapper;
    private StudentProfileMapper profileMapper;
    private MajorMapper majorMapper;
    private BilibiliTool tool;

    @BeforeEach
    void setUp() {
        resourceMapper = mock(BilibiliResourceMapper.class);
        profileMapper = mock(StudentProfileMapper.class);
        majorMapper = mock(MajorMapper.class);
        tool = new BilibiliTool(resourceMapper, profileMapper, majorMapper);
    }

    private BilibiliResource resource(String title, String uploader, String category,
                                      String keywords, String url) {
        BilibiliResource r = new BilibiliResource();
        r.setTitle(title);
        r.setUploader(uploader);
        r.setCategory(category);
        r.setKeywords(keywords);
        r.setUrl(url);
        r.setDifficulty("BEGINNER");
        r.setSortOrder(1);
        r.setSuitableMajor("[\"*\"]");   // 默认真通用课，便于无关键词分支取到
        return r;
    }

    @Test
    void keywordHitsTitleAndKeywords() {
        List<BilibiliResource> data = new ArrayList<>();
        data.add(resource("高等数学 · 宋浩老师全程课", "宋浩老师官方", "大学基础课",
                "高等数学,微积分,高数", "https://s.bilibili.com/高数"));
        data.add(resource("Excel 从入门到精通", "王佩丰", "职场技能",
                "Excel,函数,透视表", "https://s.bilibili.com/excel"));
        when(resourceMapper.selectList(any())).thenReturn(data);

        // 命中 keywords 字段里的「微积分」
        String out = tool.execute(1L, args("keyword", "微积分", "limit", 5));
        assertThat(out).contains("宋浩");
        assertThat(out).doesNotContain("Excel");

        // 命中标题里的「Excel」
        String out2 = tool.execute(1L, args("keyword", "excel", "limit", 5));
        assertThat(out2).contains("王佩丰");
        assertThat(out2).doesNotContain("宋浩");
    }

    @Test
    void keywordMissReturnsExplainableFallback() {
        List<BilibiliResource> data = new ArrayList<>();
        data.add(resource("高等数学 · 宋浩老师全程课", "宋浩老师官方", "大学基础课",
                "高等数学,微积分,高数", "https://s.bilibili.com/高数"));
        when(resourceMapper.selectList(any())).thenReturn(data);

        String out = tool.execute(1L, args("keyword", "量子物理", "limit", 5));
        assertThat(out).contains("\"found\":0");
        assertThat(out).contains("资源库中没有匹配");
    }

    @Test
    void noKeywordFallsBackToMajorRecommendation() {
        List<BilibiliResource> data = new ArrayList<>();
        data.add(resource("Python 入门 · 黑马程序员全套", "黑马程序员", "编程开发",
                "Python,爬虫", "https://s.bilibili.com/python"));
        when(resourceMapper.selectList(any())).thenReturn(data);
        when(profileMapper.selectOne(any())).thenReturn(new StudentProfile());

        String out = tool.execute(1L, args("limit", 5));
        assertThat(out).contains("按专业推荐");
        assertThat(out).contains("https://s.bilibili.com/python");
    }

    @Test
    void noKeywordFiltersOutUnrelatedCoursesForPsychology() {
        BilibiliResource ml = resource("机器学习 · 吴恩达公开课", "吴恩达 Andrew Ng", "数据与AI",
                "机器学习,深度学习", "https://s.bilibili.com/ml");
        ml.setSuitableMajor("[\"计算机科学与技术\",\"数学与应用数学\",\"应用统计学\"]");
        BilibiliResource psy = resource("心理学导论 · 普通心理学", "心理学陈老师", "大学基础课",
                "心理学,普通心理学", "https://s.bilibili.com/psy");
        psy.setSuitableMajor("[\"心理学\",\"应用心理学\"]");
        BilibiliResource math = resource("高等数学 · 宋浩老师全程课", "宋浩老师官方", "大学基础课",
                "高等数学", "https://s.bilibili.com/math");

        List<BilibiliResource> data = new ArrayList<>();
        data.add(ml);
        data.add(math);
        data.add(psy);
        when(resourceMapper.selectList(any())).thenReturn(data);

        StudentProfile p = new StudentProfile();
        p.setMajorId(1L);
        when(profileMapper.selectOne(any())).thenReturn(p);
        Major major = new Major();
        major.setName("心理学");
        when(majorMapper.selectById(1L)).thenReturn(major);

        String out = tool.execute(1L, args("limit", 5));
        assertThat(out).contains("心理学导论");        // 100 分精确对口
        assertThat(out).contains("高等数学");          // 60 分真通用
        assertThat(out).doesNotContain("机器学习");    // 不对口，必须被过滤
        assertThat(out).contains("按专业推荐");
    }

    @Test
    void noKeywordPrefersExactCoursesOverGeneralOnes() {
        List<BilibiliResource> data = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            BilibiliResource r = resource("心理学专业课" + i, "心理学课堂", "大学基础课",
                    "心理学", "https://s.bilibili.com/psy" + i);
            r.setSuitableMajor("[\"心理学\"]");
            data.add(r);
        }
        data.add(resource("Excel 通用课", "王佩丰", "职场技能",
                "Excel", "https://s.bilibili.com/excel"));
        when(resourceMapper.selectList(any())).thenReturn(data);

        StudentProfile p = new StudentProfile();
        p.setMajorId(1L);
        when(profileMapper.selectOne(any())).thenReturn(p);
        Major major = new Major();
        major.setName("心理学");
        when(majorMapper.selectById(1L)).thenReturn(major);

        String out = tool.execute(1L, args("limit", 5));
        assertThat(out).contains("\"found\":5");
        assertThat(out).contains("\"exactTotal\":6");
        assertThat(out).doesNotContain("Excel 通用课")
                .as("对口课足够时，通用课不应该占用 AI 助手的推荐位");
    }

    @Test
    void toolIdentityAndSchema() {
        assertThat(tool.name()).isEqualTo("search_bilibili_courses");
        assertThat(tool.description()).contains("B 站");
        Map<String, Object> schema = tool.parametersSchema();
        assertThat(schema.get("type")).isEqualTo("object");
        @SuppressWarnings("unchecked")
        Map<String, Object> props = (Map<String, Object>) schema.get("properties");
        assertThat(props).containsKeys("keyword", "limit");
    }

    /** Java 8 兼容的 Map.of 替代 */
    private static Map<String, Object> args(Object... kv) {
        Map<String, Object> m = new HashMap<>();
        for (int i = 0; i + 1 < kv.length; i += 2) {
            if (kv[i + 1] instanceof Number) {
                m.put(String.valueOf(kv[i]), ((Number) kv[i + 1]).intValue());
            } else {
                m.put(String.valueOf(kv[i]), kv[i + 1]);
            }
        }
        return m;
    }
}
