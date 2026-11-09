package com.zhitu.service;

import com.zhitu.ai.AIService;
import com.zhitu.entity.StudentProfile;
import com.zhitu.entity.User;
import com.zhitu.mapper.AiPlanMapper;
import com.zhitu.mapper.LearningRecordMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.StudyPlanMapper;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.impl.StudentProfileServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 验证 AI 降级时不会把「空画像」写进数据库。
 *
 * 真实故障：未配置 API Key 时，chatForUser 会降级并返回一段不含 JSON 的离线模板文本，
 * extractJson 找不到花括号于是返回 "{}"，代码误以为调用成功，
 * 把空对象存进 ai_portrait —— 前端表现为「AI画像已生成」但卡片内容全空、综合分 0。
 */
class StudentProfilePortraitTest {

    private StudentProfileMapper profileMapper;
    private AIService aiService;
    private StudentProfileServiceImpl service;

    @BeforeEach
    void setUp() {
        profileMapper = mock(StudentProfileMapper.class);
        UserMapper userMapper = mock(UserMapper.class);
        aiService = mock(AIService.class);

        service = new StudentProfileServiceImpl(profileMapper, userMapper,
            mock(MajorMapper.class), mock(AiPlanMapper.class), mock(StudyPlanMapper.class),
            mock(LearningRecordMapper.class), aiService);

        StudentProfile profile = new StudentProfile();
        profile.setId(1L);
        profile.setUserId(1L);
        profile.setGrade("大三");
        profile.setMajorId(7L);
        when(profileMapper.selectOne(any())).thenReturn(profile);

        User user = new User();
        user.setNickname("测试同学");
        when(userMapper.selectById(anyLong())).thenReturn(user);
    }

    @Test
    void offlineTemplateTextShouldFallBackInsteadOfSavingEmptyPortrait() {
        // 模拟 AI 降级：返回一段普通文本，里面没有任何 JSON
        when(aiService.chatForUser(anyLong(), any(), any()))
            .thenReturn("关于「多态」，配置 AI API Key 后可获得更精准回答。");

        Map<String, Object> portrait = service.generatePortrait(1L);

        // 关键：不能是空对象，必须回退到规则模板
        assertThat(portrait).isNotEmpty();
        assertThat(portrait.get("summary")).isNotNull();
        assertThat(portrait.get("scores")).isNotNull();
        assertThat(portrait.get("strengths")).isNotNull();
    }

    @Test
    void validJsonFromModelIsUsedAsIs() {
        when(aiService.chatForUser(anyLong(), any(), any())).thenReturn(
            "{\"summary\":\"来自大模型的评价\",\"scores\":{\"overall\":88},\"strengths\":[\"基础扎实\"]}");

        Map<String, Object> portrait = service.generatePortrait(1L);

        assertThat(portrait.get("summary")).isEqualTo("来自大模型的评价");
    }

    @Test
    void jsonWithoutSummaryIsTreatedAsInvalid() {
        // 有些模型会返回 {"result":"..."} 之类结构，
        // 缺少 summary 说明不是我们要的画像结构，应该走兜底
        when(aiService.chatForUser(anyLong(), any(), any()))
            .thenReturn("{\"result\":\"抱歉，我无法完成\"}");

        Map<String, Object> portrait = service.generatePortrait(1L);

        assertThat(portrait.get("summary")).isNotNull();
        assertThat(portrait.get("scores")).isNotNull();
    }

    @Test
    void aiExceptionAlsoFallsBack() {
        when(aiService.chatForUser(anyLong(), any(), any()))
            .thenThrow(new RuntimeException("connection refused"));

        Map<String, Object> portrait = service.generatePortrait(1L);

        assertThat(portrait).isNotEmpty();
        assertThat(portrait.get("summary")).isNotNull();
    }
}
