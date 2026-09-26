package com.zhitu.service;

import java.util.List;
import java.util.Map;

public interface StudyPlanService {
    /** AI生成/调整学习计划 */
    List<Map<String, Object>> generateStudyPlan(Long userId, int days);

    /** 获取当前学习计划 */
    List<Map<String, Object>> getCurrentPlan(Long userId);

    /** 记录今日学习并触发AI分析 */
    Map<String, Object> recordAndAnalyze(Long userId, String content, int minutes, int courseId);
}
