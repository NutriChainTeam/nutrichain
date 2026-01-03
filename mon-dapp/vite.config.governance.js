import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist-governance',
    rollupOptions: {
      input: {
        main: 'index-governance.html',
      },
    },
  },
})
