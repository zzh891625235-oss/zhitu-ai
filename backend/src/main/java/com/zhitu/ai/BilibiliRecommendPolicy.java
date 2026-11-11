package com.zhitu.ai;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.function.ToIntFunction;

/**
 * B 站课堂「推荐位分配」策略——页面「按你的专业推荐」与 Agent 的
 * {@code search_bilibili_courses} 工具共用，保证两处给出的课程顺序和层级一致。
 *
 * <p>解决的问题：早期把 100 / 80 / 60 分课程混在一起按分数排序，当某个专业的
 * 精确对口课程较少时，高数、Excel、考研政治这类通用课会直接占满前排，学生看到
 * 的就是「推荐不对口」。现在按层级分配推荐位：
 * <ol>
 *   <li><b>100 分专业对口</b>优先，尽量占满全部推荐位；</li>
 *   <li>对口课不足时，<b>80 分近亲专业</b>最多补 3 门；</li>
 *   <li>仍不足时，<b>60 分通用技能</b>最多补 2 门，且排在最后；</li>
 *   <li>100 分课程严格按 sort_order（贴合度分层）顺序取满，<b>不设分类上限</b>：
 *       早期为了「多样性」限制每个分类 4 条，结果把高数、大学化学这类门类基础课
 *       排到了专业核心课前面。现在单分类上限只作用于 80/60 分补位层。</li>
 * </ol>
 * 宁可少推，不可错推；任何情况下 100 分课程都不会被 80 / 60 分课程挤掉。
 *
 * <p>与 {@link CourseMajorRelevance} 的分工：后者判定「一门课对某个专业算几分」，
 * 本类决定「这些分数怎么分配展示位」。两者都是纯函数，便于单元测试。
 */
public final class BilibiliRecommendPolicy {

    /** 页面默认展示条数 */
    public static final int DEFAULT_LIMIT = 16;
    /** 近亲专业课程最多补位条数 */
    public static final int MAX_RELATED = 3;
    /** 全专业通用课程最多补位条数 */
    public static final int MAX_OPEN = 2;
    /** 80/60 分补位层：同一分类最多出现几条（100 分对口课不受此限制） */
    public static final int MAX_PER_CATEGORY = 5;

    private BilibiliRecommendPolicy() {}

    /**
     * @param ranked    已经算好分数的候选课程（同分顺序由调用方按 sort_order 排好）
     * @param limit     最多返回几条，&lt;= 0 时使用 {@link #DEFAULT_LIMIT}
     * @param score     取分数的函数
     * @param category  取分类名的函数
     */
    public static <T> PickResult<T> pick(List<T> ranked, int limit,
                                         ToIntFunction<T> score,
                                         Function<T, String> category) {
        int cap = limit > 0 ? limit : DEFAULT_LIMIT;
        List<T> sorted = new ArrayList<>(ranked);
        // List.sort 是稳定排序：同分保留调用方给出的 sort_order 学习顺序
        sorted.sort((a, b) -> Integer.compare(score.applyAsInt(b), score.applyAsInt(a)));

        List<T> exact = new ArrayList<>();
        List<T> related = new ArrayList<>();
        List<T> open = new ArrayList<>();
        for (T item : sorted) {
            int s = score.applyAsInt(item);
            if (s >= CourseMajorRelevance.EXACT) exact.add(item);
            else if (s >= CourseMajorRelevance.RELATED) related.add(item);
            else if (s >= CourseMajorRelevance.OPEN) open.add(item);
        }

        State<T> state = new State<>(category, cap);
        // 100 分课程按 sort_order（贴合度）顺序取满，不因分类上限打乱专业课顺序
        state.take(exact, cap, false);
        // 近亲 / 通用只在有空位时补，各有限额，且避免同一分类刷屏
        int relatedPicked = state.take(related, Math.min(MAX_RELATED, state.remaining()), true);
        int openPicked = state.take(open, Math.min(MAX_OPEN, state.remaining()), true);
        return new PickResult<>(state.out, exact.size(), related.size(), open.size(),
                relatedPicked, openPicked);
    }

    private static final class State<T> {
        private final Function<T, String> category;
        private final int cap;
        private final List<T> out = new ArrayList<>();
        // 同一门课可能在两轮里被扫描到，用引用相等去重
        private final Set<T> seen = Collections.newSetFromMap(new IdentityHashMap<T, Boolean>());
        private final Map<String, Integer> categoryCount = new HashMap<>();

        private State(Function<T, String> category, int cap) {
            this.category = category;
            this.cap = cap;
        }

        private int remaining() {
            return cap - out.size();
        }

        /** 返回本轮实际加入的条数 */
        private int take(List<T> tier, int quota, boolean enforceCategory) {
            if (quota <= 0 || remaining() <= 0) return 0;
            int added = 0;
            for (T item : tier) {
                if (added >= quota || remaining() <= 0) break;
                if (seen.contains(item)) continue;
                String cat = category.apply(item);
                if (cat == null) cat = "";
                int used = categoryCount.containsKey(cat) ? categoryCount.get(cat) : 0;
                if (enforceCategory && used >= MAX_PER_CATEGORY) continue;
                seen.add(item);
                out.add(item);
                categoryCount.put(cat, used + 1);
                added++;
            }
            return added;
        }
    }

    /** 挑选结果 + 分层统计，统计值直接用于页面文案与接口调试 */
    public static final class PickResult<T> {
        private final List<T> items;
        private final int exactTotal;
        private final int relatedTotal;
        private final int openTotal;
        private final int relatedPicked;
        private final int openPicked;

        private PickResult(List<T> items, int exactTotal, int relatedTotal, int openTotal,
                           int relatedPicked, int openPicked) {
            this.items = items;
            this.exactTotal = exactTotal;
            this.relatedTotal = relatedTotal;
            this.openTotal = openTotal;
            this.relatedPicked = relatedPicked;
            this.openPicked = openPicked;
        }

        public List<T> items() { return items; }
        /** 该专业在资源库中精确对口的课程总数（不受展示条数限制） */
        public int exactTotal() { return exactTotal; }
        public int relatedTotal() { return relatedTotal; }
        public int openTotal() { return openTotal; }
        public int relatedPicked() { return relatedPicked; }
        public int openPicked() { return openPicked; }
        public int exactPicked() { return items.size() - relatedPicked - openPicked; }
    }
}
