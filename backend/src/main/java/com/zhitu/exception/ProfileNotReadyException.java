package com.zhitu.exception;

/**
 * 学生尚未完成 AI 成长档案初始化，却调用了依赖专业/年级的生成类功能。
 *
 * <p>为什么不用普通的 {@link RuntimeException}：以前这些分支统一落到
 * {@code GlobalExceptionHandler#handleException}，会返回
 * 「服务器内部错误: 请先完善个人档案」，甚至把 Java 空指针原文
 * （{@code Cannot invoke "...getMajorId()" because "p" is null}）直接展示在浏览器里。
 * 评委用新注册账号点一下「生成规划」就会看到这种红色报错，观感很糟糕。
 *
 * <p>现在用 409 与真正的服务端故障区分开：前端拦截器识别到 409 会弹出
 * 「去完成档案初始化」的可跳转引导，其余 500 只显示通用文案。
 */
public class ProfileNotReadyException extends BusinessException {

    public static final int CODE = 409;
    public static final String MESSAGE = "请先完成 AI 成长档案初始化，再使用这个功能";

    public ProfileNotReadyException() {
        super(CODE, MESSAGE);
    }
}
