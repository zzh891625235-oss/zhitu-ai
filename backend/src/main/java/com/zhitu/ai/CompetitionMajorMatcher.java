package com.zhitu.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Collections;
import java.util.List;

/**
 * 竞赛「适合专业」与用户专业的匹配规则（唯一事实来源）。
 *
 * <p>为什么单独抽出来：竞赛中心列表页需要给每场比赛标注「是否对口我的专业」，
 * 推荐服务需要按专业过滤候选。如果两处各写一套判断，迟早会出现
 * 「列表页显示对口、推荐结果又说不对口」的矛盾。
 *
 * <p>匹配分三步：
 * <ol>
 *   <li>suitable_major 含 "*" —— 面向所有专业，不算「专业对口」但人人可参加；</li>
 *   <li>专业名直接命中；</li>
 *   <li>同属一个 {@link MajorDirection} 方向也算对口 —— 数据库里只列了「会计学」，
 *       人力资源管理、财务管理同属经管方向，同样应该被识别为对口。</li>
 * </ol>
 */
public final class CompetitionMajorMatcher {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private CompetitionMajorMatcher() {}

    /** suitable_major 是否为 JSON 数组；脏数据时返回 null，由调用方退化处理 */
    private static List<String> parse(String suitableMajorJson) {
        if (suitableMajorJson == null || suitableMajorJson.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try {
            return MAPPER.readValue(suitableMajorJson, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 该竞赛是否面向所有专业（suitable_major 含 "*"）。
     * 这类竞赛人人可参加，但推荐理由不能写成「与你的专业方向对口」。
     */
    public static boolean isOpenToAll(String suitableMajorJson) {
        List<String> list = parse(suitableMajorJson);
        if (list == null) {
            return suitableMajorJson != null && suitableMajorJson.contains("\"*\"");
        }
        return list.contains("*");
    }

    /**
     * 竞赛是否对口该专业。注意：面向所有专业的竞赛这里也返回 true，
     * 判断「专业强相关」时必须先用 {@link #isOpenToAll} 排除。
     */
    public static boolean matches(String suitableMajorJson, String majorName) {
        List<String> list = parse(suitableMajorJson);
        if (list == null) {
            // 脏数据（不是合法 JSON）时退化成包含判断，避免整个列表加载失败
            return majorName != null && !majorName.isEmpty() && suitableMajorJson.contains(majorName);
        }
        if (list.isEmpty()) return false;
        if (list.contains("*")) return true;
        if (majorName == null || majorName.isEmpty()) return false;
        if (list.contains(majorName)) return true;

        MajorDirection mine = MajorDirection.resolve(majorName);
        if (mine.isGeneral()) return false;
        for (String s : list) {
            MajorDirection other = MajorDirection.resolve(s);
            if (!other.isGeneral() && other == mine) return true;
        }
        return false;
    }

    /** 竞赛是否与本专业强相关（不含「不限专业」的比赛） */
    public static boolean isMajorSpecific(String suitableMajorJson, String majorName) {
        return !isOpenToAll(suitableMajorJson) && matches(suitableMajorJson, majorName);
    }

    /**
     * 对口程度。列表页要据此区分「专门为你这个专业办的比赛」和
     * 「同方向相关、可以参加但不是为你专业办的比赛」——
     * 只用 matches() 的布尔值时，统计学学生会被告知「地质技能竞赛」也与他对口。
     */
    public enum MatchLevel {
        /** suitable_major 里精确列出了该专业 */
        EXACT,
        /** 没精确列出，但列出了同方向的其他专业 */
        RELATED,
        /** 面向所有专业 */
        OPEN
    }

    /** 返回对口程度；完全不对口返回 null */
    public static MatchLevel matchLevel(String suitableMajorJson, String majorName) {
        List<String> list = parse(suitableMajorJson);
        if (list == null) {
            // 脏数据：退化成包含判断，只能算「相关」
            if (majorName != null && !majorName.isEmpty() && suitableMajorJson.contains(majorName)) {
                return MatchLevel.RELATED;
            }
            return null;
        }
        if (list.contains("*")) return MatchLevel.OPEN;
        if (majorName == null || majorName.isEmpty()) return null;
        if (list.contains(majorName)) return MatchLevel.EXACT;

        MajorDirection mine = MajorDirection.resolve(majorName);
        if (mine.isGeneral()) return null;
        for (String s : list) {
            MajorDirection other = MajorDirection.resolve(s);
            if (!other.isGeneral() && other == mine) return MatchLevel.RELATED;
        }
        return null;
    }
}
