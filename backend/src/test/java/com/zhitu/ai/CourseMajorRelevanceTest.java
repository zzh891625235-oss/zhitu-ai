package com.zhitu.ai;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 课程推荐专业相关度测试。
 *
 * 回归场景来自真实反馈：心理学专业的 B 站推荐里混进了「机器学习」「数据分析」，
 * 理由是「与你所在专业方向相关」——根因是复用了竞赛的学科大类匹配器，
 * 把 心理 / 数学 / 统计 归进了同一个「理科基础类」。
 */
class CourseMajorRelevanceTest {

    private static final String ML =
            "[\"人工智能\",\"计算机科学与技术\",\"软件工程\",\"数据科学与大数据技术\","
                    + "\"自动化\",\"应用统计学\",\"统计学\",\"数学与应用数学\",\"信息与计算科学\"]";
    private static final String DATA_ANALYSIS =
            "[\"数据科学与大数据技术\",\"应用统计学\",\"统计学\",\"经济统计学\","
                    + "\"金融学\",\"会计学\",\"财务管理\",\"数学与应用数学\"]";
    private static final String PSY_INTRO =
            "[\"心理学\",\"应用心理学\",\"教育学\",\"学前教育\",\"小学教育\",\"社会工作\",\"护理学\"]";
    private static final String TEACHER_CERT =
            "[\"教育学\",\"学前教育\",\"小学教育\",\"汉语言文学\",\"应用心理学\",\"体育教育\",\"英语\"]";

    @Test
    void psychologyMustNotGetMachineLearningOrDataAnalysis() {
        assertThat(CourseMajorRelevance.score(ML, "心理学"))
                .as("机器学习只列了数学/统计/计算机专业，不能靠理科大类攀上心理学")
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
        assertThat(CourseMajorRelevance.score(DATA_ANALYSIS, "心理学"))
                .as("数据分析同理")
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
    }

    @Test
    void exactMajorStillScores100() {
        assertThat(CourseMajorRelevance.score(PSY_INTRO, "心理学"))
                .isEqualTo(CourseMajorRelevance.EXACT);
        assertThat(CourseMajorRelevance.score(PSY_INTRO, "应用心理学"))
                .isEqualTo(CourseMajorRelevance.EXACT);
        assertThat(CourseMajorRelevance.reason(CourseMajorRelevance.EXACT, PSY_INTRO, "心理学"))
                .contains("直接对口");
    }

    @Test
    void closeRelativeScores80WithExplainableReason() {
        // 心理学没被精确列出，但「应用心理学」是近亲 -> 80 分
        String onlyApplied = "[\"应用心理学\",\"教育学\",\"学前教育\"]";
        assertThat(CourseMajorRelevance.score(onlyApplied, "心理学"))
                .isEqualTo(CourseMajorRelevance.RELATED);
        assertThat(CourseMajorRelevance.relatedMajor(onlyApplied, "心理学"))
                .isEqualTo("应用心理学");
        assertThat(CourseMajorRelevance.reason(CourseMajorRelevance.RELATED, onlyApplied, "心理学"))
                .contains("应用心理学").contains("拓展方向");
    }

    @Test
    void realGeneralCoursesScore60ForEveryone() {
        String general = "[\"*\"]";
        assertThat(CourseMajorRelevance.score(general, "心理学"))
                .isEqualTo(CourseMajorRelevance.OPEN);
        assertThat(CourseMajorRelevance.score(general, "口腔医学"))
                .isEqualTo(CourseMajorRelevance.OPEN);
        assertThat(CourseMajorRelevance.score(general, null))
                .as("未完善档案时也只推真通用课")
                .isEqualTo(CourseMajorRelevance.OPEN);
        assertThat(CourseMajorRelevance.score(ML, null))
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
    }

    @Test
    void otherMajorsAreNotRegressed() {
        assertThat(CourseMajorRelevance.score(ML, "计算机科学与技术"))
                .isEqualTo(CourseMajorRelevance.EXACT);
        assertThat(CourseMajorRelevance.score(DATA_ANALYSIS, "应用统计学"))
                .isEqualTo(CourseMajorRelevance.EXACT);
        assertThat(CourseMajorRelevance.score("[\"临床医学\",\"护理学\",\"口腔医学\"]", "口腔医学"))
                .isEqualTo(CourseMajorRelevance.EXACT);
        assertThat(CourseMajorRelevance.score(ML, "口腔医学"))
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
    }

    @Test
    void closeRelativeBoundaries() {
        assertThat(CourseMajorRelevance.closelyRelated("心理学", "应用心理学")).isTrue();
        assertThat(CourseMajorRelevance.closelyRelated("心理学", "教育心理学")).isTrue();
        assertThat(CourseMajorRelevance.closelyRelated("心理学", "数学与应用数学")).isFalse();
        assertThat(CourseMajorRelevance.closelyRelated("心理学", "应用统计学")).isFalse();
        assertThat(CourseMajorRelevance.closelyRelated("口腔医学", "临床医学")).isFalse();
        assertThat(CourseMajorRelevance.closelyRelated("心理学", "汉语言文学")).isFalse();
    }

    @Test
    void fitnessRanksMajorSpecificCoursesAboveCrossDisciplineOnes() {
        assertThat(CourseMajorRelevance.coreToken("心理学")).isEqualTo("心理");
        assertThat(CourseMajorRelevance.coreToken("口腔医学")).isEqualTo("口腔");
        assertThat(CourseMajorRelevance.coreToken("临床医学")).isEqualTo("临床");
        assertThat(CourseMajorRelevance.coreToken("计算机科学与技术")).isEqualTo("计算");
        assertThat(CourseMajorRelevance.coreToken("汉语言文学")).isEqualTo("汉语");
        assertThat(CourseMajorRelevance.coreToken("法学")).isEqualTo("法");
        assertThat(CourseMajorRelevance.coreToken("茶学")).isEqualTo("茶");

        int core = CourseMajorRelevance.fitness("普通心理学 · 彭聃龄", "普通心理学,彭聃龄",
                "[\"心理学\",\"教育学\"]", "心理学");
        int side = CourseMajorRelevance.fitness("统计学入门", "统计,假设检验",
                "[\"心理学\",\"教育学\",\"统计学\"]", "心理学");
        assertThat(core).as("标题命中专业核心词的课程应排在拓展课前面").isGreaterThan(side);

        int dental = CourseMajorRelevance.fitness("口腔解剖生理学", "口腔解剖,牙体",
                "[\"口腔医学\",\"临床医学\"]", "口腔医学");
        int anatomy = CourseMajorRelevance.fitness("人体解剖学 · 系统解剖全程", "系统解剖学",
                "[\"临床医学\",\"口腔医学\",\"护理学\"]", "口腔医学");
        assertThat(dental).isGreaterThan(anatomy);
        assertThat(CourseMajorRelevance.fitness("普通心理学", "心理学", "[\"心理学\"]", null)).isZero();
    }

    @Test
    void dirtyDataNeverBecomesGeneralCourse() {
        assertThat(CourseMajorRelevance.score("not-a-json-array", "心理学"))
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
        assertThat(CourseMajorRelevance.score(null, "心理学"))
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
    }
}
