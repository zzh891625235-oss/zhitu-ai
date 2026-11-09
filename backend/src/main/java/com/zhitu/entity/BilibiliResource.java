package com.zhitu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * B 站公开课学习资源。
 *
 * <p>定位：专业学习页的课程地图是「校内该学什么」，这张表是「校外去哪学」——
 * 把大学生口碑较高的 B 站公开课整理成结构化资源库，按专业匹配推荐，
 * 与课程地图形成互补。
 *
 * <p>URL 设计说明：存的是 B 站搜索直达链接（keyword 精确到课程名 + UP 主），
 * 而不是具体 BV 号。原因是视频会下架 / 转载，BV 号会失效；
 * 而「课程名 + UP 主」的搜索组合能长期稳定命中正版课程页，避免评委点开死链。
 */
@Data
@TableName("bilibili_resource")
public class BilibiliResource {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 课程标题（含 UP 主署名习惯写法，用于搜索命中） */
    private String title;

    /** UP 主名称 */
    private String uploader;

    /** 大类：大学基础课 / 编程开发 / 数据与AI / 设计创作 / 职场技能 / 外语提升 / 考研升学 */
    private String category;

    /** 匹配关键词（逗号分隔），供 Agent 检索与站内搜索 */
    private String keywords;

    /** BEGINNER / INTERMEDIATE / ADVANCED */
    private String difficulty;

    /** 适合专业（JSON 数组，"*" 表示通用）。匹配规则与竞赛表一致，复用 CompetitionMajorMatcher */
    private String suitableMajor;

    /** 一句话推荐理由 */
    private String description;

    /** B 站搜索直达链接 */
    private String url;

    /** 推荐优先学习顺序（小的排前面） */
    private Integer sortOrder;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
