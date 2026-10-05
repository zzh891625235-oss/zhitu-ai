<template>
  <div class="career-page">
    <div class="page-hero">
      <h1><el-icon><Compass /></el-icon> 发展方向</h1>
      <p>就业 · 考研 · 保研 · 考公 · 创业 —— 每条路都有清晰规划</p>
    </div>

    <!-- 5条路线卡片 -->
    <div class="path-grid">
      <div class="path-card" v-for="path in paths" :key="path.id"
        :class="{ active: activePath === path.id }"
        @click="activePath = path.id">
        <div class="path-icon">{{ path.icon }}</div>
        <h3>{{ path.title }}</h3>
        <p>{{ path.desc }}</p>
        <span class="path-badge" v-if="path.id === 'job'">最热门</span>
      </div>
    </div>

    <!-- 选中路线的详细规划 -->
    <div class="path-detail" v-if="activePath">
      <div class="detail-header" :style="{ background: currentPath.color }">
        <span class="detail-emoji">{{ currentPath.icon }}</span>
        <div>
          <h2>{{ currentPath.title }}路线规划</h2>
          <p>{{ currentPath.subtitle }}</p>
        </div>
      </div>

      <!-- 阶段时间线 -->
      <div class="stage-timeline">
        <div class="stage-item" v-for="(stage, idx) in currentPath.stages" :key="idx">
          <div class="stage-marker">
            <div class="stage-num" :style="{ background: currentPath.color }">{{ idx + 1 }}</div>
            <div class="stage-line" v-if="idx < currentPath.stages.length - 1"></div>
          </div>
          <div class="stage-card">
            <div class="stage-header">
              <h4>{{ stage.name }}</h4>
              <span class="stage-time">{{ stage.time }}</span>
            </div>
            <div class="stage-tasks">
              <div class="task-item" v-for="t in stage.tasks" :key="t">
                <el-icon :size="14"><Check /></el-icon>
                <span>{{ t }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 关键数据 -->
      <div class="path-facts">
        <div class="fact-card" v-for="f in currentPath.facts" :key="f.label">
          <span class="fact-num" :style="{ color: currentPath.color }">{{ f.value }}</span>
          <span class="fact-label">{{ f.label }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Compass, Check } from '@element-plus/icons-vue'

const activePath = ref('job')

const paths = [
  { id: 'job', icon: '💼', title: '就业', desc: '进入企业，快速成长', color: 'var(--signal)' },
  { id: 'postgrad', icon: '📚', title: '考研', desc: '继续深造，提升学历', color: '#66BB6A' },
  { id: 'recommended', icon: '⭐', title: '保研', desc: '推免读研，提前锁定', color: 'var(--amber)' },
  { id: 'civil', icon: '🏛', title: '考公', desc: '进入体制，稳定发展', color: '#EF5350' },
  { id: 'startup', icon: '🚀', title: '创业', desc: '自主创业，掌控未来', color: '#54A0FF' },
]

const pathData = {
  job: {
    subtitle: '从校园到职场，每一步都算数',
    stages: [
      { name: '基础积累', time: '大一~大二', tasks: ['掌握一门主流语言(Java/Python/C++)', '学习数据结构与算法', '完成2-3个小项目', '通过英语四级'] },
      { name: '技术深化', time: '大二~大三', tasks: ['精通一个技术栈(Spring Boot/Vue/React)', '完成1-2个完整项目', '学习数据库/Redis/消息队列', '刷LeetCode 100+题'] },
      { name: '实习实战', time: '大三寒假/暑假', tasks: ['投递暑期实习(3-5月)', '准备技术面试(八股+算法)', '积累真实项目经验', '建立行业人脉'] },
      { name: '秋招冲刺', time: '大三暑假~大四上', tasks: ['完善简历(项目+实习)', '海投+针对性投递', '模拟面试', '多家对比offer'] },
      { name: '签约入职', time: '大四下', tasks: ['完成毕业设计', '提前学习工作技术栈', '规划职业发展路径', '办理入职手续'] },
    ],
    facts: [
      { value: '15-40万', label: '计算机应届薪资/年' },
      { value: '3-6个月', label: '建议准备周期' },
      { value: '100+', label: '建议投递数量' },
      { value: '3轮+', label: '大厂面试轮次' },
    ]
  },
  postgrad: {
    subtitle: '用一年时间，换一个更高的起点',
    stages: [
      { name: '基础阶段', time: '大三上(9-12月)', tasks: ['确定目标院校和专业', '收集历年真题和资料', '数学(高数/线代/概率)一轮', '英语单词+长难句'] },
      { name: '强化阶段', time: '大三下~暑假(1-8月)', tasks: ['数学二轮强化+刷题', '专业课系统学习(408)', '英语真题阅读', '政治基础+刷题'] },
      { name: '真题阶段', time: '大四上(9-10月)', tasks: ['数学真题(近15年)', '专业课真题+模拟', '英语作文模板', '政治冲刺背诵'] },
      { name: '冲刺阶段', time: '大四上(11-12月)', tasks: ['模拟考试(严格计时)', '查漏补缺', '调整心态', '考前准备'] },
      { name: '复试准备', time: '大四下(2-4月)', tasks: ['机试/笔试复习', '英语口语', '专业课面试', '联系导师'] },
    ],
    facts: [
      { value: '300万+', label: '2026考研报名人数' },
      { value: '30%', label: '计算机录取率约' },
      { value: '9-12月', label: '关键备考期' },
      { value: '408', label: '计算机统考科目' },
    ]
  },
  recommended: {
    subtitle: '用三年努力，换一个免试名额',
    stages: [
      { name: 'GPA为王', time: '大一~大三上', tasks: ['保持专业前10%排名', '核心课成绩85+', '不挂科不重修', '关注保研政策变化'] },
      { name: '英语+竞赛', time: '大二~大三上', tasks: ['六级550+或雅思6.5+', '参加省级以上竞赛获奖', 'ACM/数模/蓝桥杯等', '积累竞赛经历'] },
      { name: '科研+论文', time: '大二下~大三', tasks: ['加入导师实验室', '参与科研项目', '争取发表论文(核心/SCI)', '参加学术会议'] },
      { name: '夏令营/预推免', time: '大三暑假(6-8月)', tasks: ['投递目标院校夏令营', '准备面试(专业+英语)', '联系意向导师', '获取推免资格'] },
      { name: '最终确认', time: '大四上(9-10月)', tasks: ['填报推免系统', '确认录取', '完成毕业设计', '提前进组学习'] },
    ],
    facts: [
      { value: '前10%', label: '通常保研排名要求' },
      { value: '550+', label: '六级推荐分数' },
      { value: '1-2篇', label: '推荐论文数量' },
      { value: '6-8月', label: '夏令营关键期' },
    ]
  },
  civil: {
    subtitle: '行测+申论，系统准备是关键',
    stages: [
      { name: '基础了解', time: '大三上', tasks: ['了解国考/省考/选调', '确定目标地区和岗位', '收集真题资料', '制定学习计划'] },
      { name: '行测专项', time: '大三下(1-6月)', tasks: ['言语理解与表达', '数量关系+资料分析', '判断推理', '常识判断积累'] },
      { name: '申论+真题', time: '大三暑假~大四上(7-10月)', tasks: ['申论写作练习(每周2篇)', '行测真题套卷(近10年)', '模拟考试(严格限时)', '错题整理+弱项突破'] },
      { name: '冲刺+国考', time: '大四上(11-12月)', tasks: ['参加国考笔试', '申论热点押题', '调整状态', '准备省考(备选)'] },
      { name: '面试+体检', time: '大四下(1-4月)', tasks: ['结构化面试练习', '无领导小组讨论', '政审材料准备', '体检准备'] },
    ],
    facts: [
      { value: '60:1', label: '平均竞争比' },
      { value: '6个月', label: '建议准备时间' },
      { value: '行测+申论', label: '两大考试科目' },
      { value: '不限专业', label: '计算机可报岗位多' },
    ]
  },
  startup: {
    subtitle: '风险与机遇并存，准备充分再出发',
    stages: [
      { name: '能力积累', time: '大一~大三', tasks: ['精通至少一个技术方向', '积累项目经验(3个+)', '学习产品/运营/管理知识', '参加创业比赛积累经验'] },
      { name: '方向探索', time: '大三', tasks: ['找到创业方向(痛点验证)', '组建核心团队(2-5人)', 'MVP产品开发', '用户调研+市场分析'] },
      { name: '启动阶段', time: '大四上', tasks: ['参加互联网+等创业大赛', '撰写商业计划书', '申请创业扶持/孵化器', '寻找种子用户'] },
      { name: '落地执行', time: '大四', tasks: ['产品迭代优化', '市场推广+获客', '融资对接(天使轮)', '公司注册+法务'] },
      { name: '持续成长', time: '毕业后', tasks: ['团队扩张', '营收模型验证', 'A轮融资', '规模化发展'] },
    ],
    facts: [
      { value: '1%', label: '创业成功率约' },
      { value: '3人+', label: '建议初始团队' },
      { value: '互联网+', label: '推荐参赛平台' },
      { value: 'MVP', label: '先验证再投入' },
    ]
  }
}

const currentPath = computed(() => pathData[activePath.value])
</script>

<style scoped>
.career-page { max-width: 1100px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.path-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 14px; margin-bottom: 32px; }
.path-card {
  background:var(--glass); border: 2px solid var(--border); border-radius: var(--radius-lg);
  padding: 24px 16px; text-align: center; cursor: pointer;
  transition: all var(--transition); position: relative;
}
.path-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
.path-card.active { border-color: var(--primary); background: rgba(139,195,74,.03); }
.path-icon { font-size: 36px; margin-bottom: 10px; }
.path-card h3 { font-size: 16px; font-weight: 600; margin-bottom: 4px; }
.path-card p { font-size: 12px; color: var(--text-muted); }
.path-badge {
  position: absolute; top: -8px; right: -8px;
  padding: 2px 10px; border-radius: 10px; background: #EF5350;
  color: #fff; font-size: 11px; font-weight: 600;
}

.path-detail { margin-bottom: 40px; }
.detail-header {
  display: flex; align-items: center; gap: 16px;
  padding: 28px 32px; border-radius: var(--radius-lg) var(--radius-lg) 0 0;
  color: #fff;
}
.detail-emoji { font-size: 42px; }
.detail-header h2 { font-size: 22px; font-weight: 700; }
.detail-header p { opacity: .85; font-size: 14px; margin-top: 4px; }

.stage-timeline { padding: 0 32px; background:var(--glass); border: 1px solid var(--border); border-top: none; }
.stage-item { display: flex; gap: 20px; padding: 24px 0; }
.stage-item:not(:last-child) { border-bottom: 1px solid var(--slate-50); }
.stage-marker { display: flex; flex-direction: column; align-items: center; width: 40px; }
.stage-num {
  width: 36px; height: 36px; border-radius: 10px; color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 15px; font-weight: 700; flex-shrink: 0;
}
.stage-line { width: 2px; flex: 1; background: var(--border); min-height: 20px; margin: 6px 0; }
.stage-card { flex: 1; }
.stage-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.stage-header h4 { font-size: 16px; font-weight: 600; }
.stage-time { font-size: 12px; color: var(--text-muted); }
.stage-tasks { display: flex; flex-direction: column; gap: 8px; }
.task-item { display: flex; align-items: center; gap: 8px; font-size: 14px; color: var(--text-secondary); }

.path-facts {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 0;
  background: rgba(255,255,255,.02); border: 1px solid var(--border); border-top: none;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
}
.fact-card { padding: 20px; text-align: center; border-right: 1px solid var(--border); }
.fact-card:last-child { border-right: none; }
.fact-num { display: block; font-size: 24px; font-weight: 700; margin-bottom: 4px; }
.fact-label { display: block; font-size: 12px; color: var(--text-muted); }

@media (max-width:820px){
  .path-grid { grid-template-columns: repeat(2, 1fr); gap: 10px; }
  .path-facts { grid-template-columns: repeat(2, 1fr); }
  .fact-card { border-right: none; border-bottom: 1px solid var(--border); }
  .fact-card:nth-child(odd) { border-right: 1px solid var(--border); }
  .stage-timeline { padding: 0 16px; }
  .detail-header { padding: 20px 18px; }
  .detail-header h2 { font-size: 18px; }
  .stage-header { flex-direction: column; align-items: flex-start; gap: 4px; }
}
</style>
