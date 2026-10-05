package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.Course;
import com.zhitu.entity.LearningRecord;
import com.zhitu.mapper.CourseMapper;
import com.zhitu.mapper.LearningRecordMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 课程学习控制器
 */
@RestController
@RequestMapping("/api")
public class CourseController {

    private final CourseMapper courseMapper;
    private final LearningRecordMapper recordMapper;

    public CourseController(CourseMapper courseMapper, LearningRecordMapper recordMapper) {
        this.courseMapper = courseMapper;
        this.recordMapper = recordMapper;
    }

    /** 获取某专业的所有课程（附带用户学习进度） */
    @GetMapping("/courses")
    public Result<List<Map<String, Object>>> listCourses(
            Authentication auth,
            @RequestParam(defaultValue = "1") Long majorId) {
        Long userId = (Long) auth.getPrincipal();

        List<Course> courses = courseMapper.selectList(
            new LambdaQueryWrapper<Course>()
                .eq(Course::getMajorId, majorId)
                .orderByAsc(Course::getSortOrder));

        // 获取用户学习记录
        List<LearningRecord> records = recordMapper.selectList(
            new LambdaQueryWrapper<LearningRecord>().eq(LearningRecord::getUserId, userId));
        Map<Long, LearningRecord> recordMap = records.stream()
            .collect(Collectors.toMap(LearningRecord::getCourseId, r -> r, (a, b) -> a));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Course c : courses) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", c.getId());
            item.put("name", c.getName());
            item.put("description", c.getDescription());
            item.put("difficulty", c.getDifficulty());
            item.put("semester", c.getSemester());
            item.put("category", c.getCategory());
            item.put("sortOrder", c.getSortOrder());

            LearningRecord rec = recordMap.get(c.getId());
            item.put("progress", rec != null ? rec.getProgress() : 0);
            item.put("status", rec != null ? rec.getStatus() : "NOT_STARTED");
            result.add(item);
        }
        return Result.success(result);
    }

    /** 获取课程详情 */
    @GetMapping("/courses/{id}")
    public Result<Course> getCourse(@PathVariable Long id) {
        Course course = courseMapper.selectById(id);
        return Result.success(course);
    }

    /** 更新学习进度 */
    @PostMapping("/courses/{id}/progress")
    public Result<?> updateProgress(Authentication auth,
                                     @PathVariable Long id,
                                     @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        int progress = toInt(body.get("progress"), 0);
        // 进度收敛到 0-100，避免前端传入越界值污染统计
        progress = Math.max(0, Math.min(100, progress));

        LearningRecord record = recordMapper.selectOne(
            new LambdaQueryWrapper<LearningRecord>()
                .eq(LearningRecord::getUserId, userId)
                .eq(LearningRecord::getCourseId, id));

        if (record == null) {
            record = new LearningRecord();
            record.setUserId(userId);
            record.setCourseId(id);
            record.setProgress(progress);
            record.setStatus(progress >= 100 ? "COMPLETED" : "IN_PROGRESS");
            record.setStudyMinutes(0);
            recordMapper.insert(record);
        } else {
            record.setProgress(progress);
            record.setStatus(progress >= 100 ? "COMPLETED" : "IN_PROGRESS");
            recordMapper.updateById(record);
        }
        return Result.success("进度更新成功");
    }

    /** 宽松地把请求体中的值转成 int，避免前端传 null 或字符串时抛 ClassCastException */
    private int toInt(Object value, int defaultValue) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        if (value instanceof String) {
            try {
                return Integer.parseInt(((String) value).trim());
            } catch (NumberFormatException ignored) {
                return defaultValue;
            }
        }
        return defaultValue;
    }
}
