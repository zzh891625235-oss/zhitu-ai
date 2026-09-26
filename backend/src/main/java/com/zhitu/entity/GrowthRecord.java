package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("growth_record")
public class GrowthRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String recordType;
    private String title;
    private String description;
    private LocalDate recordDate;
    private String evidenceUrl;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
