package com.zhitu.service;

import com.zhitu.ai.AIService;
import com.zhitu.entity.StudentProfile;
import com.zhitu.entity.User;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.impl.StudentProfileServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

/**
 * 验证「按专业方向切换能力自评项」在提示词里的落地效果。
 *
 * 背景：原先所有专业都会拿到「编程基础 / Java基础 / 数据结构」这些字段，
 * 对临床医学、汉语言文学等专业完全是噪声，会带偏 AI 生成的画像。
 */
class StudentProfilePromptTest {

    private StudentProfileServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new StudentProfileServiceImpl(
            mock(StudentProfileMapper.class),
            mock(UserMapper.class),
            mock(MajorMapper.class),
            mock(AIService.class));
    }

    private User user() {
        User u = new User();
        u.setNickname("测试同学");
        return u;
    }

    private String promptFor(StudentProfile profile) {
        return (String) ReflectionTestUtils.invokeMethod(
            service, "buildPortraitUserMessage", profile, user());
    }

    @Test
    void computerMajorStillUsesProgrammingFields() {
        StudentProfile p = new StudentProfile();
        p.setGrade("大二");
        p.setProgrammingLevel("INTERMEDIATE");
        p.setJavaLevel("ADVANCED");
        p.setEnglishLevel("BASIC");

        String msg = promptFor(p);

        assertThat(msg).contains("编程基础：INTERMEDIATE");
        assertThat(msg).contains("Java基础：ADVANCED");
        assertThat(msg).doesNotContain("专业能力自评");
    }

    @Test
    void nonComputerMajorUsesSkillAssessmentInsteadOfProgrammingFields() {
        StudentProfile p = new StudentProfile();
        p.setGrade("大二");
        // 这些字段对医学专业没有意义，不应该出现在提示词里
        p.setProgrammingLevel("BEGINNER");
        p.setJavaLevel("BEGINNER");
        p.setSkillAssessment("{\"template\":\"医学类\",\"items\":["
            + "{\"label\":\"药理学\",\"value\":\"BASIC\"},"
            + "{\"label\":\"解剖与形态学\",\"value\":\"INTERMEDIATE\"}]}");

        String msg = promptFor(p);

        assertThat(msg).contains("专业能力自评");
        assertThat(msg).contains("方向：医学类");
        assertThat(msg).contains("药理学：入门");
        assertThat(msg).contains("解剖与形态学：中等");
        // 关键：不能再给医学专业塞编程字段
        assertThat(msg).doesNotContain("Java基础");
        assertThat(msg).doesNotContain("编程基础");
    }

    @Test
    void malformedSkillAssessmentFallsBackInsteadOfCrashing() {
        StudentProfile p = new StudentProfile();
        p.setProgrammingLevel("BASIC");
        p.setSkillAssessment("这不是合法 JSON");

        String msg = promptFor(p);

        // 解析失败不能打崩流程，应回退到原有字段
        assertThat(msg).contains("编程基础：BASIC");
    }

    @Test
    void emptySkillAssessmentBehavesLikeComputerMajor() {
        StudentProfile p = new StudentProfile();
        p.setProgrammingLevel("ADVANCED");
        p.setSkillAssessment("   ");

        String msg = promptFor(p);

        assertThat(msg).contains("编程基础：ADVANCED");
    }
}
