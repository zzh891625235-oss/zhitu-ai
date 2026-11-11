package com.zhitu.ai;

import com.baomidou.mybatisplus.annotation.TableField;
import com.zhitu.entity.Competition;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 竞赛「报名入口直达」测试。
 *
 * 回归场景：竞赛卡片原本只有一个「官网」文字按钮，点进去是主办单位门户首页，
 * 学生要自己找报名通知；蓝桥杯、传智杯这类赛事的报名系统与门户根本不是同一个域名。
 * 这里验证报名系统白名单、校内报名检索兜底、报名状态与「不落库」约束。
 */
class CompetitionRegistrationLinkTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 11, 10);

    @Test
    void onlinePortalsPointToRealRegistrationSystems() {
        assertThat(CompetitionRegistrationLink.channel("蓝桥杯全国软件和信息技术专业人才大赛"))
                .isEqualTo(CompetitionRegistrationLink.ONLINE);
        assertThat(CompetitionRegistrationLink.resolveUrl("蓝桥杯全国软件和信息技术专业人才大赛",
                "https://www.lanqiao.cn/"))
                .as("蓝桥杯门户是 lanqiao.cn，报名系统必须是 dasai.lanqiao.cn")
                .isEqualTo("https://dasai.lanqiao.cn/");

        assertThat(CompetitionRegistrationLink.resolveUrl("传智杯全国大学生IT技能大赛",
                "https://www.itcast.cn/"))
                .as("传智杯集团站不是报名页，必须直达 boxuegu 报名通道")
                .isEqualTo("https://www.boxuegu.com/match/");

        assertThat(CompetitionRegistrationLink.resolveUrl("中国国际大学生创新大赛（互联网+）",
                "https://cy.ncss.cn/"))
                .isEqualTo("https://cy.ncss.cn/");
    }

    @Test
    void schoolOrganizedCompetitionsGetSearchShortcut() {
        String name = "全国大学生口腔医学技能大赛";
        assertThat(CompetitionRegistrationLink.channel(name))
                .isEqualTo(CompetitionRegistrationLink.SCHOOL);
        String url = CompetitionRegistrationLink.resolveUrl(name, "https://www.cndent.com/");
        assertThat(url).startsWith("https://www.baidu.com/s?wd=");
        assertThat(url).contains("%E6%8A%A5%E5%90%8D");   // 「报名」已被 URL 编码
        assertThat(url).as("检索链接不能含未编码的中文或空格")
                .doesNotContain(" ").doesNotContain("口腔");
        assertThat(CompetitionRegistrationLink.label(CompetitionRegistrationLink.SCHOOL))
                .isEqualTo("学校统一组织报名");
    }

    @Test
    void noticeOnlyCompetitionsReachOfficialNoticePage() {
        String name = "全国大学生数学建模竞赛";
        assertThat(CompetitionRegistrationLink.channel(name))
                .isEqualTo(CompetitionRegistrationLink.NOTICE);
        assertThat(CompetitionRegistrationLink.resolveUrl(name, "http://www.mcm.edu.cn/"))
                .isEqualTo("http://www.mcm.edu.cn/");
    }

    @Test
    void statusCoversUpcomingOpenAndClosed() {
        LocalDate start = TODAY.minusDays(5), end = TODAY.plusDays(10);
        assertThat(CompetitionRegistrationLink.status(start, end, TODAY))
                .isEqualTo(CompetitionRegistrationLink.OPEN);
        assertThat(CompetitionRegistrationLink.status(TODAY.plusDays(1), end, TODAY))
                .isEqualTo(CompetitionRegistrationLink.UPCOMING);
        assertThat(CompetitionRegistrationLink.status(start, TODAY.minusDays(1), TODAY))
                .isEqualTo(CompetitionRegistrationLink.CLOSED);
        assertThat(CompetitionRegistrationLink.status(null, null, TODAY))
                .as("日期缺失时不能把报名按钮关掉")
                .isEqualTo(CompetitionRegistrationLink.OPEN);
    }

    @Test
    void actionTextFollowsChannelAndStatus() {
        assertThat(CompetitionRegistrationLink.action(
                CompetitionRegistrationLink.ONLINE, CompetitionRegistrationLink.OPEN))
                .isEqualTo("立即报名");
        assertThat(CompetitionRegistrationLink.action(
                CompetitionRegistrationLink.SCHOOL, CompetitionRegistrationLink.OPEN))
                .isEqualTo("校内报名指引");
        assertThat(CompetitionRegistrationLink.action(
                CompetitionRegistrationLink.ONLINE, CompetitionRegistrationLink.CLOSED))
                .isEqualTo("报名已结束");
        assertThat(CompetitionRegistrationLink.action(
                CompetitionRegistrationLink.SCHOOL, CompetitionRegistrationLink.UPCOMING))
                .isEqualTo("查看报名安排");
    }

    @Test
    void applyFillsEveryCalculatedField() {
        Competition c = new Competition();
        c.setName("传智杯全国大学生IT技能大赛");
        c.setOfficialUrl("https://www.itcast.cn/");
        c.setRegistrationStart(TODAY.minusDays(3));
        c.setRegistrationEnd(TODAY.plusDays(20));

        CompetitionRegistrationLink.apply(c);

        assertThat(c.getRegistrationUrl()).isEqualTo("https://www.boxuegu.com/match/");
        assertThat(c.getRegistrationChannel()).isEqualTo(CompetitionRegistrationLink.ONLINE);
        assertThat(c.getRegistrationLabel()).isEqualTo("官方在线报名");
        assertThat(c.getRegistrationStatus()).isEqualTo(CompetitionRegistrationLink.OPEN);
        assertThat(c.getRegistrationAction()).isEqualTo("立即报名");
    }

    @Test
    void decorateKeepsPageAndAgentConsistent() {
        Competition c = new Competition();
        c.setName("全国大学生茶艺技能大赛");
        c.setOfficialUrl("https://www.caass.org.cn/");
        c.setRegistrationStart(TODAY.minusDays(2));
        c.setRegistrationEnd(TODAY.plusDays(30));

        Map<String, Object> item = new LinkedHashMap<>();
        CompetitionRegistrationLink.decorate(item, c);

        assertThat(item.get("registrationChannel")).isEqualTo(CompetitionRegistrationLink.SCHOOL);
        assertThat(String.valueOf(item.get("registrationUrl"))).startsWith("https://www.baidu.com/s?wd=");
        assertThat(item.get("registrationAction")).isEqualTo("校内报名指引");
        assertThat(item).containsKeys("registrationLabel", "registrationStatus");
    }

    @Test
    void registrationFieldsNeverPersistToDatabase() throws Exception {
        // 报名系统地址每年会变，落库会让老用户的 data/ 目录长期留着过期链接。
        // 所有报名字段必须保持 @TableField(exist = false)，否则 MyBatis-Plus 会去查不存在的列。
        String[] fields = {"registrationUrl", "registrationChannel", "registrationLabel",
                "registrationStatus", "registrationAction"};
        for (String f : fields) {
            TableField ann = Competition.class.getDeclaredField(f).getAnnotation(TableField.class);
            assertThat(ann).as(f + " 必须标注 @TableField").isNotNull();
            assertThat(ann.exist()).as(f + " 必须不落库").isFalse();
        }
    }

    @Test
    void everySeedCompetitionHasAUsableRegistrationLink() throws Exception {
        // 直接读生成后的 H2 种子 SQL，保证 101 场赛事一个都不会出现「按钮点了没反应」
        File seed = new File("src/main/resources/db/competition-seed-h2.sql");
        assertThat(seed).as("竞赛种子文件").exists();
        String sql = new String(Files.readAllBytes(seed.toPath()), StandardCharsets.UTF_8);
        Matcher m = Pattern.compile("MERGE INTO competition \\(name,[\\s\\S]*?KEY\\(name\\) VALUES\\s*\\n\\('((?:[^']|'')*)'")
                .matcher(sql);
        List<String> names = new ArrayList<>();
        while (m.find()) names.add(m.group(1).replace("''", "'"));
        assertThat(names.size()).as("竞赛种子条数").isGreaterThanOrEqualTo(90);

        List<String> broken = new ArrayList<>();
        for (String name : names) {
            String url = CompetitionRegistrationLink.resolveUrl(name, "https://example.org/");
            if (url == null || !url.startsWith("http")
                    || url.contains(" ") || url.matches(".*[\\u4e00-\\u9fa5].*")) {
                broken.add(name + " -> " + url);
            }
        }
        assertThat(broken).as("以下赛事的报名入口不可用：%s", broken).isEmpty();
    }
}
