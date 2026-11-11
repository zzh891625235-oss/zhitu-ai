package com.zhitu.service.impl;

import com.zhitu.ai.AIService;
import com.zhitu.entity.Resume;
import com.zhitu.mapper.GrowthRecordMapper;
import com.zhitu.mapper.LearningRecordMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.ResumeMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * 简历「在线编辑保存」的字段清洗回归测试。
 * resume.content 是一整列 JSON，一旦写入任意结构或超长内容，
 * 下次 getResume 解析失败就会退化成一张空白 A4 纸。
 */
class ResumeSaveTest {

    private ResumeServiceImpl service(ResumeMapper resumeMapper) {
        return new ResumeServiceImpl(
                Mockito.mock(StudentProfileMapper.class),
                Mockito.mock(UserMapper.class),
                Mockito.mock(LearningRecordMapper.class),
                Mockito.mock(GrowthRecordMapper.class),
                resumeMapper,
                Mockito.mock(MajorMapper.class),
                Mockito.mock(AIService.class));
    }

    @Test
    void onlyWhitelistedFieldsAreKeptAndValuesAreCleaned() {
        ResumeMapper mapper = Mockito.mock(ResumeMapper.class);
        Map<String, Object> input = new LinkedHashMap<>();
        input.put("name", "  张三  ");
        input.put("targetPosition", "算法工程师");
        StringBuilder longText = new StringBuilder();
        for (int i = 0; i < 900; i++) longText.append('A');
        input.put("advantages", longText.toString());
        Map<String, Object> edu = new HashMap<>();
        edu.put("school", "某某大学");
        edu.put("major", "计算机科学与技术");
        edu.put("grade", "大三");
        edu.put("unexpected", "不应写入");
        input.put("education", edu);
        input.put("skills", Arrays.asList("Java", "Java", "  Python  ", ""));
        input.put("courses", "不是数组，应被丢弃");
        input.put("hackerField", "任意字段都不写入");

        Map<String, Object> out = service(mapper).saveResume(7L, input);

        assertThat(out).doesNotContainKey("hackerField");
        assertThat(out).containsKeys("name", "targetPosition", "advantages", "education",
                "skills", "courses", "projects", "competitions", "certificates");
        assertThat(out.get("name")).isEqualTo("张三");
        assertThat((String) out.get("advantages")).hasSize(600);
        assertThat((List<?>) out.get("skills")).containsExactly("Java", "Python");
        assertThat((List<?>) out.get("courses")).isEmpty();
        Map<?, ?> savedEdu = (Map<?, ?>) out.get("education");
        assertThat(savedEdu.containsKey("unexpected")).isFalse();
        assertThat(savedEdu.get("school")).isEqualTo("某某大学");

        ArgumentCaptor<Resume> captor = ArgumentCaptor.forClass(Resume.class);
        Mockito.verify(mapper).insert(captor.capture());
        String content = captor.getValue().getContent();
        assertThat(content)
                .as("落库 JSON 只含白名单字段")
                .doesNotContain("hackerField", "unexpected");
        assertThat(captor.getValue().getUserId()).isEqualTo(7L);
    }

    @Test
    void controlCharactersNeverBreakStoredJson() throws Exception {
        ResumeMapper mapper = Mockito.mock(ResumeMapper.class);
        Map<String, Object> input = new HashMap<>();
        input.put("name", "李\u0001四");
        input.put("advantages", "沟通\u0008能力强");

        Map<String, Object> out = service(mapper).saveResume(9L, input);

        assertThat(out.get("name")).isEqualTo("李四");
        assertThat(out.get("advantages")).isEqualTo("沟通能力强");
        ArgumentCaptor<Resume> captor = ArgumentCaptor.forClass(Resume.class);
        Mockito.verify(mapper).insert(captor.capture());
        // 直接把落库 JSON 读回来，既证明它没被控制字符写坏，也证明清洗真的生效
        Map<?, ?> back = new com.fasterxml.jackson.databind.ObjectMapper()
                .readValue(captor.getValue().getContent(), Map.class);
        assertThat(back.get("name")).isEqualTo("李四");
        assertThat(back.get("advantages")).isEqualTo("沟通能力强");
    }

    @Test
    void listSizeIsCapped() {
        ResumeMapper mapper = Mockito.mock(ResumeMapper.class);
        List<String> many = new ArrayList<>();
        for (int i = 0; i < 80; i++) many.add("技能" + i);
        Map<String, Object> input = new HashMap<>();
        input.put("skills", many);

        Map<String, Object> out = service(mapper).saveResume(11L, input);

        assertThat((List<?>) out.get("skills")).hasSize(40);
    }

    @Test
    void nullPayloadIsRejectedWithClientError() {
        assertThatThrownBy(() -> service(Mockito.mock(ResumeMapper.class)).saveResume(1L, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("简历内容不能为空");
    }
}
