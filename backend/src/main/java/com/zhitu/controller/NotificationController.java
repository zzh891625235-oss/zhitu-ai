package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.dto.Result;
import com.zhitu.entity.Notification;
import com.zhitu.mapper.NotificationMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 站内通知：竞赛报名截止提醒、AI 画像更新、学习计划生成等。
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationMapper notificationMapper;

    public NotificationController(NotificationMapper notificationMapper) {
        this.notificationMapper = notificationMapper;
    }

    /** 通知列表（最新 20 条） */
    @GetMapping
    public Result<List<Notification>> list(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<Notification> list = notificationMapper.selectList(
            new LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .orderByDesc(Notification::getCreatedAt)
                .last("LIMIT 20"));
        return Result.success(list);
    }

    /** 未读数量：导航栏红点用，单表 count 开销很小 */
    @GetMapping("/unread-count")
    public Result<Map<String, Object>> unreadCount(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Long count = notificationMapper.selectCount(
            new LambdaQueryWrapper<Notification>()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, false));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("count", count == null ? 0L : count);
        return Result.success(data);
    }

    /** 标记单条已读 */
    @PutMapping("/{id}/read")
    public Result<?> markRead(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        Notification notification = notificationMapper.selectById(id);
        // 校验归属，避免通过猜 ID 修改他人的通知状态
        if (notification == null || !userId.equals(notification.getUserId())) {
            return Result.error(404, "通知不存在");
        }
        notification.setIsRead(true);
        notificationMapper.updateById(notification);
        return Result.success("已标记为已读");
    }

    /** 全部标记已读 */
    @PutMapping("/read-all")
    public Result<?> markAllRead(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Notification update = new Notification();
        update.setIsRead(true);
        notificationMapper.update(update, new LambdaQueryWrapper<Notification>()
            .eq(Notification::getUserId, userId)
            .eq(Notification::getIsRead, false));
        return Result.success("已全部标记为已读");
    }
}
