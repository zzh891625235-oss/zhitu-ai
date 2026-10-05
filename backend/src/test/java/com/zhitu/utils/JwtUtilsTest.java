package com.zhitu.utils;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;

class JwtUtilsTest {

    private JwtUtils jwtUtils;

    @BeforeEach
    void setUp() {
        jwtUtils = new JwtUtils();
        ReflectionTestUtils.setField(jwtUtils, "secret", "unit-test-secret-key-at-least-32-bytes-long");
        ReflectionTestUtils.setField(jwtUtils, "expiration", 3600_000L);
    }

    @Test
    void generatedTokenCanBeParsedBack() {
        String token = jwtUtils.generateToken(7L, "13800000000", "ADMIN");

        assertThat(jwtUtils.validateToken(token)).isTrue();
        assertThat(jwtUtils.getUserIdFromToken(token)).isEqualTo(7L);
        assertThat(jwtUtils.getRoleFromToken(token)).isEqualTo("ADMIN");
    }

    @Test
    void tokenWithoutRoleFallsBackToStudent() {
        // 修复前签发的旧 Token 不含 role 声明，
        // 不能因为这次改动让所有老用户集体掉线
        String legacyToken = jwtUtils.generateToken(1L, "13800000000");

        assertThat(jwtUtils.validateToken(legacyToken)).isTrue();
        assertThat(jwtUtils.getRoleFromToken(legacyToken)).isEqualTo("STUDENT");
    }

    @Test
    void tamperedOrMalformedTokenIsRejected() {
        String token = jwtUtils.generateToken(1L, "13800000000", "STUDENT");

        assertThat(jwtUtils.validateToken(token + "x")).isFalse();
        assertThat(jwtUtils.validateToken("not-a-jwt")).isFalse();
        assertThat(jwtUtils.validateToken("")).isFalse();
    }

    @Test
    void tokenSignedWithAnotherSecretIsRejected() {
        String token = jwtUtils.generateToken(1L, "13800000000", "ADMIN");

        JwtUtils other = new JwtUtils();
        ReflectionTestUtils.setField(other, "secret", "a-completely-different-secret-key-value");
        ReflectionTestUtils.setField(other, "expiration", 3600_000L);

        assertThat(other.validateToken(token)).isFalse();
    }

    @Test
    void expiredTokenIsRejected() {
        ReflectionTestUtils.setField(jwtUtils, "expiration", -1000L);
        String token = jwtUtils.generateToken(1L, "13800000000", "STUDENT");

        assertThat(jwtUtils.validateToken(token)).isFalse();
    }
}
