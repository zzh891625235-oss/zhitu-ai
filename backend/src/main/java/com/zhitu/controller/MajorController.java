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
        List<Major> majors = majorMapper.selectList(null);
        return Result.success(majors);
    }
}
