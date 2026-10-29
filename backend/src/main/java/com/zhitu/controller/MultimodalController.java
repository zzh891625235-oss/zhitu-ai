package com.zhitu.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.zhitu.ai.AIService;
import com.zhitu.ai.guard.AiGuard;
import com.zhitu.dto.Result;
import com.zhitu.entity.GrowthRecord;
import com.zhitu.mapper.GrowthRecordMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 多模态接口：用图片喂给模型，让它替学生把证书、奖状填进成长档案。
 *
 * <p>场景很朴素——学生手里有一张获奖证书的照片，要录进档案得手动敲五六个字段，
 * 很多人就此放弃，档案一直是空的。这里把这件事压缩成「拍照 → 自动填好 → 确认入库」三步。
 *
 * <p>处理方式上有一个刻意的克制：模型不支持视觉、或者返回的结果解析不出来时，
 * 接口会如实返回 {@code success=false} 并把原始文本交给前端，让用户自己改，
 * <b>绝不根据图片文件名去猜这是一张三好学生奖状</b>。宁可少一个自动化亮点，
 * 也不能在学生的简历里塞一条他自己没核实过的数据。
 */
@RestController
@RequestMapping("/api/multimodal")
public class MultimodalController {

    private static final Logger log = LoggerFactory.getLogger(MultimodalController.class);

    /** 让模型做的事：抽字段，输出严格 JSON */
    private static final String INSTRUCTION =
            "请识别这张图片，判断它属于下面哪一类，并抽取字段。\n"
            + "recordType 只能是：PROJECT(项目/课程设计) / COMPETITION(竞赛获奖) / "
            + "CERTIFICATE(证书) / INTERNSHIP(实习证明) / HONOR(荣誉)。\n"
            + "严格只输出一个 JSON 对象，不要任何说明文字，字段如下：\n"
            + "{\"recordType\":\"...\",\"title\":\"证书或项目名称\",\"organizer\":\"颁发单位\","
            + "\"date\":\"YYYY-MM-DD，识别不到年份就填图片上最接近的日期或空字符串\","
            + "\"description\":\"60字以内说明你在其中做了什么\",\"confidence\":0到1之间的小数}\n"
            + "实在看不清就说不清：title 填「未能识别」，confidence 给 0。";

    private final AIService aiService;
    private final AiGuard guard;
    private final GrowthRecordMapper growthRecordMapper;

    @Value("${ai.max-image-mb:5}")
    private int maxImageMb;

    public MultimodalController(AIService aiService, AiGuard guard, GrowthRecordMapper growthRecordMapper) {
        this.aiService = aiService;
        this.guard = guard;
        this.growthRecordMapper = growthRecordMapper;
    }

    /** 当前环境的图像理解能力，用于前端决定是否展示上传入口 */
    @GetMapping("/capability")
    public Result<Map<String, Object>> capability(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        Map<String, Object> status = aiService.status(userId);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("configured", Boolean.TRUE.equals(status.get("configured")));
        data.put("maxImageMb", maxImageMb);
        data.put("hint", Boolean.TRUE.equals(status.get("configured"))
                ? "支持图片自动识别，识别出的字段请务必核对后再入库"
                : "未配置支持视觉输入的模型，图片录入暂不可用，可手动填写档案");
        return Result.success(data);
    }

    /**
     * 解析一张图片（证书 / 奖状 / 实习证明）。
     *
     * @return success=true 且 data.record 有值时表示识别成功；
     *         success=false 时 data.raw 里是模型的原始输出，供前端回显让用户手动补
     */
    @PostMapping("/parse")
    public Result<Map<String, Object>> parse(Authentication auth,
                                             @RequestParam("file") MultipartFile file) {
        Long userId = (Long) auth.getPrincipal();

        Map<String, Object> failHint = new LinkedHashMap<>();
        if (file == null || file.isEmpty()) {
            return Result.error(400, "请先选择一张图片");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return Result.error(400, "只支持图片文件，当前上传的是：" + contentType);
        }
        long maxBytes = maxImageMb * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            return Result.error(400, "图片不能超过 " + maxImageMb + "MB");
        }

        String base64;
        try {
            base64 = Base64.getEncoder().encodeToString(file.getBytes());
        } catch (Exception e) {
            log.warn("读取上传图片失败：{}", e.getMessage());
            return Result.error(400, "读取图片失败，请重试");
        }

        String raw = aiService.visionForUser(userId, INSTRUCTION, base64, contentType);
        if (raw == null || raw.trim().isEmpty()) {
            // 这里刻意返回 success + success=false 而不是 HTTP 错误：
            // 「你的模型不支持看图」是产品能力边界，不是接口调用错误，
            // 前端据此切换成手动表单即可，不需要弹一个红色报错。
            failHint.put("success", false);
            failHint.put("reason", "当前模型不支持图像理解，或未配置 API Key / 模型不具备视觉能力");
            failHint.put("manual", true);
            return Result.success(failHint);
        }

        JsonNode node = guard.extractJson(guard.maskSecrets(raw));
        if (node == null) {
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("success", false);
            data.put("raw", raw);
            data.put("reason", "模型返回的内容不是规范 JSON，请核对后手动填写");
            return Result.success(data);
        }

        Map<String, Object> record = new LinkedHashMap<>();
        record.put("recordType", text(node, "recordType", "PROJECT"));
        record.put("title", text(node, "title", ""));
        record.put("organizer", text(node, "organizer", ""));
        record.put("date", text(node, "date", ""));
        record.put("description", text(node, "description", ""));
        record.put("confidence", node.path("confidence").asDouble(0));

        Map<String, Object> data = new LinkedHashMap<>();
        boolean recognized = !"未能识别".equals(record.get("title"))
                && !String.valueOf(record.get("title")).trim().isEmpty();
        data.put("success", recognized);
        data.put("record", record);
        data.put("raw", raw);
        if (!recognized) {
            data.put("reason", "没能看清这张图片的内容，请手动填写或在更清晰的光线下重拍");
        } else if (node.path("confidence").asDouble(1) < 0.6) {
            data.put("warning", "识别置信度较低（" + node.path("confidence").asDouble(0) + "），入库前请务必核对");
        }
        return Result.success(data);
    }

    /** 把确认过的识别结果写入成长档案，闭环到「成长档案 / 简历」模块 */
    @PostMapping("/commit")
    public Result<?> commit(Authentication auth, @RequestBody Map<String, Object> body) {
        Long userId = (Long) auth.getPrincipal();
        if (body == null) {
            return Result.error(400, "缺少数据");
        }
        String title = String.valueOf(body.getOrDefault("title", "")).trim();
        if (title.isEmpty()) {
            return Result.error(400, "标题不能为空");
        }
        String type = String.valueOf(body.getOrDefault("recordType", "PROJECT")).trim();
        if (type.isEmpty()) {
            type = "PROJECT";
        }

        GrowthRecord record = new GrowthRecord();
        record.setUserId(userId);
        record.setRecordType(type);
        record.setTitle(title);
        record.setDescription(String.valueOf(body.getOrDefault("description", "")));

        LocalDate date = parseDate(String.valueOf(body.getOrDefault("date", "")));
        record.setRecordDate(date == null ? LocalDate.now() : date);

        StringBuilder evidence = new StringBuilder();
        String organizer = String.valueOf(body.getOrDefault("organizer", ""));
        if (!organizer.isEmpty() && !"null".equals(organizer)) {
            evidence.append("AI 识别来源：").append(organizer);
        }
        if (evidence.length() > 0) {
            record.setEvidenceUrl(evidence.toString());
        }

        growthRecordMapper.insert(record);
        return Result.success(record);
    }

    private LocalDate parseDate(String value) {
        if (value == null || value.trim().isEmpty() || "null".equals(value)) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim().substring(0, Math.min(10, value.trim().length())));
        } catch (Exception e) {
            return null;
        }
    }

    private String text(JsonNode node, String field, String def) {
        JsonNode v = node.path(field);
        if (v.isNull()) {
            return def;
        }
        String s = v.asText("").trim();
        return s.isEmpty() || "null".equals(s) ? def : s;
    }
}
