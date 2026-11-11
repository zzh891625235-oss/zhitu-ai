package com.zhitu.exception;

import com.zhitu.dto.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理。
 *
 * <p>一条重要原则：<b>内部异常细节只进服务端日志，不返回给浏览器</b>。
 * 原实现把 {@code e.getMessage()} 直接拼进「服务器内部错误: ...」，
 * 于是空指针的类名、字段名都会出现在页面红色提示里，例如新用户点
 * 「生成简历」会看到 {@code Cannot invoke "...getMajorId()" because "p" is null}。
 * 演示环境里既难看，也把内部实现细节摊给了评委。
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** 业务异常：文案是我们自己写的，可以安全地展示给用户 */
    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValidation(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors()
                .stream().map(f -> f.getDefaultMessage())
                .findFirst().orElse("参数校验失败");
        return Result.error(400, msg);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public Result<?> handleIllegalArgument(IllegalArgumentException e) {
        log.warn("参数不合法: {}", e.getMessage());
        return Result.error(400, e.getMessage() == null ? "参数不合法" : e.getMessage());
    }

    /**
     * 兜底：真实堆栈写入服务端日志方便排查，对用户只给稳定的通用提示。
     * 不要再改回拼接 e.getMessage()。
     */
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("未处理的请求异常", e);
        return Result.error(500, "操作未完成，请稍后重试");
    }
}
