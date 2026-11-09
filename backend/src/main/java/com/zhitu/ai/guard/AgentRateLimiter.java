package com.zhitu.ai.guard;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Agent 调用频率限制（滑动窗口，进程内）。
 *
 * <p>为什么需要：一次 Agent 对话会触发 1 次 RAG 检索 + 至多 4 轮 LLM 工具循环 +
 * 1 次流式合成，成本远高于普通接口。没有限流时，脚本或误操作可以在一分钟内
 * 烧掉大量模型额度，也可能把演示环境打挂。
 *
 * <p>实现选择：单体部署 + 演示场景下，进程内滑动窗口足够；多实例部署时应换成
 * Redis 令牌桶（注释中给出迁移路径）。窗口滑动而非固定分桶，避免「窗口边界双倍突发」。
 *
 * <p>被限流时返回明确提示而不是默默丢弃——可解释性与 {@link AiGuard} 的设计一致。
 */
@Component
public class AgentRateLimiter {

    private static final Logger log = LoggerFactory.getLogger(AgentRateLimiter.class);

    /** 窗口长度（毫秒）：1 分钟 */
    private final long windowMs;
    /** 窗口内允许的最大次数 */
    private final int maxCalls;

    /** userId -> 该用户窗口内的调用时间戳（毫秒） */
    private final Map<Long, Deque<Long>> buckets = new ConcurrentHashMap<>();

    public AgentRateLimiter() {
        this(60_000, 10);
    }

    /** 测试专用：可注入窗口与上限 */
    public AgentRateLimiter(long windowMs, int maxCalls) {
        this.windowMs = windowMs;
        this.maxCalls = maxCalls;
    }

    /**
     * 尝试获取一次调用许可。
     *
     * @return true 放行；false 被限流
     */
    public synchronized boolean tryAcquire(Long userId) {
        if (userId == null) {
            return true; // 未登录请求由上游鉴权拦截，这里不重复判断
        }
        long now = System.currentTimeMillis();
        Deque<Long> calls = buckets.computeIfAbsent(userId, k -> new ArrayDeque<>());
        evictExpired(calls, now);
        if (calls.size() >= maxCalls) {
            log.warn("用户 {} 触发 Agent 频率限制：{} 秒内超过 {} 次", userId, windowMs / 1000, maxCalls);
            return false;
        }
        calls.addLast(now);
        return true;
    }

    /** 该用户还需等待多少秒才能再次调用（用于提示语），不在窗口内时返回 0 */
    public synchronized long retryAfterSeconds(Long userId) {
        Deque<Long> calls = buckets.get(userId);
        if (calls == null || calls.isEmpty()) {
            return 0;
        }
        long now = System.currentTimeMillis();
        evictExpired(calls, now);
        if (calls.size() < maxCalls) {
            return 0;
        }
        Long oldest = calls.peekFirst();
        return oldest == null ? 0 : Math.max(0, (oldest + windowMs - now) / 1000);
    }

    private void evictExpired(Deque<Long> calls, long now) {
        Iterator<Long> it = calls.iterator();
        while (it.hasNext()) {
            if (now - it.next() >= windowMs) {
                it.remove();
            } else {
                break; // 时间戳按插入顺序递增，后面的都还在窗口内
            }
        }
    }

    /** 测试/管理用途：清空某个用户的计数 */
    public synchronized void reset(Long userId) {
        buckets.remove(userId);
    }
}
