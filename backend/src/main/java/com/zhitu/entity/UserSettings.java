package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user_settings")
public class UserSettings {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String apiKey;
    private String apiUrl;
    private String model;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
