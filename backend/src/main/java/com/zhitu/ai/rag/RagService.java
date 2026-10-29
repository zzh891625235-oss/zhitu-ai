package com.zhitu.ai.rag;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.zhitu.entity.Competition;
import com.zhitu.entity.Course;
import com.zhitu.entity.Major;
import com.zhitu.mapper.CompetitionMapper;
import com.zhitu.mapper.CourseMapper;
import com.zhitu.mapper.MajorMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * RAG（Retrieval-Augmented Generation）检索服务。
 *
 * <h3>为什么需要它</h3>
 * 通用大模型不知道「我们学校这个专业有哪些课」「今年有哪些赛事正在报名」，
 * 也不知道本平台沉淀的备考方法论。直接问模型，它会一本正经地编出一份看起来很像
 * 真的清单——这正是本项目要避免的幻觉。所以所有涉及平台内知识的问题，都要先
 * 检索本地知识库，再把检索到的原文片段塞进 Prompt，让模型「看着材料回答」。
 *
 * <h3>语料来源（两条腿）</h3>
 * <ol>
 *   <li><b>动态源</b>：数据库中的竞赛、课程、专业字典——启动时抽取成片段；</li>
 *   <li><b>静态源</b>：{@code classpath:rag/corpus.md}，人工维护的通识知识，
 *       改这个文件不需要改任何 Java 代码。</li>
 * </ol>
 *
 * <h3>检索算法</h3>
 * 中文没有空格分词，外部分词器又会引入额外依赖，因此这里用两级混合检索：
 * <ul>
 *   <li><b>字符二元组（bigram）</b>：把「机器学习」切成 机器/器学/学习，
 *       天然对中文子词匹配友好，也不依赖词典；</li>
 *   <li><b>BM25</b>：经典概率检索模型，能惩罚长文档、抑制高频词权重；</li>
 *   <li><b>哈希向量余弦</b>：把片段映射到 128 维空间，用于兜住「用词不同但语义相近」的情况。</li>
 * </ul>
 * 两者按 0.55 / 0.45 加权融合，最后按知识域（是否属于该学生的专业）做小幅加权。
 * 这样既不引入重量级依赖，也不是单纯的关键词 like 查询。
 */
@Component
public class RagService {

    private static final Logger log = LoggerFactory.getLogger(RagService.class);

    /** 哈希向量维度，权衡内存与区分度 */
    private static final int VECTOR_DIM = 128;
    private static final double BM25_K1 = 1.5;
    private static final double BM25_B = 0.75;
    private static final double W_BM25 = 0.55;
    private static final double W_VECTOR = 0.45;

    private final CompetitionMapper competitionMapper;
    private final CourseMapper courseMapper;
    private final MajorMapper majorMapper;

    /** 片段全体 */
    private volatile List<Chunk> chunks = Collections.emptyList();
    /** 每个词出现在多少个片段中，用于 IDF */
    private volatile Map<String, Integer> docFreq = Collections.emptyMap();
    /** 片段平均长度（词数），用于 BM25 的长度归一 */
    private volatile double avgLength = 1.0;

    public RagService(CompetitionMapper competitionMapper, CourseMapper courseMapper, MajorMapper majorMapper) {
        this.competitionMapper = competitionMapper;
        this.courseMapper = courseMapper;
        this.majorMapper = majorMapper;
    }

    // ================================================================
    // 对外能力
    // ================================================================

    /**
     * 检索与问题最相关的知识片段。
     *
     * @param query    用户问题
     * @param majorName 当前学生的专业名，用于给对口知识加权；可为 null
     * @param topK     返回条数
     */
    public List<Citation> search(String query, String majorName, int topK) {
        if (query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }
        List<Chunk> index = ensureIndex();
        if (index.isEmpty()) {
            return Collections.emptyList();
        }

        List<String> qTokens = tokenize(query);
        if (qTokens.isEmpty()) {
            return Collections.emptyList();
        }
        double[] qVec = embed(qTokens);

        List<Scored> scored = new ArrayList<>(index.size());
        double maxBm25 = 0.0001;
        for (Chunk c : index) {
            double bm25 = bm25Score(qTokens, c);
            if (bm25 > maxBm25) {
                maxBm25 = bm25;
            }
            scored.add(new Scored(c, bm25, cosine(qVec, c.vector)));
        }

        List<Citation> result = new ArrayList<>();
        for (Scored s : scored) {
            double score = W_BM25 * (s.bm25 / maxBm25) + W_VECTOR * Math.max(0.0, s.cosine);
            // 专业相关性加权：命中自己专业 / 类别的片段更值得被引用
            if (majorName != null && !majorName.isEmpty() && s.chunk.text.contains(majorName)) {
                score += 0.15;
            }
            if (score < 0.06) {
                continue; // 相关性太低的不进上下文，避免污染 Prompt
            }
            result.add(new Citation(s.chunk.id, s.chunk.source, s.chunk.sourceId, s.chunk.title,
                    s.chunk.text, round(score)));
        }

        result.sort((a, b) -> Double.compare(b.score, a.score));
        return result.subList(0, Math.min(topK, result.size()));
    }

    /** 把检索结果渲染成可塞进 Prompt 的 Markdown 块，并带编号以便模型引用 */
    public String renderContext(List<Citation> citations) {
        if (citations == null || citations.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("【知识库检索结果】（以下内容来自平台本地知识库，只能引用这些内容回答，禁止自行补充未出现的数字、赛事名或网址）\n");
        for (int i = 0; i < citations.size(); i++) {
            Citation c = citations.get(i);
            sb.append('[').append(i + 1).append("] ").append(c.source).append(" / ").append(c.title).append('\n');
            sb.append(clip(c.text, 320)).append("\n\n");
        }
        return sb.toString();
    }

    /** 索引统计信息，供 /api/agent/rag-stats 展示（也可用于答辩现场证明索引真实存在） */
    public Map<String, Object> stats() {
        List<Chunk> index = ensureIndex();
        Map<String, Integer> bySource = new LinkedHashMap<>();
        for (Chunk c : index) {
            Integer n = bySource.get(c.source);
            bySource.put(c.source, n == null ? 1 : n + 1);
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalChunks", index.size());
        m.put("bySource", bySource);
        m.put("avgLength", Math.round(avgLength * 100.0) / 100.0);
        m.put("vectorDim", VECTOR_DIM);
        return m;
    }

    /** 手动重建索引（管理或数据更新后调用） */
    public synchronized void rebuild() {
        List<Chunk> built = new ArrayList<>();
        try {
            built.addAll(competitionChunks());
        } catch (Exception e) {
            log.warn("构建竞赛知识片段失败（可能数据库尚未就绪）：{}", e.getMessage());
        }
        try {
            built.addAll(courseChunks());
        } catch (Exception e) {
            log.warn("构建课程知识片段失败：{}", e.getMessage());
        }
        try {
            built.addAll(majorChunks());
        } catch (Exception e) {
            log.warn("构建专业知识片段失败：{}", e.getMessage());
        }
        built.addAll(corpusChunks());

        for (Chunk c : built) {
            c.tokens = tokenize(c.text);
            c.vector = embed(c.tokens);
            c.tf = termFrequency(c.tokens);
            c.length = c.tokens.size();
        }

        Map<String, Integer> df = new HashMap<>();
        double total = 0;
        for (Chunk c : built) {
            total += c.length;
            for (String t : uniqueOf(c.tokens)) {
                Integer n = df.get(t);
                df.put(t, n == null ? 1 : n + 1);
            }
        }
        this.avgLength = built.isEmpty() ? 1.0 : Math.max(1.0, total / built.size());
        this.docFreq = df;
        this.chunks = built;
        log.info("RAG 索引构建完成：{} 个片段，平均长度 {} 词", built.size(), Math.round(avgLength));
    }

    // ================================================================
    // 索引构建
    // ================================================================

    private List<Chunk> ensureIndex() {
        List<Chunk> index = chunks;
        if (index.isEmpty()) {
            rebuild();
            index = chunks;
        }
        return index;
    }

    private List<Chunk> competitionChunks() {
        List<Competition> list = competitionMapper.selectList(new LambdaQueryWrapper<Competition>());
        List<Chunk> out = new ArrayList<>();
        for (Competition c : list) {
            if (c.getName() == null) {
                continue;
            }
            StringBuilder sb = new StringBuilder();
            sb.append("竞赛：").append(c.getName()).append('\n');
            sb.append("类别：").append(nvl(c.getType())).append("，难度：").append(nvl(c.getDifficulty())).append('\n');
            if (c.getSuitableMajor() != null && !c.getSuitableMajor().isEmpty()) {
                sb.append("适合专业：").append(c.getSuitableMajor()).append('\n');
            }
            if (c.getSuitableGrade() != null && !c.getSuitableGrade().isEmpty()) {
                sb.append("适合年级：").append(c.getSuitableGrade()).append('\n');
            }
            if (c.getDescription() != null && !c.getDescription().isEmpty()) {
                sb.append("简介：").append(c.getDescription()).append('\n');
            }
            if (c.getOfficialUrl() != null && !c.getOfficialUrl().isEmpty()) {
                sb.append("官网：").append(c.getOfficialUrl());
            }
            out.add(new Chunk("competition", String.valueOf(c.getId()), c.getName(), sb.toString()));
        }
        return out;
    }

    private List<Chunk> courseChunks() {
        List<Course> list = courseMapper.selectList(new LambdaQueryWrapper<Course>());
        List<Chunk> out = new ArrayList<>();
        Map<Long, String> majorNames = new HashMap<>();
        for (Course c : list) {
            if (c.getName() == null) {
                continue;
            }
            String mName = majorNames.get(c.getMajorId());
            if (mName == null && c.getMajorId() != null) {
                Major m = majorMapper.selectById(c.getMajorId());
                mName = m == null ? "" : nvl(m.getName());
                majorNames.put(c.getMajorId(), mName);
            }
            StringBuilder sb = new StringBuilder();
            sb.append("课程：").append(c.getName()).append('\n');
            if (!mName.isEmpty()) {
                sb.append("所属专业：").append(mName).append('\n');
            }
            sb.append("难度：").append(nvl(c.getDifficulty())).append("，建议学期：").append(nvl(c.getSemester())).append('\n');
            if (c.getCategory() != null && !c.getCategory().isEmpty()) {
                sb.append("课程类别：").append(c.getCategory()).append('\n');
            }
            if (c.getDescription() != null && !c.getDescription().isEmpty()) {
                sb.append("课程简介：").append(c.getDescription());
            }
            out.add(new Chunk("course", String.valueOf(c.getId()), c.getName(), sb.toString()));
        }
        return out;
    }

    private List<Chunk> majorChunks() {
        List<Major> list = majorMapper.selectList(new LambdaQueryWrapper<Major>());
        List<Chunk> out = new ArrayList<>();
        for (Major m : list) {
            if (m.getName() == null) {
                continue;
            }
            StringBuilder sb = new StringBuilder();
            sb.append("专业：").append(m.getName()).append('\n');
            if (m.getCategory() != null && !m.getCategory().isEmpty()) {
                sb.append("学科门类：").append(m.getCategory()).append('\n');
            }
            if (m.getDescription() != null && !m.getDescription().isEmpty()) {
                sb.append("专业介绍：").append(m.getDescription());
            }
            out.add(new Chunk("major", String.valueOf(m.getId()), m.getName(), sb.toString()));
        }
        return out;
    }

    /** 读取 classpath 下的静态语料，按 "### 标题 | 标签" 切分 */
    private List<Chunk> corpusChunks() {
        List<Chunk> out = new ArrayList<>();
        try {
            ClassPathResource res = new ClassPathResource("rag/corpus.md");
            if (!res.exists()) {
                return out;
            }
            StringBuilder body = new StringBuilder();
            String title = null;
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(res.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String t = line.trim();
                    if (t.startsWith("###")) {
                        if (title != null && body.length() > 0) {
                            out.add(new Chunk("corpus", "", title, body.toString().trim()));
                        }
                        String raw = t.substring(3).trim();
                        int sep = raw.indexOf('|');
                        title = sep > 0 ? raw.substring(0, sep).trim() : raw;
                        body.setLength(0);
                    } else if (!t.startsWith("#")) {
                        body.append(t).append('\n');
                    }
                }
            }
            if (title != null && body.length() > 0) {
                out.add(new Chunk("corpus", "", title, body.toString().trim()));
            }
        } catch (Exception e) {
            log.warn("读取静态知识库失败：{}", e.getMessage());
        }
        return out;
    }

    // ================================================================
    // 检索算法
    // ================================================================

    private double bm25Score(List<String> queryTokens, Chunk c) {
        int N = chunks.size();
        double score = 0.0;
        for (String t : queryTokens) {
            Integer tf = c.tf.get(t);
            if (tf == null || tf == 0) {
                continue;
            }
            Integer df = docFreq.get(t);
            double n = df == null ? 0 : df;
            double idf = Math.log(1 + (N - n + 0.5) / (n + 0.5));
            double denom = tf + BM25_K1 * (1 - BM25_B + BM25_B * c.length / avgLength);
            score += idf * (tf * (BM25_K1 + 1)) / denom;
        }
        return score;
    }

    /**
     * 分词：中文取字符二元组，英文/数字按连续串成词，单字仅在无法组二元组时保留。
     * 不依赖任何分词库，保证零第三方依赖、可离线运行。
     */
    List<String> tokenize(String text) {
        List<String> out = new ArrayList<>();
        if (text == null) {
            return out;
        }
        String lower = text.toLowerCase(Locale.ROOT);
        StringBuilder ascii = new StringBuilder();
        StringBuilder cjk = new StringBuilder();
        for (int i = 0; i < lower.length(); i++) {
            char ch = lower.charAt(i);
            if ((ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9')) {
                flushCjk(cjk, out);
                ascii.append(ch);
            } else if (isCjk(ch)) {
                flushAscii(ascii, out);
                cjk.append(ch);
            } else {
                flushAscii(ascii, out);
                flushCjk(cjk, out);
            }
        }
        flushAscii(ascii, out);
        flushCjk(cjk, out);
        return out;
    }

    private void flushAscii(StringBuilder buf, List<String> out) {
        if (buf.length() > 0) {
            if (buf.length() >= 2) {
                out.add(buf.toString());
            }
            buf.setLength(0);
        }
    }

    private void flushCjk(StringBuilder buf, List<String> out) {
        if (buf.length() == 0) {
            return;
        }
        if (buf.length() == 1) {
            out.add(buf.toString());
        } else {
            for (int i = 0; i + 1 < buf.length(); i++) {
                out.add(buf.substring(i, i + 2));
            }
        }
        buf.setLength(0);
    }

    private boolean isCjk(char ch) {
        return ch >= '\u4e00' && ch <= '\u9fa5';
    }

    /** 哈希向量 + 次线性 TF 加权，然后做 L2 归一 */
    private double[] embed(List<String> tokens) {
        double[] vec = new double[VECTOR_DIM];
        Map<String, Integer> tf = termFrequency(tokens);
        for (Map.Entry<String, Integer> e : tf.entrySet()) {
            int idx = Math.abs(e.getKey().hashCode()) % VECTOR_DIM;
            vec[idx] += 1 + Math.log(e.getValue());
        }
        double norm = 0.0;
        for (double v : vec) {
            norm += v * v;
        }
        norm = Math.sqrt(norm);
        if (norm > 0) {
            for (int i = 0; i < vec.length; i++) {
                vec[i] /= norm;
            }
        }
        return vec;
    }

    private double cosine(double[] a, double[] b) {
        if (a == null || b == null || a.length != b.length) {
            return 0.0;
        }
        double dot = 0.0;
        for (int i = 0; i < a.length; i++) {
            dot += a[i] * b[i];
        }
        return dot;
    }

    private Map<String, Integer> termFrequency(List<String> tokens) {
        Map<String, Integer> tf = new HashMap<>();
        for (String t : tokens) {
            Integer n = tf.get(t);
            tf.put(t, n == null ? 1 : n + 1);
        }
        return tf;
    }

    private Set<String> uniqueOf(List<String> tokens) {
        return new HashSet<>(tokens);
    }

    private static String nvl(String s) {
        return s == null ? "" : s;
    }

    private static String clip(String s, int max) {
        if (s == null) {
            return "";
        }
        return s.length() <= max ? s : s.substring(0, max) + "…";
    }

    private static double round(double v) {
        return Math.round(v * 10000.0) / 10000.0;
    }

    // ================================================================
    // 数据模型
    // ================================================================

    /** 知识片段（检索的最小单位） */
    private static class Chunk {
        final String id;
        final String source;
        final String sourceId;
        final String title;
        final String text;
        List<String> tokens;
        double[] vector;
        Map<String, Integer> tf;
        int length;

        Chunk(String source, String sourceId, String title, String text) {
            this.id = source + ":" + sourceId + ":" + Math.abs(text.hashCode());
            this.source = source;
            this.sourceId = sourceId;
            this.title = title;
            this.text = text;
        }
    }

    private static class Scored {
        final Chunk chunk;
        final double bm25;
        final double cosine;

        Scored(Chunk chunk, double bm25, double cosine) {
            this.chunk = chunk;
            this.bm25 = bm25;
            this.cosine = cosine;
        }
    }

    /** 引用条目：既用于构造 Prompt，也用于前端「引用来源」气囊 */
    public static class Citation {
        private final String id;
        private final String source;
        private final String sourceId;
        private final String title;
        private final String text;
        private final double score;

        public Citation(String id, String source, String sourceId, String title, String text, double score) {
            this.id = id;
            this.source = source;
            this.sourceId = sourceId;
            this.title = title;
            this.text = text;
            this.score = score;
        }

        public String getId() {
            return id;
        }

        public String getSource() {
            return source;
        }

        public String getSourceId() {
            return sourceId;
        }

        public String getTitle() {
            return title;
        }

        public String getText() {
            return text;
        }

        public double getScore() {
            return score;
        }
    }
}
