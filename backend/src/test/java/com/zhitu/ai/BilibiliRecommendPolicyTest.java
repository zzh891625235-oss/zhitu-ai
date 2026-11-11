package com.zhitu.ai;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 推荐位分配策略测试。
 *
 * 回归场景：早期把 100/80/60 分混在一起排序，专业对口课少的时候，
 * 高数、Excel、考研政治这些通用课会占满前排，学生看到「推荐不对口」。
 * 现在必须保证对口课优先占满、近亲与通用课严格限量、且只做补位。
 */
class BilibiliRecommendPolicyTest {

    private static final class Item {
        final String name;
        final int score;
        final String category;

        Item(String name, int score, String category) {
            this.name = name;
            this.score = score;
            this.category = category;
        }
    }

    private static Item item(String name, int score, String category) {
        return new Item(name, score, category);
    }

    private static BilibiliRecommendPolicy.PickResult<Item> pick(List<Item> all, int limit) {
        return BilibiliRecommendPolicy.pick(all, limit, i -> i.score, i -> i.category);
    }

    private static List<String> names(List<Item> items) {
        List<String> out = new ArrayList<>();
        for (Item i : items) out.add(i.name);
        return out;
    }

    @Test
    void exactCoursesFillAllSlotsWhenThereAreEnough() {
        List<Item> all = new ArrayList<>();
        for (int i = 0; i < 20; i++) {
            all.add(item("对口课" + i, CourseMajorRelevance.EXACT, "分类" + (i % 4)));
        }
        for (int i = 0; i < 5; i++) all.add(item("近亲课" + i, CourseMajorRelevance.RELATED, "近亲类"));
        for (int i = 0; i < 5; i++) all.add(item("通用课" + i, CourseMajorRelevance.OPEN, "通用类"));

        BilibiliRecommendPolicy.PickResult<Item> result = pick(all, 16);
        assertThat(result.items()).hasSize(16);
        assertThat(result.exactPicked()).isEqualTo(16);
        assertThat(result.relatedPicked()).isZero();
        assertThat(result.openPicked()).isZero();
        assertThat(names(result.items())).noneMatch(n -> n.startsWith("通用课") || n.startsWith("近亲课"));
        assertThat(result.exactTotal()).isEqualTo(20);
    }

    @Test
    void relatedAndOpenAreStrictlyCappedAndOnlyFillLeftovers() {
        List<Item> all = new ArrayList<>();
        all.add(item("对口A", CourseMajorRelevance.EXACT, "专业课"));
        all.add(item("对口B", CourseMajorRelevance.EXACT, "专业课"));
        for (int i = 0; i < 10; i++) all.add(item("近亲课" + i, CourseMajorRelevance.RELATED, "近亲类"));
        for (int i = 0; i < 10; i++) all.add(item("通用课" + i, CourseMajorRelevance.OPEN, "通用类"));

        BilibiliRecommendPolicy.PickResult<Item> result = pick(all, 16);
        assertThat(result.items()).hasSize(7);           // 2 + 3 + 2，宁缺毋滥
        assertThat(result.exactPicked()).isEqualTo(2);
        assertThat(result.relatedPicked()).isEqualTo(BilibiliRecommendPolicy.MAX_RELATED);
        assertThat(result.openPicked()).isEqualTo(BilibiliRecommendPolicy.MAX_OPEN);
        assertThat(names(result.items()).subList(0, 2)).containsExactly("对口A", "对口B");
        // 通用课永远排在最后
        assertThat(names(result.items()).subList(5, 7)).allMatch(n -> n.startsWith("通用课"));
    }

    @Test
    void categoryCapNeverHidesExactCourses() {
        // 20 门对口课全挤在同一个分类里：分类多样性不能打断「专业课优先」，
        // 仍然应该取满 16 门专业课，而不是让通用课填空。
        List<Item> all = new ArrayList<>();
        for (int i = 0; i < 20; i++) all.add(item("对口课" + i, CourseMajorRelevance.EXACT, "理工专业课"));
        for (int i = 0; i < 5; i++) all.add(item("通用课" + i, CourseMajorRelevance.OPEN, "职场技能"));

        BilibiliRecommendPolicy.PickResult<Item> result = pick(all, 16);
        assertThat(result.items()).hasSize(16);
        assertThat(result.exactPicked()).isEqualTo(16);
        assertThat(names(result.items())).allMatch(n -> n.startsWith("对口课"));
    }

    @Test
    void noExactCoursesStillReturnsExplainableLimitedMix() {
        List<Item> all = new ArrayList<>();
        for (int i = 0; i < 4; i++) all.add(item("近亲课" + i, CourseMajorRelevance.RELATED, "近亲类"));
        for (int i = 0; i < 4; i++) all.add(item("通用课" + i, CourseMajorRelevance.OPEN, "通用类"));

        BilibiliRecommendPolicy.PickResult<Item> result = pick(all, 10);
        assertThat(result.exactPicked()).isZero();
        assertThat(result.items()).hasSize(BilibiliRecommendPolicy.MAX_RELATED + BilibiliRecommendPolicy.MAX_OPEN);
        assertThat(result.relatedPicked()).isEqualTo(3);
        assertThat(result.openPicked()).isEqualTo(2);
    }

    @Test
    void stableOrderKeepsLearningSequenceWithinSameScore() {
        List<Item> all = new ArrayList<>();
        all.add(item("先导课", CourseMajorRelevance.EXACT, "A"));
        all.add(item("主干课", CourseMajorRelevance.EXACT, "B"));
        all.add(item("进阶课", CourseMajorRelevance.EXACT, "C"));
        all.add(item("通用课", CourseMajorRelevance.OPEN, "D"));

        assertThat(names(pick(all, 3).items())).containsExactly("先导课", "主干课", "进阶课");
        // limit <= 0 时使用默认 16 条
        assertThat(pick(all, 0).items()).hasSize(4);
    }
}
