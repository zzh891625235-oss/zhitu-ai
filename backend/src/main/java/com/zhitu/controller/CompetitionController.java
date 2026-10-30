package com.zhitu.controller;

import com.zhitu.ai.CompetitionMajorMatcher;
import com.zhitu.dto.Result;
import com.zhitu.entity.Competition;
import com.zhitu.entity.Major;
import com.zhitu.entity.StudentProfile;
import com.zhitu.mapper.CompetitionMapper;
import com.zhitu.mapper.MajorMapper;
import com.zhitu.mapper.StudentProfileMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 竞赛中心控制器
 */
@RestController
@RequestMapping("/api")
public class CompetitionController {

    private final CompetitionMapper competitionMapper;
    private final StudentProfileMapper profileMapper;
    private final MajorMapper majorMapper;

    public CompetitionController(CompetitionMapper competitionMapper,
                                 StudentProfileMapper profileMapper,
                                 MajorMapper majorMapper) {
        this.competitionMapper = competitionMapper;
        this.profileMapper = profileMapper;
        this.majorMapper = majorMapper;
    }

    /**
     * 获取竞赛列表（支持筛选）。
     *
     * @param majorId   按哪个专业判断对口。不传时自动取当前登录用户的档案专业；
     *                  两层都取不到就只返回列表、不做对口标注。
     * @param onlyMatch true 时只返回「对口该专业」的竞赛（精确对口 + 不限专业），
     *                  不含仅同方向的比赛。
     */
    @GetMapping("/competitions")
    public Result<List<Competition>> listCompetitions(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) Long majorId,
            @RequestParam(required = false, defaultValue = "false") boolean onlyMatch,
            Authentication auth) {
        LambdaQueryWrapper<Competition> wrapper = new LambdaQueryWrapper<>();
        if (type != null && !type.isEmpty()) wrapper.eq(Competition::getType, type);
        if (difficulty != null && !difficulty.isEmpty()) wrapper.eq(Competition::getDifficulty, difficulty);
        wrapper.orderByAsc(Competition::getRegistrationEnd);
        List<Competition> list = competitionMapper.selectList(wrapper);

        String majorName = resolveMajorName(majorId, auth);
        if (majorName.isEmpty()) {
            return Result.success(list);
        }

        for (Competition c : list) {
            markMatch(c, majorName);
        }
        if (onlyMatch) {
            list.removeIf(c -> c.getMatchLevel() == null
                    || CompetitionMajorMatcher.MatchLevel.RELATED.name().equals(c.getMatchLevel()));
        }
        return Result.success(list);
    }

    /** 获取竞赛详情 */
    @GetMapping("/competitions/{id}")
    public Result<Competition> getCompetition(@PathVariable Long id, Authentication auth) {
        Competition c = competitionMapper.selectById(id);
        if (c == null) return Result.success(null);
        String majorName = resolveMajorName(null, auth);
        if (!majorName.isEmpty()) markMatch(c, majorName);
        return Result.success(c);
    }

    /** 标注该竞赛与用户专业的对口程度 */
    private void markMatch(Competition c, String majorName) {
        CompetitionMajorMatcher.MatchLevel level =
                CompetitionMajorMatcher.matchLevel(c.getSuitableMajor(), majorName);
        c.setMatchLevel(level == null ? null : level.name());
        c.setOpenToAll(level == CompetitionMajorMatcher.MatchLevel.OPEN);
        c.setMatchMyMajor(level != null);
    }

    /**
     * 解析用于匹配的专业名称：显式传入的 majorId 优先，其次取当前登录用户的档案专业。
     * 解析不出来返回空串，调用方据此跳过对口标注（未初始化档案的用户照常浏览）。
     */
    private String resolveMajorName(Long explicitMajorId, Authentication auth) {
        Long majorId = explicitMajorId;
        if (majorId == null && auth != null && auth.getPrincipal() instanceof Long) {
            Long userId = (Long) auth.getPrincipal();
            try {
                StudentProfile profile = profileMapper.selectOne(
                        new LambdaQueryWrapper<StudentProfile>().eq(StudentProfile::getUserId, userId));
                if (profile != null) majorId = profile.getMajorId();
            } catch (Exception ignored) {
                // 档案表异常不应影响竞赛列表加载
            }
        }
        if (majorId == null) return "";
        try {
            Major major = majorMapper.selectById(majorId);
            return major == null ? "" : major.getName();
        } catch (Exception e) {
            return "";
        }
    }
}
