import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    proxy: {
      '/api/v1': {
        target: 'http://47.100.36.186:8000',
        changeOrigin: true,
        ws: true,
        // rewrite: (path) => path.replace(new RegExp(`^/api`), ''),
        // only https
        // secure: false
      },
    },
    open: true, // 项目启动后，自动打开
  },
})
