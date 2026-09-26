package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("ai_chat")
public class AiChat {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String chatType;
    private String question;
    private String answer;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
