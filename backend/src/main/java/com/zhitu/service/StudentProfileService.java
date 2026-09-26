package com.zhitu.service;

import com.zhitu.entity.StudentProfile;
import java.util.Map;

public interface StudentProfileService {
    /** 保存或更新学生档案 */
    StudentProfile saveProfile(Long userId, StudentProfile profile);

    /** 获取当前用户的档案 */
    StudentProfile getByUserId(Long userId);

    /** AI生成学生画像 */
    Map<String, Object> generatePortrait(Long userId);
}
