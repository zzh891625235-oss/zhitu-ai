package com.zhitu.exception;

import com.zhitu.dto.Result;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 异常外泄回归测试。
 *
 * 巡检时注册一个全新账号，点「生成简历」页面上直接弹出
 * 「服务器内部错误: Cannot invoke "...getMajorId()" because "p" is null」。
 * 这类内部实现细节必须只留在服务端日志里。
 */
class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void internalExceptionNeverLeaksImplementationDetails() {
        Result<?> r = handler.handleException(new NullPointerException(
                "Cannot invoke \"com.zhitu.entity.StudentProfile.getMajorId()\" because \"p\" is null"));
        assertThat(r.getCode()).isEqualTo(500);
        assertThat(r.getMessage()).isEqualTo("操作未完成，请稍后重试");
        assertThat(r.getMessage())
                .doesNotContain("getMajorId", "NullPointerException", "服务器内部错误:", "p\" is null");
    }

    @Test
    void profileNotReadyIsDistinguishableFromServerFailure() {
        Result<?> r = handler.handleBusinessException(new ProfileNotReadyException());
        assertThat(r.getCode()).as("前端据此弹出可跳转的初始化引导").isEqualTo(409);
        assertThat(r.getMessage()).contains("档案初始化");
        assertThat(ProfileNotReadyException.CODE).isEqualTo(409);
    }

    @Test
    void businessExceptionKeepsItsOwnFriendlyMessage() {
        Result<?> r = handler.handleBusinessException(new BusinessException(400, "该手机号已注册"));
        assertThat(r.getCode()).isEqualTo(400);
        assertThat(r.getMessage()).isEqualTo("该手机号已注册");
    }

    @Test
    void illegalArgumentIsReportedAsClientError() {
        Result<?> r = handler.handleIllegalArgument(new IllegalArgumentException("天数必须在 1~30 之间"));
        assertThat(r.getCode()).isEqualTo(400);
        assertThat(r.getMessage()).contains("天数");
    }
}
