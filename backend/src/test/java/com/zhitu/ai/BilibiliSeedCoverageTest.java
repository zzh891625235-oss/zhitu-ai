package com.zhitu.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 真实种子数据的「专业覆盖率」回归测试。
 *
 * 用户反馈「推荐的课程还是专业不对口」，根因有两个，本测试把两个都钉死：
 * 1. 课程太少，175 个专业里大量专业一门精确对口课都没有，只能拿通用课凑数；
 * 2. suitable_major 里写了「应用统计学」「应用心理学」「秘书学」这类专业字典里
 *    根本不存在的名字，它们永远无法精确命中，只会被近亲规则蹭成 80 分。
 *
 * 因此直接读生成的 H2 种子 SQL，校验：专业名 100% 来自字典、每个专业至少 3 门
 * 100 分课程、热门与冷门专业都有对口课、编程课不会蹭到心理学/口腔医学。
 */
class BilibiliSeedCoverageTest {

    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<List<String>>() {};
    private static final Pattern SUITABLE = Pattern.compile("'(\\[[^']*\\])'");

    @Test
    void everyMajorNameBelongsToDictionaryAndEveryMajorHasEnoughExactCourses() throws Exception {
        String sql = readSeed();
        Map<String, List<String>> byJson = new HashMap<>();
        Matcher m = SUITABLE.matcher(sql);
        List<List<String>> lists = new ArrayList<>();
        while (m.find()) {
            List<String> names = MAPPER.readValue(m.group(1), STRING_LIST);
            lists.add(names);
            byJson.put(m.group(1), names);
        }
        assertThat(lists).as("课程库应包含显著扩充后的课程").hasSizeGreaterThanOrEqualTo(200);

        Set<String> dictionary = readMajors();
        assertThat(dictionary).as("专业字典应为 175 个专业").hasSize(175);

        Set<String> illegal = new HashSet<>();
        Map<String, Integer> coverage = new HashMap<>();
        for (String major : dictionary) coverage.put(major, 0);
        for (List<String> names : lists) {
            for (String name : names) {
                if ("*".equals(name)) continue;
                if (!dictionary.contains(name)) illegal.add(name);
                else coverage.put(name, coverage.get(name) + 1);
            }
        }
        assertThat(illegal).as("字典外专业名无法精确命中，只会制造错配：" + illegal).isEmpty();

        List<String> weak = new ArrayList<>();
        for (Map.Entry<String, Integer> e : coverage.entrySet()) {
            if (e.getValue() < 3) weak.add(e.getKey() + "(" + e.getValue() + ")");
        }
        assertThat(weak).as("以下专业精确对口课程不足 3 门：" + weak).isEmpty();
    }

    @Test
    void popularAndNicheMajorsAllHaveExactCourses() throws Exception {
        List<List<String>> lists = parse(readSeed());
        String[] majors = {"心理学", "口腔医学", "计算机科学与技术", "法学", "汉语言文学",
                "会计学", "临床医学", "农学", "茶学", "烟草", "监狱学", "逻辑学", "草业科学"};
        for (String major : majors) {
            long n = 0;
            for (List<String> names : lists) if (names.contains(major)) n++;
            assertThat(n).as("专业「%s」的 100 分对口课程数", major).isGreaterThanOrEqualTo(3);
        }
    }

    @Test
    void programmingCoursesNeverLeakIntoPsychologyOrDentistry() throws Exception {
        String sql = readSeed();
        Matcher m = SUITABLE.matcher(sql);
        while (m.find()) {
            String json = m.group(1);
            List<String> names = MAPPER.readValue(json, STRING_LIST);
            if (names.contains("计算机科学与技术") && !names.contains("心理学")) {
                assertThat(CourseMajorRelevance.score(json, "心理学"))
                        .as("计算机类课程不能因为「理科大类」蹭给心理学：" + json)
                        .isEqualTo(CourseMajorRelevance.NOT_MATCH);
            }
            if (names.contains("软件工程") && !names.contains("口腔医学")) {
                assertThat(CourseMajorRelevance.score(json, "口腔医学"))
                        .as("编程课不能推给口腔医学：" + json)
                        .isEqualTo(CourseMajorRelevance.NOT_MATCH);
            }
        }
    }

    private static List<List<String>> parse(String sql) throws Exception {
        List<List<String>> out = new ArrayList<>();
        Matcher m = SUITABLE.matcher(sql);
        while (m.find()) out.add(MAPPER.readValue(m.group(1), STRING_LIST));
        return out;
    }

    private static String readSeed() throws Exception {
        try (InputStream in = BilibiliSeedCoverageTest.class.getResourceAsStream("/db/bilibili-seed-h2.sql")) {
            assertThat(in).as("classpath 下应能找到 B 站种子脚本").isNotNull();
            java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) > 0) bos.write(buf, 0, n);
            return new String(bos.toByteArray(), StandardCharsets.UTF_8);
        }
    }

    private static Set<String> readMajors() throws Exception {
        Path p = Paths.get("../database/majors.sql");
        if (!Files.exists(p)) p = Paths.get("database/majors.sql");
        assertThat(Files.exists(p)).as("找不到专业字典 database/majors.sql").isTrue();
        String text = new String(Files.readAllBytes(p), StandardCharsets.UTF_8);
        Matcher m = Pattern.compile("\\(\\d+,\\s*'([^']+)',\\s*'([^']+)'").matcher(text);
        Set<String> out = new HashSet<>();
        while (m.find()) out.add(m.group(1));
        return out;
    }
}
