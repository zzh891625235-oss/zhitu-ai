package com.zhitu.ai.guard;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 频率限制测试：滑动窗口的放行/拦截/恢复行为。
 */
class AgentRateLimiterTest {

    @Test
    void allowsUpToMaxCalls() {
        AgentRateLimiter limiter = new AgentRateLimiter(60_000, 3);
        assertThat(limiter.tryAcquire(1L)).isTrue();
        assertThat(limiter.tryAcquire(1L)).isTrue();
        assertThat(limiter.tryAcquire(1L)).isTrue();
        assertThat(limiter.tryAcquire(1L)).isFalse();
    }

    @Test
    void differentUsersAreIndependent() {
        AgentRateLimiter limiter = new AgentRateLimiter(60_000, 1);
        assertThat(limiter.tryAcquire(1L)).isTrue();
        assertThat(limiter.tryAcquire(2L)).isTrue();
        assertThat(limiter.tryAcquire(1L)).isFalse();
    }

    @Test
    void windowSlidesAndReleases() throws Exception {
        AgentRateLimiter limiter = new AgentRateLimiter(150, 1);
        assertThat(limiter.tryAcquire(1L)).isTrue();
        assertThat(limiter.tryAcquire(1L)).isFalse();
        Thread.sleep(200);
        assertThat(limiter.tryAcquire(1L)).isTrue();
    }

    @Test
    void nullUserIsNotLimited() {
        AgentRateLimiter limiter = new AgentRateLimiter(60_000, 1);
        assertThat(limiter.tryAcquire(null)).isTrue();
        assertThat(limiter.tryAcquire(null)).isTrue();
    }

    @Test
    void retryAfterReflectsOldestCall() {
        AgentRateLimiter limiter = new AgentRateLimiter(60_000, 2);
        limiter.tryAcquire(1L);
        limiter.tryAcquire(1L);
        long wait = limiter.retryAfterSeconds(1L);
        assertThat(wait).isBetween(0L, 60L);
        assertThat(limiter.retryAfterSeconds(2L)).isZero();
    }

    @Test
    void resetClearsTheBucket() {
        AgentRateLimiter limiter = new AgentRateLimiter(60_000, 1);
        assertThat(limiter.tryAcquire(1L)).isTrue();
        limiter.reset(1L);
        assertThat(limiter.tryAcquire(1L)).isTrue();
    }
}
