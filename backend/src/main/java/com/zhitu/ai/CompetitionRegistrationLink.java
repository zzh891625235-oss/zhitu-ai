package com.zhitu.ai;

import com.zhitu.entity.Competition;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 竞赛「报名入口直达」统一策略。
 *
 * <p><b>为什么单独做一层，而不是直接复用 official_url？</b>
 * 竞赛库里的 official_url 大多是主办单位/学会/集团的门户首页，不是报名页。
 * 例如蓝桥杯的门户是 lanqiao.cn，实际报名系统是 dasai.lanqiao.cn；
 * 传智杯记录在库里的是 itcast.cn（传智教育集团站），实际报名在 boxuegu.com/match。
 * 学生从首页往往要点三四层才能找到报名通知，甚至根本找不到。
 *
 * <p><b>三类报名渠道</b>
 * <ol>
 *   <li>{@link #ONLINE}：有独立在线报名系统的赛事 → 直达官方报名系统（白名单，均为公开可核实的地址）；</li>
 *   <li>{@link #SCHOOL}：由学校/学院统一组织报名的学科竞赛（占大多数）→ 直达「赛事名 + 报名通知」检索结果，
 *       一次点击就能看到组委会通知与本校报名安排，而不是让学生自己猜关键词；</li>
 *   <li>{@link #NOTICE}：仅发布报名通知的赛事 → 直达官方通知检索。</li>
 * </ol>
 * 任何情况下都同时保留 official_url 作为「官网」次入口；两个链接互相兜底，
 * 避免某届赛事更换报名系统后出现死链。
 *
 * <p><b>为什么不落库？</b>
 * 报名系统地址每年都可能变化（例如挑战杯按年份使用 2025./2026. 子域名），
 * 把它们写进种子数据会让老用户的 data/ 目录长期留着过期链接。
 * 这里统一按赛事名在运行时解析，属于 {@code @TableField(exist = false)} 计算字段：
 * 不改表结构、不改种子、不需要用户删库，H2 / MySQL / 分布式数据库三档部署行为完全一致。
 * 维护时只需改本类的 PORTALS 白名单。
 */
public final class CompetitionRegistrationLink {

    /** 官方在线报名系统 */
    public static final String ONLINE = "ONLINE";
    /** 学校 / 学院统一组织报名 */
    public static final String SCHOOL = "SCHOOL";
    /** 官网发布报名通知 */
    public static final String NOTICE = "NOTICE";

    public static final String OPEN = "OPEN";
    public static final String UPCOMING = "UPCOMING";
    public static final String CLOSED = "CLOSED";

    /** 检索直达前缀：搜索词由平台拼好，学生点开即是报名通知，不用自己想关键词 */
    private static final String SEARCH_PREFIX = "https://www.baidu.com/s?wd=";

    /** 已核实的官方报名系统（关键词 → 报名入口）。刻意只放稳定域名，不放带届数/年份的临时路径。 */
    private static final Map<String, String> PORTALS = new LinkedHashMap<>();
    /** 仅发布通知、但官网本身即为报名通知入口的赛事（关键词 → 官网） */
    private static final Map<String, String> NOTICE_SITES = new LinkedHashMap<>();

    static {
        // —— 有独立在线报名系统，且与库里 official_url 明显不同 ——
        PORTALS.put("蓝桥杯", "https://dasai.lanqiao.cn/");
        PORTALS.put("传智杯", "https://www.boxuegu.com/match/");
        PORTALS.put("中国国际大学生创新大赛", "https://cy.ncss.cn/");
        PORTALS.put("中国大学生计算机设计大赛", "https://jsjds.blcu.edu.cn/");

        // —— 官网即报名平台，明确标为「官方在线报名」，与模糊的「官网」区分 ——
        PORTALS.put("团体程序设计天梯赛", "https://gplt.patest.cn/");
        PORTALS.put("ACM-ICPC", "https://icpc.global/");
        PORTALS.put("挑战杯", "https://www.tiaozhanbei.net/");
        PORTALS.put("华为ICT大赛", "https://e.huawei.com/cn/talent/ict-competition");
        PORTALS.put("外研社杯", "https://uchallenge.unipus.cn/");
        PORTALS.put("全国大学生英语竞赛", "https://www.chinaneccs.cn/");
        PORTALS.put("全国大学生电子设计竞赛", "https://nuedc.xjtu.edu.cn/");
        PORTALS.put("全国大学生信息安全竞赛", "http://www.ciscn.cn/");
        PORTALS.put("集成电路创新创业大赛", "https://univ.ciciec.com/");
        PORTALS.put("服务外包创新创业大赛", "http://www.fwwb.org.cn/");
        PORTALS.put("全国大学生市场调查与分析大赛", "http://www.china-csm.org/");
        PORTALS.put("全国大学生统计建模大赛", "http://www.china-csm.org/");

        // —— 官网常年发布报名通知/校内选拔通知，直达官网首页的通知栏目 ——
        NOTICE_SITES.put("全国大学生数学建模竞赛", "http://www.mcm.edu.cn/");
    }

    private CompetitionRegistrationLink() {
    }

    /** 按赛事名解析报名渠道 */
    public static String channel(String name) {
        if (name == null || name.isEmpty()) return SCHOOL;
        for (String key : PORTALS.keySet()) {
            if (name.contains(key)) return ONLINE;
        }
        for (String key : NOTICE_SITES.keySet()) {
            if (name.contains(key)) return NOTICE;
        }
        return SCHOOL;
    }

    /** 报名入口地址：白名单优先，其余走报名通知检索直达，永不返回 null / 空串 */
    public static String resolveUrl(String name, String officialUrl) {
        String ch = channel(name);
        if (ch.equals(ONLINE)) {
            String url = lookup(PORTALS, name);
            return url != null ? url : fallback(officialUrl, name, "官方报名");
        }
        if (ch.equals(NOTICE)) {
            String url = lookup(NOTICE_SITES, name);
            return url != null ? url : fallback(officialUrl, name, "报名通知");
        }
        // 学校统一报名：检索「赛事名 报名通知 校内选拔」，一次点击直达通知列表
        return search(name + " 报名通知 校内选拔");
    }

    /** 渠道说明，展示在按钮下方，避免学生误以为点了就直接提交报名表 */
    public static String label(String ch) {
        if (ONLINE.equals(ch)) return "官方在线报名";
        if (NOTICE.equals(ch)) return "官网发布报名通知";
        return "学校统一组织报名";
    }

    /** 按钮文案：报名状态优先于渠道 */
    public static String action(String ch, String status) {
        if (CLOSED.equals(status)) return "报名已结束";
        if (UPCOMING.equals(status)) return "查看报名安排";
        if (ONLINE.equals(ch)) return "立即报名";
        if (NOTICE.equals(ch)) return "查看报名通知";
        return "校内报名指引";
    }

    /** 报名状态：未开始 / 报名中 / 已截止。日期缺失时保守地认为可报名（只影响按钮文案，不影响链接） */
    public static String status(LocalDate start, LocalDate end, LocalDate today) {
        LocalDate now = today == null ? LocalDate.now() : today;
        if (start != null && now.isBefore(start)) return UPCOMING;
        if (end != null && now.isAfter(end)) return CLOSED;
        return OPEN;
    }

    /** 把 4 个报名字段填进竞赛实体（均为不落库的计算字段） */
    public static void apply(Competition c) {
        if (c == null) return;
        String ch = channel(c.getName());
        String st = status(c.getRegistrationStart(), c.getRegistrationEnd(), LocalDate.now());
        c.setRegistrationChannel(ch);
        c.setRegistrationLabel(label(ch));
        c.setRegistrationUrl(resolveUrl(c.getName(), c.getOfficialUrl()));
        c.setRegistrationStatus(st);
        c.setRegistrationAction(action(ch, st));
    }

    /** 推荐结果 / Agent 工具是 Map 结构，用同一套规则装饰，避免页面与 AI 助手说法不一致 */
    public static void decorate(Map<String, Object> item, Competition c) {
        if (item == null || c == null) return;
        String ch = channel(c.getName());
        String st = status(c.getRegistrationStart(), c.getRegistrationEnd(), LocalDate.now());
        item.put("registrationChannel", ch);
        item.put("registrationLabel", label(ch));
        item.put("registrationUrl", resolveUrl(c.getName(), c.getOfficialUrl()));
        item.put("registrationStatus", st);
        item.put("registrationAction", action(ch, st));
    }

    /** 只有赛事名、没有实体时的轻量版（离线编排 / RAG 文本拼装用） */
    public static String urlByName(String name, String officialUrl) {
        return resolveUrl(name, officialUrl);
    }

    private static String lookup(Map<String, String> table, String name) {
        if (name == null) return null;
        for (Map.Entry<String, String> e : table.entrySet()) {
            if (name.contains(e.getKey())) return e.getValue();
        }
        return null;
    }

    private static String fallback(String officialUrl, String name, String suffix) {
        if (officialUrl != null && !officialUrl.trim().isEmpty()) return officialUrl;
        return search(name + " " + suffix);
    }

    /** URL 编码，保证中文赛事名拼进检索链接后仍然可点开 */
    private static String search(String keyword) {
        try {
            return SEARCH_PREFIX + URLEncoder.encode(keyword == null ? "大学生竞赛报名" : keyword, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            return "https://www.baidu.com/s?wd=%E5%A4%A7%E5%AD%A6%E7%94%9F%E7%AB%9E%E8%B5%9B%E6%8A%A5%E5%90%8D";
        }
    }
}
