package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("student_profile")
public class StudentProfile {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String school;
    private Long majorId;
    private String grade;
    private String gpa;
    private String programmingLevel;
    private String javaLevel;
    private String pythonLevel;
    private String cppLevel;
    private String dsLevel;
    private String dbLevel;
    private String webLevel;
    private String aiLevel;
    private String englishLevel;
    private String interests;
    private String careerGoal;
    private String aiPortrait;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
