package com.zhitu.dto;

import lombok.Data;

/**
 * 统一API返回结果。
 *
 * 注意 success 的重载陷阱：
 * 曾经只有 {@code success(T data)} 与 {@code success(String message, T data)} 两个方法，
 * 于是 {@code Result.success("设置已保存")} 会被解析成「把字符串当成 data」，
 * 最终返回的 message 是 "success"，中文提示丢失。
 * 现在补上了 {@code success(String message)}，Java 会选择更具体的重载，语义恢复正确。
 */
@Data
public class Result<T> {
    private int code;
    private String message;
    private T data;

    public static <T> Result<T> success(T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = "success";
        r.data = data;
        return r;
    }

    /**
     * 只返回提示信息、没有业务数据的成功响应。
     *
     * 不要删除这个方法，也不要让它的参数类型变成 Object：
     * 一旦退化成 {@code success(T)}，所有 {@code success("中文提示")} 都会再次丢失 message。
     */
    public static <T> Result<T> success(String message) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = message;
        return r;
    }

    public static <T> Result<T> success(String message, T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = message;
        r.data = data;
        return r;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> r = new Result<>();
        r.code = code;
        r.message = message;
        return r;
    }
}
