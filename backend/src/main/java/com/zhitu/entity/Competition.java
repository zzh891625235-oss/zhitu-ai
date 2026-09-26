package com.zhitu.entity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("competition")
public class Competition {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String description;
    private String type;
    private String suitableMajor;
    private String suitableGrade;
    private LocalDate registrationStart;
    private LocalDate registrationEnd;
    private LocalDate competitionStart;
    private LocalDate competitionEnd;
    private String difficulty;
    private String officialUrl;
    private Integer recommendDays;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
