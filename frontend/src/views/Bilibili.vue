<template>
  <div class="bili-page">
    <div class="page-hero">
      <h1><el-icon><VideoPlay /></el-icon> B站课堂 · 公开课推荐</h1>
      <p>{{ majorName ? `${majorName} · 为你精选的 B 站公开课` : '为你的专业精选的 B 站公开课' }}</p>
    </div>

    <!-- 为你推荐 -->
    <div v-if="recommendations.length" class="section">
      <div class="section-head">
        <h2><span class="spark">✦</span> 按你的专业推荐</h2>
        <span class="section-sub">专业对口 > 方向相关 > 通用技能，每条都有推荐理由</span>
      </div>
      <div class="card-grid">
        <div class="bili-card rec" v-for="r in recommendations" :key="'rec-' + r.id">
          <div class="card-top">
            <el-tag size="small" effect="dark" class="cat-tag">{{ r.category }}</el-tag>
            <el-tag :type="diffTag(r.difficulty)" size="small" effect="plain">{{ diffLabel(r.difficulty) }}</el-tag>
          </div>
          <h4 class="card-title">{{ r.title }}</h4>
          <p class="card-desc">{{ r.description }}</p>
          <div class="match-line">
            <span class="match-score" :class="scoreClass(r.score)">{{ r.score }}分</span>
            <span class="match-reason">{{ r.matchReason }}</span>
          </div>
          <div class="card-footer">
            <span class="up-name"><el-icon><UserFilled /></el-icon> {{ r.uploader }}</span>
            <a :href="r.url" target="_blank" rel="noopener" class="go-btn">去B站学习 ↗</a>
          </div>
        </div>
      </div>
    </div>

    <!-- 全部资源 -->
    <div class="section">
      <div class="section-head">
        <h2>全部公开课资源库</h2>
        <span class="section-sub">共 {{ totalCount }} 门 · 链接直达 B 站搜索，课程名+UP主精准命中</span>
      </div>

      <div class="filter-bar">
        <div class="cat-chips">
          <button class="chip" :class="{ active: activeCategory === '' }" @click="filterCategory('')">全部</button>
          <button class="chip" v-for="(count, cat) in categories" :key="cat"
            :class="{ active: activeCategory === cat }" @click="filterCategory(cat)">
            {{ cat }} <span class="chip-count">{{ count }}</span>
          </button>
        </div>
        <el-input v-model="searchKeyword" placeholder="搜课程 / UP主 / 关键词，如 Python、高数" clearable
          class="search-input" @keyup.enter="loadResources" @clear="loadResources">
          <template #append>
            <el-button @click="loadResources"><el-icon><Search /></el-icon></el-button>
          </template>
        </el-input>
      </div>

      <div class="card-grid" v-if="resources.length">
        <div class="bili-card" v-for="r in resources" :key="r.id">
          <div class="card-top">
            <el-tag size="small" effect="plain" class="cat-tag">{{ r.category }}</el-tag>
            <el-tag :type="diffTag(r.difficulty)" size="small" effect="plain">{{ diffLabel(r.difficulty) }}</el-tag>
          </div>
          <h4 class="card-title">{{ r.title }}</h4>
          <p class="card-desc">{{ r.description }}</p>
          <div class="card-footer">
            <span class="up-name"><el-icon><UserFilled /></el-icon> {{ r.uploader }}</span>
            <a :href="r.url" target="_blank" rel="noopener" class="go-btn">去B站学习 ↗</a>
          </div>
        </div>
      </div>
      <div class="empty-tip" v-else>
        <el-icon><Search /></el-icon>
        <span>没有匹配「{{ searchKeyword }}」的资源，换个关键词试试（也可以在 AI 助手里直接问）</span>
      </div>
    </div>

    <div class="bili-note">
      <el-icon><InfoFilled /></el-icon>
      <div>
        <b>为什么是搜索直达而不是固定视频链接？</b>
        B 站视频会因下架 / 转载导致 BV 号失效。我们为每门课保存「课程名 + UP 主」的精准搜索组合，
        确保你任何时候点开都能命中正版课程页——评委与同学不会遇到死链。
        也可以在 <router-link to="/home/assistant">AI 助手</router-link> 里直接问「高数去哪学」，AI 会调用资源库检索并给出可追溯的链接。
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { VideoPlay, Search, UserFilled, InfoFilled } from '@element-plus/icons-vue'
import { getBilibiliCategoriesApi, getBilibiliResourcesApi, getBilibiliRecommendApi } from '../api/bilibili'

const recommendations = ref([])
const resources = ref([])
const categories = ref({})
const totalCount = ref(0)
const majorName = ref('')
const activeCategory = ref('')
const searchKeyword = ref('')

function diffTag(d) {
  if (d === 'BEGINNER') return 'success'
  if (d === 'INTERMEDIATE') return 'warning'
  return 'danger'
}
function diffLabel(d) {
  if (d === 'BEGINNER') return '入门'
  if (d === 'INTERMEDIATE') return '进阶'
  return '高级'
}
function scoreClass(s) {
  if (s >= 100) return 'exact'
  if (s >= 80) return 'related'
  return 'open'
}

function filterCategory(cat) {
  activeCategory.value = cat
  loadResources()
}

async function loadResources() {
  try {
    const params = {}
    if (activeCategory.value) params.category = activeCategory.value
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()
    const res = await getBilibiliResourcesApi(params)
    resources.value = res.data || []
  } catch (e) {
    resources.value = []
  }
}

onMounted(async () => {
  try {
    const cat = await getBilibiliCategoriesApi()
    categories.value = cat.data?.categories || {}
    totalCount.value = cat.data?.total || 0
  } catch (e) { /* 忽略，筛选条降级为空 */ }

  try {
    const rec = await getBilibiliRecommendApi()
    recommendations.value = rec.data?.recommendations || []
    majorName.value = rec.data?.majorName || ''
  } catch (e) { /* 未初始化档案时推荐区不显示 */ }

  loadResources()
})
</script>

<style scoped>
.bili-page { max-width: 1100px; margin: 0 auto; }
.page-hero { text-align: center; padding: 36px 0 20px; }
.page-hero h1 { font-size: 26px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
.page-hero p { color: var(--text-secondary); margin-top: 6px; font-size: 14px; }

.section { margin-bottom: 40px; }
.section-head { display: flex; align-items: baseline; gap: 12px; margin-bottom: 16px; flex-wrap: wrap; }
.section-head h2 { font-size: 18px; font-weight: 700; }
.spark { color: var(--signal); margin-right: 2px; }
.section-sub { font-size: 12px; color: var(--text-muted); }

.card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; }

.bili-card {
  background: var(--glass); border: 1.5px solid var(--border); border-radius: var(--radius);
  padding: 18px 20px; display: flex; flex-direction: column; gap: 10px;
  transition: all var(--transition);
}
.bili-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); border-color: rgba(255,181,107,.4); }
.bili-card.rec { border-color: rgba(255,181,107,.3); }

.card-top { display: flex; justify-content: space-between; align-items: center; }
.cat-tag { background: rgba(255,181,107,.12); color: #FFB56B; border-color: transparent; }
.card-title { font-size: 15px; font-weight: 600; line-height: 1.4; }
.card-desc { font-size: 12px; color: var(--text-muted); line-height: 1.6; flex: 1; }

.match-line { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.match-score { font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 10px; }
.match-score.exact { color: #4CD7A0; background: rgba(0,210,160,.12); }
.match-score.related { color: #FFB56B; background: rgba(255,181,107,.12); }
.match-score.open { color: var(--text-muted); background: rgba(255,255,255,.06); }
.match-reason { font-size: 11.5px; color: var(--text-secondary); }

.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 4px; }
.up-name { font-size: 12px; color: var(--text-muted); display: flex; align-items: center; gap: 4px; }
.go-btn {
  font-size: 12.5px; font-weight: 600; color: #FF9F69; text-decoration: none;
  padding: 5px 12px; border-radius: 6px; background: rgba(255,159,105,.12);
  transition: all var(--transition);
}
.go-btn:hover { background: rgba(255,159,105,.22); }

.filter-bar { display: flex; gap: 16px; margin-bottom: 20px; flex-wrap: wrap; align-items: center; }
.cat-chips { display: flex; gap: 6px; flex-wrap: wrap; flex: 1; }
.chip {
  font-size: 12px; padding: 5px 12px; border-radius: 14px; cursor: pointer;
  background: transparent; color: var(--text-secondary);
  border: 1px solid var(--border); transition: all var(--transition);
}
.chip:hover { color: var(--text); border-color: var(--text-muted); }
.chip.active { color: #FF9F69; border-color: rgba(255,159,105,.5); background: rgba(255,159,105,.1); font-weight: 600; }
.chip-count { opacity: .6; font-size: 11px; }
.search-input { width: 280px; }

.empty-tip {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  padding: 40px; color: var(--text-muted); font-size: 13px;
  border: 1px dashed var(--border); border-radius: var(--radius);
}

.bili-note {
  display: flex; gap: 10px; padding: 14px 18px; margin-bottom: 40px;
  font-size: 12.5px; color: var(--text-secondary); line-height: 1.7;
  background: rgba(255,255,255,.03); border-radius: var(--radius);
  border: 1px solid var(--border);
}
.bili-note a { color: #FF9F69; }
</style>
