package com.zhitu.utils;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class PasswordUtilsTest {

    /** data.sql 中演示账号（13800000000 / 13900000000）写死的 BCrypt 哈希 */
    private static final String SEED_HASH = "$2a$10$Cdp6ZQ1X9bqElozp94P3j.iTnR6Wpp/fVEhfjtyjd/CeeiWnHGBGG";

    @Test
    void encodedPasswordIsHashedAndVerifiable() {
        String hash = PasswordUtils.encode("123456");

        assertThat(hash).isNotEqualTo("123456");
        assertThat(hash).startsWith("$2a$");
        assertThat(PasswordUtils.matches("123456", hash)).isTrue();
        assertThat(PasswordUtils.matches("wrong-password", hash)).isFalse();
    }

    @Test
    void samePasswordProducesDifferentHashes() {
        // BCrypt 每次加盐，因此同一明文两次加密结果必然不同
        assertThat(PasswordUtils.encode("123456")).isNotEqualTo(PasswordUtils.encode("123456"));
    }

    @Test
    void seedDataHashMatchesDemoPassword() {
        // 守住 data.sql 里的演示账号密码：如果有人手改了那串哈希，
        // 演示账号会在评审现场登录失败，这条测试能第一时间拦住
        assertThat(PasswordUtils.matches("123456", SEED_HASH)).isTrue();
    }
}
