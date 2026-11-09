package com.zhitu.service;

import com.zhitu.ai.AIService;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.AiPlanMapper;
import com.zhitu.mapper.LearningRecordMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.zhitu.mapper.StudyPlanMapper;
import com.zhitu.mapper.UserMapper;
import com.zhitu.service.impl.StudentProfileServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 验证「换专业」会清空所有依赖旧专业的已生成数据。
 *
 * 真实故障：换专业只更新 student_profile 一行，画像(ai_portrait)、四年规划(ai_plan)、
 * 未来学习计划(study_plan)、旧专业课程打卡(learning_record) 全部残留，
 * 用户回到首页/规划页/学习页看到的还是旧专业的内容。
 */
class StudentProfileMajorChangeTest {

    private StudentProfileMapper profileMapper;
    private AiPlanMapper aiPlanMapper;
    private StudyPlanMapper studyPlanMapper;
    private LearningRecordMapper learningRecordMapper;
    private MajorMapper majorMapper;
    private StudentProfileServiceImpl service;

    @BeforeEach
    void setUp() {
        profileMapper = mock(StudentProfileMapper.class);
        UserMapper userMapper = mock(UserMapper.class);
        majorMapper = mock(MajorMapper.class);
        aiPlanMapper = mock(AiPlanMapper.class);
        studyPlanMapper = mock(StudyPlanMapper.class);
        learningRecordMapper = mock(LearningRecordMapper.class);
        AIService aiService = mock(AIService.class);

        service = new StudentProfileServiceImpl(profileMapper, userMapper, majorMapper,
            aiPlanMapper, studyPlanMapper, learningRecordMapper, aiService);

        when(majorMapper.selectById(any())).thenReturn(null);
    }

    private StudentProfile incoming(Long majorId) {
        StudentProfile p = new StudentProfile();
        p.setMajorId(majorId);
        p.setSchool("测试大学");
        p.setGrade("大二");
        p.setGpa("中等");
        p.setInterests("[]");
        p.setCareerGoal("就业");
        return p;
    }

    private StudentProfile existing(Long majorId) {
        StudentProfile p = new StudentProfile();
        p.setId(1L);
        p.setUserId(1L);
        p.setMajorId(majorId);
        return p;
    }

    @Test
    void majorChangedClearsPortraitPlanStudyPlanAndRecords() {
        when(profileMapper.selectOne(any())).thenReturn(existing(7L));

        service.saveProfile(1L, incoming(9L));

        // 画像必须被显式置 null（updateById 会跳过 null，所以走 update + wrapper）
        verify(profileMapper).update(isNull(), any());
        // 四年规划、未来学习计划、旧专业打卡记录都要删
        verify(aiPlanMapper).delete(any());
        verify(studyPlanMapper).delete(any());
        verify(learningRecordMapper).delete(any());
    }

    @Test
    void sameMajorDoesNotClearDerivedData() {
        when(profileMapper.selectOne(any())).thenReturn(existing(7L));

        service.saveProfile(1L, incoming(7L));

        verify(profileMapper, never()).update(isNull(), any());
        verify(aiPlanMapper, never()).delete(any());
        verify(studyPlanMapper, never()).delete(any());
        verify(learningRecordMapper, never()).delete(any());
    }

    @Test
    void firstTimeSaveDoesNotClear() {
        when(profileMapper.selectOne(any())).thenReturn(null);

        service.saveProfile(1L, incoming(7L));

        verify(aiPlanMapper, never()).delete(any());
        verify(learningRecordMapper, never()).delete(any());
    }
}
