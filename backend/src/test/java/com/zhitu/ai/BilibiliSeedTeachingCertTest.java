package com.zhitu.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 「教师资格证」错配回归测试。
 *
 * 用户多次反馈心理学专业的推荐里混进教师资格证。根因是课程生成脚本里有个
 * 「@教育心理」宽分组，同时挂了心理学、汉语言文学和一堆学科专业，
 * 于是考证课被当成专业课，以 100 分「直接对口」出现在首屏。
 * 现在考证类课程只面向教育学门类专业，心理学专业必须完全看不到它。
 */
class BilibiliSeedTeachingCertTest {

    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> LIST = new TypeReference<List<String>>() {};
    private static final Pattern SUITABLE = Pattern.compile("'(\\[[^']*\\])'");

    @Test
    void teachingCertificateNeverAppearsForPsychology() throws Exception {
        String sql = readSeed();
        int start = sql.indexOf("教师资格证 · 科目一科目二全程");
        assertThat(start).as("课程库应包含教资课").isPositive();
        int end = sql.indexOf(");", start);
        Matcher m = SUITABLE.matcher(sql.substring(start, end));
        assertThat(m.find()).as("教资课应带 suitable_major").isTrue();
        String json = m.group(1);

        List<String> majors = MAPPER.readValue(json, LIST);
        assertThat(majors).isNotEmpty();
        assertThat(majors).as("考证课不得冒充学科专业课")
                .doesNotContain("心理学", "汉语言文学", "新闻学", "数学与应用数学", "英语");

        assertThat(CourseMajorRelevance.score(json, "心理学"))
                .as("心理学不再精确命中，也不能被近亲规则蹭到 80 分")
                .isEqualTo(CourseMajorRelevance.NOT_MATCH);
        assertThat(CourseMajorRelevance.score(json, "教育学"))
                .as("教育学类专业仍然直接对口")
                .isEqualTo(CourseMajorRelevance.EXACT);
    }

    @Test
    void psychologyStillHasPlentyOfExactCoreCourses() throws Exception {
        String sql = readSeed();
        int exact = 0;
        Matcher m = SUITABLE.matcher(sql);
        while (m.find()) {
            List<String> names = MAPPER.readValue(m.group(1), LIST);
            if (names.contains("心理学")) exact++;
        }
        assertThat(exact).as("收窄考证课后，心理学仍应有足够多的专业核心课")
                .isGreaterThanOrEqualTo(5);
    }

    private static String readSeed() throws Exception {
        try (InputStream in = BilibiliSeedTeachingCertTest.class
                .getResourceAsStream("/db/bilibili-seed-h2.sql")) {
            assertThat(in).as("classpath 下应能找到 B 站种子脚本").isNotNull();
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) bos.write(buf, 0, n);
            return new String(bos.toByteArray(), StandardCharsets.UTF_8);
        }
    }
}
