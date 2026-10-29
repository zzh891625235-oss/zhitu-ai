import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  },
  build: {
    // es2018 覆盖绝大多数校园场景的浏览器，同时避免降级带来的 polyfill 体积
    target: 'es2018',
    cssCodeSplit: true,
    // 默认 500KB 的警告阈值在这里没有意义，我们关心的是分包之后单包是否仍然过大
    chunkSizeWarningLimit: 900,
    rollupOptions: {
      output: {
        // 依赖与业务代码分离：业务改动时依赖包的长期缓存不会失效。
        // echarts 单独拆出，是因为只有少数页面用得上图表，不应该进入首屏。
        manualChunks(id) {
          if (!id.includes('node_modules')) return
          if (id.includes('echarts')) return 'vendor-echarts'
          if (id.includes('element-plus') || id.includes('@element-plus')) return 'vendor-element'
          if (id.includes('/vue/') || id.includes('vue-router') || id.includes('pinia') || id.includes('axios')) {
            return 'vendor-core'
          }
          return 'vendor'
        }
      }
    }
  }
})
