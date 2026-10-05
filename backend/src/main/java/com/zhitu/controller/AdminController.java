package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zhitu.dto.Result;
import com.zhitu.entity.*;
import com.zhitu.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 管理后台接口。
 *
 * 整个 /api/admin/** 由 SecurityConfig 限定为 ADMIN 角色，
 * 因此这里不再逐个方法做权限判断，只需要防住「管理员误操作自己」这一类边界。
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserMapper userMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;
    private final CourseMapper courseMapper;
    private final CompetitionMapper competitionMapper;
    private final AiPlanMapper aiPlanMapper;
    private final AiChatMapper aiChatMapper;
    private final ResumeMapper resumeMapper;
    private final GrowthRecordMapper growthMapper;
    private final LearningRecordMapper learningMapper;
    private final StudyPlanMapper studyPlanMapper;
    private final UserSettingsMapper settingsMapper;
    private final NotificationMapper notificationMapper;

    // ================================================================
    // 平台概览
    // ================================================================

    /** 平台总览统计 */
    @GetMapping("/stats")
    public Result<Map<String, Object>> stats() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("userCount", count(userMapper.selectCount(null)));
        data.put("majorCount", count(majorMapper.selectCount(null)));
        data.put("courseCount", count(courseMapper.selectCount(null)));
        data.put("competitionCount", count(competitionMapper.selectCount(null)));

        data.put("profileCount", count(profileMapper.selectCount(null)));
        data.put("portraitCount", count(profileMapper.selectCount(
            new LambdaQueryWrapper<StudentProfile>().isNotNull(StudentProfile::getAiPortrait))));
        data.put("planCount", count(aiPlanMapper.selectCount(
            new LambdaQueryWrapper<AiPlan>().eq(AiPlan::getPlanType, "FOUR_YEAR"))));
        data.put("resumeCount", count(resumeMapper.selectCount(null)));

        data.put("chatCount", count(aiChatMapper.selectCount(null)));
        data.put("growthCount", count(growthMapper.selectCount(null)));
        data.put("learningCount", count(learningMapper.selectCount(null)));
        data.put("studyPlanCount", count(studyPlanMapper.selectCount(null)));

        data.put("todayUsers", count(userMapper.selectCount(
            new LambdaQueryWrapper<User>().ge(User::getCreatedAt, LocalDate.now().atStartOfDay()))));

        data.put("registerTrend", buildRegisterTrend(7));
        data.put("chatByType", buildChatByType());
        return Result.success(data);
    }

    /** 近 N 天注册趋势，用于后台折线图 */
    private List<Map<String, Object>> buildRegisterTrend(int days) {
        LocalDate today = LocalDate.now();
        LocalDateTime from = today.minusDays(days - 1L).atStartOfDay();

        List<User> users = userMapper.selectList(new LambdaQueryWrapper<User>()
            .select(User::getCreatedAt)
            .ge(User::getCreatedAt, from));

        Map<String, Long> counter = new HashMap<>();
        for (User user : users) {
            if (user.getCreatedAt() == null) {
                continue;
            }
            String day = user.getCreatedAt().toLocalDate().format(DateTimeFormatter.ISO_LOCAL_DATE);
            counter.merge(day, 1L, Long::sum);
        }

        List<Map<String, Object>> trend = new ArrayList<>();
        for (int i = days - 1; i >= 0; i--) {
            String day = today.minusDays(i).format(DateTimeFormatter.ISO_LOCAL_DATE);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", day);
            item.put("count", counter.getOrDefault(day, 0L));
            trend.add(item);
        }
        return trend;
    }

    /** 各对话模式的调用量，用于判断学生最需要哪类帮助 */
    private Map<String, Long> buildChatByType() {
        List<AiChat> chats = aiChatMapper.selectList(new LambdaQueryWrapper<AiChat>().select(AiChat::getChatType));
        Map<String, Long> counter = new LinkedHashMap<>();
        for (AiChat chat : chats) {
            String type = chat.getChatType() == null ? "GENERAL" : chat.getChatType();
            counter.merge(type, 1L, Long::sum);
        }
        return counter;
    }

    // ================================================================
    // 用户管理
    // ================================================================

    /** 用户列表（关键词搜索 + 分页） */
    @GetMapping("/users")
    public Result<Map<String, Object>> users(@RequestParam(defaultValue = "") String keyword,
                                             @RequestParam(defaultValue = "1") int page,
                                             @RequestParam(defaultValue = "10") int size) {
        int pageNo = Math.max(1, page);
        int pageSize = Math.min(50, Math.max(1, size));

        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            wrapper.and(w -> w.like(User::getPhone, kw).or().like(User::getNickname, kw));
        }
        wrapper.orderByDesc(User::getCreatedAt);

        Page<User> result = userMapper.selectPage(new Page<>(pageNo, pageSize), wrapper);
        List<User> users = result.getRecords();

        // 一次性把这一页用户的档案查出来，避免逐条查询造成的 N+1
        Map<Long, StudentProfile> profileMap = Collections.emptyMap();
        if (!users.isEmpty()) {
            List<Long> ids = users.stream().map(User::getId).collect(Collectors.toList());
            profileMap = profileMapper.selectList(
                    new LambdaQueryWrapper<StudentProfile>().in(StudentProfile::getUserId, ids))
                .stream()
                .collect(Collectors.toMap(StudentProfile::getUserId, p -> p, (a, b) -> a));
        }

        // 专业名也一次性映射，同样避免 N+1
        Map<Long, String> majorNames = majorMapper.selectList(null).stream()
            .collect(Collectors.toMap(Major::getId, Major::getName, (a, b) -> a));

        List<Map<String, Object>> records = new ArrayList<>();
        for (User user : users) {
            StudentProfile profile = profileMap.get(user.getId());
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", user.getId());
            item.put("phone", user.getPhone());
            item.put("nickname", user.getNickname());
            item.put("role", user.getRole());
            item.put("createdAt", user.getCreatedAt());
            // 注意：绝不返回密码字段
            item.put("hasProfile", profile != null);
            item.put("school", profile == null ? null : profile.getSchool());
            item.put("grade", profile == null ? null : profile.getGrade());
            item.put("careerGoal", profile == null ? null : profile.getCareerGoal());
            item.put("majorName", profile == null || profile.getMajorId() == null
                ? null : majorNames.get(profile.getMajorId()));
            records.add(item);
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("records", records);
        data.put("total", result.getTotal());
        data.put("page", pageNo);
        data.put("size", pageSize);
        data.put("pages", result.getPages());
        return Result.success(data);
    }

    /**
     * 修改用户角色。
     *
     * 注意：JWT 是无状态的，已签发的 Token 里仍带着旧角色，
     * 被修改的用户需要重新登录才会生效——这一点会在返回消息里明确告诉管理员。
     */
    @PutMapping("/users/{id}/role")
    public Result<?> updateRole(Authentication auth, @PathVariable Long id,
                                @RequestBody Map<String, String> body) {
        Long currentUserId = (Long) auth.getPrincipal();
        if (currentUserId.equals(id)) {
            return Result.error(400, "不能修改自己的角色，请让另一位管理员操作");
        }
        String role = body.get("role");
        if (!"ADMIN".equals(role) && !"STUDENT".equals(role)) {
            return Result.error(400, "角色只能是 ADMIN 或 STUDENT");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.error(404, "用户不存在");
        }
        // 防止把最后一个管理员降级，导致后台再也进不去
        if ("ADMIN".equals(user.getRole()) && !"ADMIN".equals(role) && countAdmins() <= 1) {
            return Result.error(400, "系统至少需要保留一名管理员");
        }
        user.setRole(role);
        userMapper.updateById(user);
        return Result.success("角色已更新为 " + role + "，该用户需重新登录后生效");
    }

    /** 删除用户及其全部关联数据 */
    @DeleteMapping("/users/{id}")
    @Transactional(rollbackFor = Exception.class)
    public Result<?> deleteUser(Authentication auth, @PathVariable Long id) {
        Long currentUserId = (Long) auth.getPrincipal();
        if (currentUserId.equals(id)) {
            return Result.error(400, "不能删除自己的账号");
        }
        User user = userMapper.selectById(id);
        if (user == null) {
            return Result.error(404, "用户不存在");
        }
        if ("ADMIN".equals(user.getRole()) && countAdmins() <= 1) {
            return Result.error(400, "系统至少需要保留一名管理员");
        }

        // 按依赖顺序清理，避免留下孤儿数据
        notificationMapper.delete(new LambdaQueryWrapper<Notification>().eq(Notification::getUserId, id));
        growthMapper.delete(new LambdaQueryWrapper<GrowthRecord>().eq(GrowthRecord::getUserId, id));
        studyPlanMapper.delete(new LambdaQueryWrapper<StudyPlan>().eq(StudyPlan::getUserId, id));
        learningMapper.delete(new LambdaQueryWrapper<LearningRecord>().eq(LearningRecord::getUserId, id));
        aiChatMapper.delete(new LambdaQueryWrapper<AiChat>().eq(AiChat::getUserId, id));
        aiPlanMapper.delete(new LambdaQueryWrapper<AiPlan>().eq(AiPlan::getUserId, id));
        resumeMapper.delete(new LambdaQueryWrapper<Resume>().eq(Resume::getUserId, id));
        settingsMapper.delete(new LambdaQueryWrapper<UserSettings>().eq(UserSettings::getUserId, id));
        profileMapper.delete(new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, id));
        userMapper.deleteById(id);

        return Result.success("用户及其全部数据已删除");
    }

    private long countAdmins() {
        Long total = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getRole, "ADMIN"));
        return total == null ? 0L : total;
    }

    private long count(Long value) {
        return value == null ? 0L : value;
    }
}
