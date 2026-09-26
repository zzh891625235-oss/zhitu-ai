package com.zhitu.service;

import java.util.Map;

public interface FourYearPlanService {
    /** 生成大学四年规划 */
    Map<String, Object> generatePlan(Long userId);

    /** 获取已有的四年规划 */
    Map<String, Object> getPlan(Long userId);
}
