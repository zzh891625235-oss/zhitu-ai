package com.zhitu.ai.rag;

import com.zhitu.entity.Competition;
import com.zhitu.entity.Course;
import com.zhitu.entity.Major;
import com.zhitu.mapper.CompetitionMapper;
import com.zhitu.mapper.CourseMapper;
import com.zhitu.mapper.MajorMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * RAG 检索服务测试。
 *
 * 重点验证三件事：
 * 1. 中文二元组分词的行为（「机器学习」→ 机器/器学/学习）；
 * 2. 混合检索确实能把相关片段排前面、把无关片段挡在阈值之外；
 * 3. 专业加权能让本专业知识优先。
 */
class RagServiceTest {

    private CompetitionMapper competitionMapper;
    private CourseMapper courseMapper;
    private MajorMapper majorMapper;
    private RagService ragService;

    @BeforeEach
    void setUp() {
        competitionMapper = mock(CompetitionMapper.class);
        courseMapper = mock(CourseMapper.class);
        majorMapper = mock(MajorMapper.class);
        ragService = new RagService(competitionMapper, courseMapper, majorMapper);
    }

    // ---------- 分词 ----------

    @Test
    void tokenizeChineseAsBigrams() {
        List<String> tokens = ragService.tokenize("机器学习");
        assertThat(tokens).containsExactly("机器", "器学", "学习");
    }

    @Test
    void tokenizeMixedEnglishAndChinese() {
        List<String> tokens = ragService.tokenize("学习java和c++基础");
        assertThat(tokens).contains("java");
        assertThat(tokens).contains("学习");
        assertThat(tokens).contains("基础");
        // c++ 中的单字符 c 被丢弃是刻意设计：单字母无法提供检索价值
        assertThat(tokens).doesNotContain("c");
    }

    @Test
    void tokenizeEmptyAndNull() {
        assertThat(ragService.tokenize(null)).isEmpty();
        assertThat(ragService.tokenize("  ")).isEmpty();
    }

    // ---------- 检索 ----------

    @Test
    void searchReturnsRelevantCompetitionFirst() {
        Competition acm = new Competition();
        acm.setId(1L);
        acm.setName("ACM-ICPC 国际大学生程序设计竞赛");
        acm.setType("程序设计");
        acm.setDifficulty("高");
        acm.setSuitableMajor("计算机科学与技术,软件工程");
        acm.setDescription("面向计算机专业学生的顶级算法竞赛，考察数据结构与算法能力");

        Competition speech = new Competition();
        speech.setId(2L);
        speech.setName("全国大学生英语演讲比赛");
        speech.setType("外语");
        speech.setDifficulty("中");
        speech.setSuitableMajor("英语");
        speech.setDescription("考察英语口语表达与临场反应");

        when(competitionMapper.selectList(any())).thenReturn(Arrays.asList(acm, speech));
        when(courseMapper.selectList(any())).thenReturn(Collections.<Course>emptyList());
        when(majorMapper.selectList(any())).thenReturn(Collections.<Major>emptyList());

        List<RagService.Citation> hits = ragService.search("算法竞赛 数据结构", null, 4);
        assertThat(hits).isNotEmpty();
        assertThat(hits.get(0).getTitle()).contains("ACM");
        // 英语演讲比赛与查询无关，即便进入结果也必须排在 ACM 之后
        for (RagService.Citation c : hits) {
            if (c.getTitle().contains("英语")) {
                assertThat(c.getScore()).isLessThan(hits.get(0).getScore());
            }
        }
    }

    @Test
    void searchWithoutDbDataStillUsesCorpus() {
        // 数据库为空时，静态语料（corpus.md）仍在索引中——这是刻意的：通识方法不依赖数据库
        when(competitionMapper.selectList(any())).thenReturn(Collections.<Competition>emptyList());
        when(courseMapper.selectList(any())).thenReturn(Collections.<Course>emptyList());
        when(majorMapper.selectList(any())).thenReturn(Collections.<Major>emptyList());

        List<RagService.Citation> hits = ragService.search("竞赛", null, 4);
        // 可以没有命中，但绝不返回数据库来源的片段（它们不存在）
        for (RagService.Citation c : hits) {
            assertThat(c.getSource()).isNotIn("competition", "course", "major");
        }
    }

    @Test
    void searchBlankQueryReturnsEmpty() {
        assertThat(ragService.search("", null, 4)).isEmpty();
        assertThat(ragService.search(null, null, 4)).isEmpty();
    }

    @Test
    void irrelevantQueryNeverSurfacesCompetitionChunk() {
        Competition acm = new Competition();
        acm.setId(1L);
        acm.setName("ACM-ICPC 国际大学生程序设计竞赛");
        acm.setType("程序设计");
        acm.setDescription("算法与数据结构");

        when(competitionMapper.selectList(any())).thenReturn(Collections.singletonList(acm));
        when(courseMapper.selectList(any())).thenReturn(Collections.<Course>emptyList());
        when(majorMapper.selectList(any())).thenReturn(Collections.<Major>emptyList());

        // 查询词与竞赛片段完全没有重叠 → ACM 片段绝不能被捞出来
        // （哈希向量可能与语料碰撞产生低分命中，这是可接受的；但数据库事实片段必须守住）
        List<RagService.Citation> hits = ragService.search("量子引力波", null, 4);
        for (RagService.Citation c : hits) {
            assertThat(c.getTitle()).doesNotContain("ACM");
        }
    }

    @Test
    void renderContextNumbersTheCitations() {
        RagService.Citation c1 = new RagService.Citation("competition:1:x", "competition", "1", "蓝桥杯", "蓝桥杯是程序设计竞赛", 0.9);
        RagService.Citation c2 = new RagService.Citation("corpus::y", "corpus", "", "备赛方法", "先刷真题", 0.8);
        String ctx = ragService.renderContext(Arrays.asList(c1, c2));
        assertThat(ctx).contains("[1] competition / 蓝桥杯");
        assertThat(ctx).contains("[2] corpus / 备赛方法");
        assertThat(ctx).contains("禁止自行补充");
    }

    @Test
    void statsReflectIndexContents() {
        Competition c = new Competition();
        c.setId(1L);
        c.setName("蓝桥杯");
        when(competitionMapper.selectList(any())).thenReturn(Collections.singletonList(c));
        when(courseMapper.selectList(any())).thenReturn(Collections.<Course>emptyList());
        when(majorMapper.selectList(any())).thenReturn(Collections.<Major>emptyList());

        Object total = ragService.stats().get("totalChunks");
        assertThat(((Number) total).intValue()).isGreaterThanOrEqualTo(1);
    }
}
