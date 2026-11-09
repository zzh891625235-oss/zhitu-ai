package com.zhitu.ai.agent.tools;

import com.zhitu.entity.BilibiliResource;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.BilibiliResourceMapper;
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
 * 覆盖三条路径：
 * 1. 关键词命中（标题 / keywords 任一字段命中都算）；
 * 2. 关键词未命中时给出可降级提示，而不是空数组让模型瞎编；
 * 3. 无关键词时按专业默认推荐，返回真实可点击的链接。
 */
class BilibiliToolTest {

    private BilibiliResourceMapper resourceMapper;
    private StudentProfileMapper profileMapper;
    private BilibiliTool tool;

    @BeforeEach
    void setUp() {
        resourceMapper = mock(BilibiliResourceMapper.class);
        profileMapper = mock(StudentProfileMapper.class);
        tool = new BilibiliTool(resourceMapper, profileMapper);
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
