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

    /**
     * 以下字段不落库，只在查询时按当前用户专业填充：
     * 竞赛中心要用它们给卡片打「对口我的专业」标记并支持按专业过滤。
     */
    @TableField(exist = false)
    private Boolean matchMyMajor;
    @TableField(exist = false)
    private Boolean openToAll;
    /** EXACT / RELATED / OPEN，见 CompetitionMajorMatcher.MatchLevel */
    @TableField(exist = false)
    private String matchLevel;

    /**
     * 报名入口直达（不落库）：由 CompetitionRegistrationLink 在返回前统一填充。
     * 报名系统地址每年会变，写入数据库会让老用户长期留着过期链接，
     * 因此做成计算字段：不改表结构、不需要清库，H2 / MySQL / 分布式三档行为一致。
     */
    @TableField(exist = false)
    private String registrationUrl;
    @TableField(exist = false)
    private String registrationChannel;
    @TableField(exist = false)
    private String registrationLabel;
    @TableField(exist = false)
    private String registrationStatus;
    @TableField(exist = false)
    private String registrationAction;
}
