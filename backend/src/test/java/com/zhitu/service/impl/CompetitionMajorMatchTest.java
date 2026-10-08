package com.zhitu.service.impl;

import com.zhitu.entity.Competition;
import com.zhitu.entity.StudentProfile;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 竞赛「适合专业」匹配测试。
 *
 * 真实故障：competition.suitable_major 这个字段以前只用于展示，
 * 降级推荐只按难度和年级打分，于是护理学、会计学的学生被推荐了
 * 「蓝桥杯」「ACM」这类完全不对口的竞赛。
 *
 * 这里只验证纯匹配规则，所以 mappers 传 null 即可。
 */
class CompetitionMajorMatchTest {

    private final CompetitionRecommendServiceImpl service =
        new CompetitionRecommendServiceImpl(null, null, null, null, null);

    private static final String CS_COMPETITION =
        "[\"计算机科学与技术\",\"软件工程\",\"人工智能\",\"大数据科学与技术\"]";
    private static final String NURSING_COMPETITION =
        "[\"临床医学\",\"护理学\",\"药学\",\"预防医学\"]";
    private static final String ANY_MAJOR = "[\"*\"]";

    @Test
    void nursingStudentDoesNotMatchProgrammingCompetition() {
        assertThat(service.matchesMajor(CS_COMPETITION, "护理学")).isFalse();
    }

    @Test
    void nursingStudentMatchesNursingCompetition() {
        assertThat(service.matchesMajor(NURSING_COMPETITION, "护理学")).isTrue();
    }

    @Test
    void openCompetitionMatchesEveryone() {
        assertThat(service.matchesMajor(ANY_MAJOR, "护理学")).isTrue();
        assertThat(service.matchesMajor(ANY_MAJOR, "会计学")).isTrue();
    }

    @Test
    void sameDirectionCountsAsMatch() {
        // 数据库里只列了「会计学」，但人力资源管理同属经管方向，也应算对口
        String accounting = "[\"会计学\"]";
        assertThat(service.matchesMajor(accounting, "人力资源管理")).isTrue();
        assertThat(service.matchesMajor(accounting, "会计学")).isTrue();
    }

    @Test
    void differentDirectionsDoNotMatch() {
        assertThat(service.matchesMajor("[\"会计学\"]", "土木工程")).isFalse();
        assertThat(service.matchesMajor("[\"护理学\"]", "计算机科学与技术")).isFalse();
    }

    @Test
    void unknownMajorsNeverMatchEachOther() {
        // 两个陌生专业都会落到通用兜底，不能因此被判为「同方向」
        assertThat(service.matchesMajor(CS_COMPETITION, "某个不存在的专业")).isFalse();
        assertThat(service.matchesMajor("[\"某个不存在的专业\"]", "另一个不存在的专业")).isFalse();
    }

    @Test
    void malformedOrEmptyDataDoesNotBlowUp() {
        // 脏数据退化成长度/包含判断，绝不能抛异常把整个推荐接口带崩
        assertThat(service.matchesMajor("计算机科学与技术", "计算机科学与技术")).isTrue();
        assertThat(service.matchesMajor("计算机科学与技术", "护理学")).isFalse();
        assertThat(service.matchesMajor("", "护理学")).isFalse();
        assertThat(service.matchesMajor(null, "护理学")).isFalse();
        assertThat(service.matchesMajor(ANY_MAJOR, null)).isTrue();
    }

    // ---------- 降级推荐的过滤与理由文案 ----------

    private static Competition comp(long id, String name, String suitableMajor, LocalDate regEnd) {
        Competition c = new Competition();
        c.setId(id);
        c.setName(name);
        c.setType("综合");
        c.setDifficulty("INTERMEDIATE");
        c.setSuitableMajor(suitableMajor);
        c.setSuitableGrade("不限");
        c.setRegistrationEnd(regEnd);
        c.setRecommendDays(60);
        return c;
    }

    /** 降级推荐只读年级与技能等级，专业名是单独传参的，所以这里不设 majorId */
    private static StudentProfile profile() {
        StudentProfile p = new StudentProfile();
        p.setGrade("大三");
        return p;
    }

    /** 从结果里挑出某条推荐 */
    private static Map<String, Object> find(List<Map<String, Object>> recs, String name) {
        return recs.stream().filter(r -> name.equals(r.get("name"))).findFirst().orElse(null);
    }

    @SuppressWarnings("unchecked")
    private static List<String> reasonsOf(Map<String, Object> rec) {
        return (List<String>) rec.get("reasons");
    }

    @Test
    void openToAllIsLabelledAsOpenNotAsMajorMatched() {
        // 真实问题：matchesMajor(["*"], ...) 也返回 true，于是英语竞赛这类
        // 面向全校的比赛被标成「与你的专业方向对口」，理由不实、分数虚高。
        List<Map<String, Object>> recs = service.buildFallbackRecommendations(
            profile(),
            "自动化",
            Collections.singletonList(comp(12, "全国大学生英语竞赛", ANY_MAJOR, LocalDate.now().plusDays(20))));

        assertThat(recs).hasSize(1);
        assertThat(reasonsOf(recs.get(0))).contains("不限专业，都可以参加");
        assertThat(reasonsOf(recs.get(0))).doesNotContain("与你的专业方向对口");
    }

    @Test
    void majorMatchedCompetitionStillSaysMatched() {
        List<Map<String, Object>> recs = service.buildFallbackRecommendations(
            profile(),
            "自动化",
            Collections.singletonList(comp(10, "全国大学生电子设计竞赛",
                "[\"自动化\",\"电气工程及其自动化\"]", LocalDate.now().plusDays(85))));

        assertThat(recs).hasSize(1);
        assertThat(reasonsOf(recs.get(0))).contains("与你的专业方向对口");
    }

    @Test
    void closedCompetitionIsNotRecommended() {
        // 真实问题：报名早已截止的竞赛仍带着满分出现在推荐列表里
        List<Competition> comps = Arrays.asList(
            comp(47, "已截止的挑战杯", ANY_MAJOR, LocalDate.now().minusDays(161)),
            comp(10, "还能报名的电子设计竞赛", "[\"自动化\"]", LocalDate.now().plusDays(85)));

        List<Map<String, Object>> recs =
            service.buildFallbackRecommendations(profile(), "自动化", comps);

        assertThat(find(recs, "已截止的挑战杯")).isNull();
        assertThat(find(recs, "还能报名的电子设计竞赛")).isNotNull();
    }

    @Test
    void allClosedStillReturnsSomethingInsteadOfEmptyList() {
        // 静态演示数据里可能所有日期都过期了，此时宁可展示已截止的，也不要空列表
        List<Map<String, Object>> recs = service.buildFallbackRecommendations(
            profile(),
            "自动化",
            Collections.singletonList(comp(47, "已截止的挑战杯", ANY_MAJOR, LocalDate.now().minusDays(161))));

        assertThat(recs).isNotEmpty();
    }

    @Test
    void nursingStudentGetsNursingNotProgrammingInFallback() {
        // 把两个真实问题的组合场景钉住：护理学 + 编程竞赛不应出现在结果里
        List<Competition> comps = Arrays.asList(
            comp(1, "蓝桥杯", CS_COMPETITION, LocalDate.now().plusDays(40)),
            comp(9, "中国大学生医学技术技能大赛", NURSING_COMPETITION, LocalDate.now().plusDays(40)));

        List<Map<String, Object>> recs =
            service.buildFallbackRecommendations(profile(), "护理学", comps);

        assertThat(find(recs, "蓝桥杯")).isNull();
        assertThat(find(recs, "中国大学生医学技术技能大赛")).isNotNull();
    }
}
