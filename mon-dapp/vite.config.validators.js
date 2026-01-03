import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  base: '/validators/', // Très important pour les chemins CSS/JS
  build: {
    outDir: 'dist-validators',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index-validators.html'),
      },
    },
    cssCodeSplit: false, // Force la génération d'un seul fichier CSS
  },
})
