package com.zhitu.service;

import java.util.Map;

public interface ResumeService {
    Map<String, Object> generateResume(Long userId);
    Map<String, Object> getResume(Long userId);

    /**
     * 保存在线编辑后的简历。
     * 只接受白名单字段并做长度清洗，避免把任意结构写进 content JSON。
     */
    Map<String, Object> saveResume(Long userId, Map<String, Object> resume);
}
