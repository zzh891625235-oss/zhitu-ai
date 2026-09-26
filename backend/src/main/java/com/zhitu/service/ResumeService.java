package com.zhitu.service;

import java.util.Map;

public interface ResumeService {
    Map<String, Object> generateResume(Long userId);
    Map<String, Object> getResume(Long userId);
}
