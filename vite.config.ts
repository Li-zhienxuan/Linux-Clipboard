import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import electron from 'vite-plugin-electron';
import { readFileSync } from 'fs';

// 读取 package.json 获取版本号
const packageJson = JSON.parse(readFileSync('./package.json', 'utf-8'));
const APP_VERSION = packageJson.version;

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [
        react(),
        electron([
          {
            // 主进程入口
            entry: 'electron/main.ts',
            vite: {
              build: {
                outDir: 'dist-electron',
                rollupOptions: {
                  external: ['electron']
                }
              }
            }
          },
          {
            // 预加载脚本
            entry: 'electron/preload.ts',
            onstart(options) {
              // 通知渲染进程重新加载
              options.reload();
            },
            vite: {
              build: {
                outDir: 'dist-electron',
                rollupOptions: {
                  external: ['electron']
                }
              }
            }
          }
        ])
      ],
      build: {
        rollupOptions: {
          output: {
            // 手动代码分割，减小包体积
            manualChunks: {
              // React 相关
              'react-vendor': ['react', 'react-dom'],
              // UI 图标
              'icons': ['lucide-react'],
            }
          }
        }
      },
      define: {
        '__APP_VERSION__': JSON.stringify(APP_VERSION),
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      }
    };
});
