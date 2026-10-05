package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.Major;
import com.zhitu.mapper.MajorMapper;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 专业查询控制器
 */
@RestController
@RequestMapping("/api")
public class MajorController {

    private final MajorMapper majorMapper;

    public MajorController(MajorMapper majorMapper) {
        this.majorMapper = majorMapper;
    }

    @GetMapping("/majors")
    public Result<List<Major>> listMajors() {
        // 按 sort_order 返回，保证前端下拉框里「计算机科学与技术」等常见专业排在前面
        List<Major> majors = majorMapper.selectList(
            new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Major>()
                .orderByAsc(Major::getSortOrder));
        return Result.success(majors);
    }
}
