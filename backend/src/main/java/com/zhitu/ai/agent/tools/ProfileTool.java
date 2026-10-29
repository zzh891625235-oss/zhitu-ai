package com.zhitu.ai.agent.tools;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.ai.agent.JsonTool;
import com.zhitu.ai.agent.ToolSchemas;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 读取学生学籍档案。
 *
 * Agent 回答任何个性化问题之前，几乎都要先搞清楚「这个学生是谁」：什么专业、几年级、
 * GPA 多少、想就业还是考研。这个工具就是这条链路的起点，也是 Agent 里被调用频率最高的工具。
 */
@Component
public class ProfileTool extends JsonTool {

    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;

    public ProfileTool(StudentProfileMapper profileMapper, MajorMapper majorMapper) {
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    @Override
    public String name() {
        return "get_student_profile";
    }

    @Override
    public String description() {
        return "读取当前学生的学籍档案：学校、专业、年级、GPA、升学或就业目标。"
                + "任何需要个性化背景的问题（推荐课程、推荐竞赛、制定计划、判断进度）都应该先调用它。"
                + "若返回 initialized=false，说明学生还没填写档案，此时不要凭空假设他的专业与年级，应引导他先完善档案。";
    }

    @Override
    public Map<String, Object> parametersSchema() {
        return ToolSchemas.emptyObject();
    }

    @Override
    public String execute(Long userId, Map<String, Object> arguments) {
        StudentProfile p = profileMapper.selectOne(
                new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
        Map<String, Object> out = new LinkedHashMap<>();
        if (p == null) {
            out.put("initialized", false);
            out.put("message", "该学生尚未填写成长档案，专业、年级、目标等信息未知");
            return json(out);
        }
        String majorName = null;
        String category = null;
        if (p.getMajorId() != null) {
            Major m = majorMapper.selectById(p.getMajorId());
            if (m != null) {
                majorName = m.getName();
                category = m.getCategory();
            }
        }
        out.put("initialized", true);
        out.put("school", p.getSchool());
        out.put("major", majorName);
        out.put("majorCategory", category);
        out.put("grade", p.getGrade());
        out.put("gpa", p.getGpa());
        out.put("careerGoal", p.getCareerGoal());
        out.put("interests", p.getInterests());
        return json(out);
    }

    @Override
    public String dataDomain() {
        return "private:student_profile";
    }
}
