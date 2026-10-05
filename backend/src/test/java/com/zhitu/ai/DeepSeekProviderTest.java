package com.zhitu.ai;

import com.zhitu.entity.UserSettings;
import com.zhitu.mapper.UserSettingsMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * AI 服务降级逻辑测试。
 *
 * 重点验证「降级必须如实反映在状态里」——这是项目的一个核心设计选择：
 * 宁可告诉用户这是离线模板，也不把模板内容伪装成大模型输出。
 */
class DeepSeekProviderTest {

    private UserSettingsMapper settingsMapper;
    private DeepSeekProvider provider;

    @BeforeEach
    void setUp() {
        settingsMapper = mock(UserSettingsMapper.class);
        provider = new DeepSeekProvider(settingsMapper);

        // 模拟 application.yml 注入
        ReflectionTestUtils.setField(provider, "systemApiKey", "");
        // 指向一个必然连不上的地址，用于验证降级路径
        ReflectionTestUtils.setField(provider, "systemApiUrl", "http://127.0.0.1:1/v1");
        ReflectionTestUtils.setField(provider, "systemModel", "test-model");
        ReflectionTestUtils.setField(provider, "timeout", 2000);
        ReflectionTestUtils.setField(provider, "maxRetries", 0);

        provider.initHttpClient();
    }

    @Test
    void withoutAnyApiKeyReportsNotConfigured() {
        when(settingsMapper.selectOne(any())).thenReturn(null);

        Map<String, Object> status = provider.status(1L);

        assertThat(status.get("configured")).isEqualTo(false);
        assertThat(status.get("keySource")).isEqualTo("NONE");
        assertThat(status.get("lastCallReal")).isEqualTo(false);
    }

    @Test
    void placeholderKeyFromConfigIsTreatedAsNotConfigured() {
        // application.yml 的历史默认值是 "your-api-key-here"，
        // 它绝不能被当成一个可用的 Key 而去发请求
        UserSettings settings = new UserSettings();
        settings.setApiKey("your-api-key-here");
        when(settingsMapper.selectOne(any())).thenReturn(settings);

        assertThat(provider.status(1L).get("configured")).isEqualTo(false);
    }

    @Test
    void userKeyTakesPrecedenceOverSystemKey() {
        ReflectionTestUtils.setField(provider, "systemApiKey", "sk-system");
        UserSettings settings = new UserSettings();
        settings.setApiKey("sk-user");
        when(settingsMapper.selectOne(any())).thenReturn(settings);

        assertThat(provider.getUserApiKey(1L)).isEqualTo("sk-user");
        assertThat(provider.status(1L).get("keySource")).isEqualTo("USER");
    }

    @Test
    void systemKeyIsUsedWhenUserHasNone() {
        ReflectionTestUtils.setField(provider, "systemApiKey", "sk-system");
        when(settingsMapper.selectOne(any())).thenReturn(null);

        assertThat(provider.getUserApiKey(1L)).isEqualTo("sk-system");
        assertThat(provider.status(1L).get("keySource")).isEqualTo("SYSTEM");
        assertThat(provider.status(1L).get("configured")).isEqualTo(true);
    }

    @Test
    void unreachableEndpointFallsBackAndMarksCallAsNotReal() {
        ReflectionTestUtils.setField(provider, "systemApiKey", "sk-mock");
        when(settingsMapper.selectOne(any())).thenReturn(null);

        String answer = provider.chatForUser(1L, "你是助手", "链表和数组有什么区别");

        assertThat(answer).isNotBlank();
        // 调用失败必须如实标记，前端据此显示「离线模板」
        assertThat(provider.status(1L).get("lastCallReal")).isEqualTo(false);
    }

    @Test
    void fallbackAnswerMentionsOfflineMode() {
        String answer = provider.chat("你是智途AI助手", "我想了解一下大学生活规划");

        assertThat(answer).contains("离线模板");
    }

    @Test
    void knownTopicStillReturnsUsefulFallbackContent() {
        String answer = provider.chat("你是编程学习导师", "链表和数组有什么区别");

        assertThat(answer).contains("链表");
        assertThat(answer).contains("O(1)");
    }

    @Test
    void settingsTableFailureDoesNotBreakStatus() {
        // user_settings 表缺失或查询异常时不能让整个接口崩掉
        when(settingsMapper.selectOne(any())).thenThrow(new RuntimeException("table not exists"));

        Map<String, Object> status = provider.status(1L);

        assertThat(status.get("configured")).isEqualTo(false);
        assertThat(status.get("keySource")).isEqualTo("NONE");
    }
}
