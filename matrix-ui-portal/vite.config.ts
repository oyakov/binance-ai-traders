import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    plugins: [react()],
    server: {
      port: 3000,
      host: true,
      proxy: env.VITE_PROM_URL?.startsWith('http') ? undefined : {
        '/prometheus': {
          target: 'http://prometheus-testnet:9090',
          changeOrigin: true,
          rewrite: (p: string) => p.replace(/^\/prometheus/, '')
        }
      }
    },
    preview: { port: 3000 }
  }
})


