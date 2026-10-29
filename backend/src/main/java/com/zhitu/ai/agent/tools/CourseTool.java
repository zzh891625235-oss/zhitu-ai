package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.Course;
import com.zhitu.entity.LearningRecord;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.CourseMapper;
import com.zhitu.mapper.LearningRecordMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 读取本专业的课程地图与个人学习进度。
 *
 * 这个工具回答的是「我接下来该学哪门课」——它会把该专业的全部课程与这名学生的
 * 学习进度对上，标出未开始 / 进行中 / 已完成的分布，让模型能挑出真正的下一步。
 */
@Component
public class CourseTool extends JsonTool {

    private final CourseMapper courseMapper;
    private final LearningRecordMapper learningRecordMapper;
    private final StudentProfileMapper profileMapper;

    public CourseTool(CourseMapper courseMapper, LearningRecordMapper learningRecordMapper,
                      StudentProfileMapper profileMapper) {
        this.courseMapper = courseMapper;
        this.learningRecordMapper = learningRecordMapper;
        this.profileMapper = profileMapper;
    }

    @Override
    public String name() {
        return "list_courses_with_progress";
    }

    @Override
    public String description() {
        return "列出该学生所学专业的全部课程，并附带他每门课的学习进度百分比与状态。"
                + "当需要回答「下一步学什么」「哪些课落后了」「专业课怎么安排」时调用。"
                + "可用 onlyNotFinished=true 只看未完成的课程。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        Map<String, Object> props = new LinkedHashMap<>();
        props.put("onlyNotFinished", ToolSchemas.prop("boolean", "为 true 时只返回进度未满 100% 的课程"));
        props.put("limit", ToolSchemas.intProp("最多返回多少门课，默认 20"));
        return ToolSchemas.object(props);
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        Map<String, Object> out = new LinkedHashMap<>();
        if (p == null || p.getMajorId() == null) {
            out.put("available", false);
            out.put("message", "未填写档案或未知专业，无法给出该专业课程地图");
            return json(out);
        }

        List<Course> courses = courseMapper.selectList(
                new LambdaQueryWrapper<Course>().eq(Course::getMajorId, p.getMajorId())
                        .orderByAsc(Course::getSortOrder).orderByAsc(Course::getId));

        Map<Long, LearningRecord> progressMap = new HashMap<>();
        for (LearningRecord r : learningRecordMapper.selectList(
                new LambdaQueryWrapper<LearningRecord>().eq(LearningRecord::getUserId, userId))) {
            if (r.getCourseId() != null) {
                progressMap.put(r.getCourseId(), r);
            }
        }

        boolean onlyNotFinished = Boolean.parseBoolean(str(arguments, "onlyNotFinished", "false"));
        int limit = integer(arguments, "limit", 20);

        List<Map<String, Object>> list = new ArrayList<>();
        int finished = 0;
        double progressSum = 0;
        for (Course c : courses) {
            LearningRecord r = progressMap.get(c.getId());
            int progress = r == null || r.getProgress() == null ? 0 : r.getProgress();
            if (onlyNotFinished && progress >= 100) {
                continue;
            }
            if (progress >= 100) {
                finished++;
            }
            progressSum += progress;
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("name", c.getName());
            item.put("semester", c.getSemester());
            item.put("difficulty", c.getDifficulty());
            item.put("category", c.getCategory());
            item.put("progress", progress);
            item.put("status", progress >= 100 ? "COMPLETED" : (progress > 0 ? "IN_PROGRESS" : "NOT_STARTED"));
            list.add(item);
        }

        out.put("available", true);
        out.put("totalCourses", courses.size());
        out.put("finishedCourses", finished);
        out.put("averageProgress", courses.isEmpty() ? 0 : Math.round(progressSum / courses.size() * 10.0) / 10.0);
        out.put("courses", list.subList(0, Math.min(limit, list.size())));
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "private:course+learning_record";
    }
}
