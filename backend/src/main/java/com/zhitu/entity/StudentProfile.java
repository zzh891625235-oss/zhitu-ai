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
    /**
     * 非计算机专业的能力自评 JSON：{"template":"医学类","items":[{"label":"药理学","value":"BASIC"}]}
     * 计算机 / 电子信息方向不使用该字段，仍走上面那 9 个 level 字段。
     */
    private String skillAssessment;
    private String aiPortrait;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
