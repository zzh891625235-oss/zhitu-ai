package com.zhitu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.dto.Result;
import com.zhitu.entity.GrowthRecord;
import com.zhitu.entity.LearningRecord;
import com.zhitu.mapper.GrowthRecordMapper;
import com.zhitu.mapper.LearningRecordMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api")
public class GrowthRecordController {

    private final GrowthRecordMapper growthMapper;
    private final LearningRecordMapper learnMapper;

    public GrowthRecordController(GrowthRecordMapper growthMapper, LearningRecordMapper learnMapper) {
        this.growthMapper = growthMapper;
        this.learnMapper = learnMapper;
    }

    /** 添加成长记录 */
    @PostMapping("/growth/record")
    public Result<GrowthRecord> addRecord(Authentication auth, @RequestBody GrowthRecord record) {
        record.setUserId((Long) auth.getPrincipal());
        growthMapper.insert(record);
        return Result.success("添加成功", record);
    }

    /** 获取成长档案汇总 */
    @GetMapping("/growth/archive")
    public Result<Map<String, Object>> getArchive(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();

        // 成长记录按类型分组
        LambdaQueryWrapper<GrowthRecord> gw = new LambdaQueryWrapper<GrowthRecord>()
            .eq(GrowthRecord::getUserId, userId).orderByDesc(GrowthRecord::getRecordDate);
        List<GrowthRecord> allRecords = growthMapper.selectList(gw);

        Map<String, List<Map<String, String>>> grouped = new LinkedHashMap<>();
        for (GrowthRecord r : allRecords) {
            String type = r.getRecordType();
            grouped.computeIfAbsent(type, k -> new ArrayList<>());
            Map<String, String> item = new LinkedHashMap<>();
            item.put("id", r.getId().toString());
            item.put("title", r.getTitle());
            item.put("description", r.getDescription());
            item.put("date", r.getRecordDate() != null ? r.getRecordDate().toString() : "");
            grouped.get(type).add(item);
        }

        // 学习统计
        List<LearningRecord> learnRecords = learnMapper.selectList(
            new LambdaQueryWrapper<LearningRecord>().eq(LearningRecord::getUserId, userId));
        int totalMinutes = learnRecords.stream().mapToInt(r -> r.getStudyMinutes() != null ? r.getStudyMinutes() : 0).sum();
        long courseCount = learnRecords.stream().map(LearningRecord::getCourseId).distinct().count();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("records", grouped);
        result.put("totalStudyMinutes", totalMinutes);
        result.put("coursesLearned", courseCount);
        result.put("totalRecords", allRecords.size());
        return Result.success(result);
    }
}
