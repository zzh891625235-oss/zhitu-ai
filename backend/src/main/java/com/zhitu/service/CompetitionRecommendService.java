package com.zhitu.service;

import java.util.List;
import java.util.Map;

public interface CompetitionRecommendService {
    /** AI竞赛推荐 */
    List<Map<String, Object>> recommend(Long userId);
}
