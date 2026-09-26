package com.zhitu.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("ai_plan")
public class AiPlan {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String planType;
    private String content;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
