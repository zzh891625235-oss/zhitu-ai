package com.zhitu.dto;

import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Result 的重载语义测试。
 *
 * 这里守着一个真实踩过的坑：早期只有 success(T) 与 success(String, T)，
 * 于是 Result.success("设置已保存") 会被解析成「把字符串当成 data」，
 * 返回的 message 永远是 "success"，前端所有中文提示都丢了。
 */
class ResultTest {

    @Test
    void successWithPlainStringShouldBeTreatedAsMessageNotData() {
        Result<String> result = Result.success("进度更新成功");

        assertThat(result.getCode()).isEqualTo(200);
        assertThat(result.getMessage()).isEqualTo("进度更新成功");
        assertThat(result.getData()).isNull();
    }

    @Test
    void successWithMessageOnlyKeepsMessage() {
        Result<Object> result = Result.success("已全部标记为已读");

        assertThat(result.getMessage()).isEqualTo("已全部标记为已读");
        assertThat(result.getData()).isNull();
    }

    @Test
    void successWithDataKeepsDataAndDefaultMessage() {
        Map<String, Object> data = Collections.singletonMap("nickname", "林知途");

        Result<Map<String, Object>> result = Result.success(data);

        assertThat(result.getCode()).isEqualTo(200);
        assertThat(result.getMessage()).isEqualTo("success");
        assertThat(result.getData()).isSameAs(data);
    }

    @Test
    void successWithMessageAndDataKeepsBoth() {
        Result<Integer> result = Result.success("已生成", 42);

        assertThat(result.getMessage()).isEqualTo("已生成");
        assertThat(result.getData()).isEqualTo(42);
    }

    @Test
    void errorHasNoData() {
        Result<Object> result = Result.error(404, "通知不存在");

        assertThat(result.getCode()).isEqualTo(404);
        assertThat(result.getMessage()).isEqualTo("通知不存在");
        assertThat(result.getData()).isNull();
    }
}
