package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 站内通知：竞赛报名提醒、AI 画像更新、学习计划生成等。
 * 对应 notification 表，此前只有建表语句没有实体，前端也就无法展示。
 */
@Data
@TableName("notification")
public class Notification {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String title;

    private String content;

    /** 使用包装类型：Lombok 生成的 getter 为 getIsRead()，序列化到前端仍是 isRead */
    private Boolean isRead;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
