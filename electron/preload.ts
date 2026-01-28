import { contextBridge, ipcRenderer } from 'electron';

// 定义 Electron API 接口
export interface ElectronAPI {
  readClipboard: () => Promise<{ type: string; content: string } | null>;
  toggleWindow: () => void;
  minimizeToTray: () => void;
  onClipboardChange: (callback: (data: { type: string; content: string; timestamp: number }) => void) => (() => void) | undefined;
  getSettings: () => Promise<any>;
  setSetting: (key: string, value: any) => Promise<void>;
  getApiKey: () => Promise<string>;
  setApiKey: (apiKey: string) => Promise<void>;
  getVersion: () => Promise<{
    version: string;
    electronVersion: string;
    chromeVersion: string;
    nodeVersion: string;
    platform: string;
    arch: string;
  }>;
  platform: string;
  isElectron: boolean;
}

// 暴露安全的 API 给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
  // 剪贴板操作
  readClipboard: () => ipcRenderer.invoke('clipboard:read'),

  // 窗口控制
  toggleWindow: () => ipcRenderer.send('app:toggle'),
  minimizeToTray: () => ipcRenderer.send('app:minimize'),

  // 监听剪贴板变化
  onClipboardChange: (callback: (data: { type: string; content: string; timestamp: number }) => void) => {
    const listener = (_: any, data: any) => callback(data);
    ipcRenderer.on('clipboard:new', listener);
    return () => ipcRenderer.removeListener('clipboard:new', listener);
  },

  // 设置管理
  getSettings: () => ipcRenderer.invoke('settings:get'),
  setSetting: (key: string, value: any) => ipcRenderer.invoke('settings:set', key, value),

  // API Key 管理
  getApiKey: () => ipcRenderer.invoke('get-api-key'),
  setApiKey: (apiKey: string) => ipcRenderer.invoke('set-api-key', apiKey),

  // 获取版本信息
  getVersion: () => ipcRenderer.invoke('app:getVersion'),

  // 平台信息
  platform: process.platform,

  // 检测是否在 Electron 环境
  isElectron: true
});
