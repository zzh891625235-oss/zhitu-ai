package com.zhitu.controller;

import com.zhitu.dto.Result;
import com.zhitu.entity.Competition;
import com.zhitu.mapper.CompetitionMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 竞赛中心控制器
 */
@RestController
@RequestMapping("/api")
public class CompetitionController {

    private final CompetitionMapper competitionMapper;

    public CompetitionController(CompetitionMapper competitionMapper) {
        this.competitionMapper = competitionMapper;
    }

    /** 获取竞赛列表（支持筛选） */
    @GetMapping("/competitions")
    public Result<List<Competition>> listCompetitions(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String difficulty) {
        LambdaQueryWrapper<Competition> wrapper = new LambdaQueryWrapper<>();
        if (type != null && !type.isEmpty()) wrapper.eq(Competition::getType, type);
        if (difficulty != null && !difficulty.isEmpty()) wrapper.eq(Competition::getDifficulty, difficulty);
        wrapper.orderByAsc(Competition::getRegistrationEnd);
        return Result.success(competitionMapper.selectList(wrapper));
    }

    /** 获取竞赛详情 */
    @GetMapping("/competitions/{id}")
    public Result<Competition> getCompetition(@PathVariable Long id) {
        return Result.success(competitionMapper.selectById(id));
    }
}
