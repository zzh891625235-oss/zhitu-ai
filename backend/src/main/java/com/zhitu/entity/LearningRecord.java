package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("learning_record")
public class LearningRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long courseId;
    private Long knowledgePointId;
    private Integer progress;
    private Integer studyMinutes;
    private String status;
    private String notes;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
