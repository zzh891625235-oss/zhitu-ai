<template>
  <div class="page-container">
    <div class="page-header">
      <h2>Courses</h2>
      <p>此页面功能开发中，敬请期待...</p>
    </div>
    <el-empty description="功能开发中">
      <el-button type="primary" @click="goHome">返回首页</el-button>
    </el-empty>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()
const goHome = () => router.push('/')
</script>

<style scoped>
.page-container { padding: 20px; }
.page-header { margin-bottom: 40px; text-align: center; }
.page-header h2 { font-size: 24px; color: #333; margin-bottom: 8px; }
.page-header p { color: #999; }
</style>
