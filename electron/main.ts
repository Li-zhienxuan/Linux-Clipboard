import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { ClipboardManager } from './clipboard-manager';
import { TrayManager } from './tray-manager';
import { ShortcutsManager } from './shortcuts-manager';
import { ConfigStore } from './store/config-store';
import { SecureConfigStore } from './store/secure-store';

// 处理 root 用户运行时的沙箱问题
if (process.getuid && process.getuid() === 0) {
  app.commandLine.appendSwitch('no-sandbox');
  console.warn('Running as root: --no-sandbox flag enabled');
}

let mainWindow: BrowserWindow | null = null;
const isDev = !app.isPackaged; // 使用 Electron 的打包状态检测，而不是环境变量

const getBasePath = () => {
  // 开发环境：使用当前工作目录
  // 生产环境：app.getAppPath() 返回 app.asar 路径，Electron 可以直接从中读取文件
  return isDev ? process.cwd() : app.getAppPath();
};

// 配置存储
const store = new ConfigStore();
const secureStore = new SecureConfigStore();

// 自动迁移：从旧配置迁移 API Key 到安全存储
function migrateApiKeyToSecureStore() {
  try {
    // 检查旧配置中是否有 API Key
    const oldConfigPath = path.join(app.getPath('userData'), 'linux-clipboard-config.json');
    const fs = require('fs');

    if (fs.existsSync(oldConfigPath)) {
      // 读取旧配置
      const oldConfig = JSON.parse(fs.readFileSync(oldConfigPath, 'utf-8'));

      // 如果旧配置中有 geminiApiKey 且安全存储中还没有
      if (oldConfig.geminiApiKey && !secureStore.getApiKey()) {
        console.log('🔄 Migrating API key from plaintext config to secure storage...');
        secureStore.setApiKey(oldConfig.geminiApiKey);

        // 从旧配置中删除明文 API Key
        delete oldConfig.geminiApiKey;
        fs.writeFileSync(oldConfigPath, JSON.stringify(oldConfig, null, 2));
        console.log('✓ API key migration completed successfully');
      }
    }
  } catch (error) {
    console.error('Migration failed:', error);
    // 迁移失败不影响应用启动
  }
}

// 执行迁移
migrateApiKeyToSecureStore();

// 创建窗口
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    show: false, // 先隐藏，等加载完成后再显示
    frame: true,
    title: 'Linux-Clipboard',
    autoHideMenuBar: true, // 隐藏菜单栏
    webPreferences: {
      preload: path.join(getBasePath(), 'dist-electron', 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    }
  });

  // 移除默认菜单
  mainWindow.setMenuBarVisibility(false);

  // 开发环境加载 Vite 服务器，生产环境加载打包文件
  if (isDev) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(getBasePath(), 'dist', 'index.html'));
  }

  // 页面加载完成后显示窗口
  mainWindow.once('ready-to-show', () => {
    mainWindow?.show();
  });

  // 窗口关闭时隐藏到托盘
  mainWindow.on('close', (e) => {
    if (!(app as any).isQuitting) {
      e.preventDefault();
      mainWindow?.hide();
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// IPC 处理器
function setupIpc() {
  // 剪贴板读取
  ipcMain.handle('clipboard:read', async () => {
    return clipboardManager?.read() || null;
  });

  // 切换窗口显示/隐藏
  ipcMain.on('app:toggle', () => {
    if (mainWindow?.isVisible()) {
      mainWindow.hide();
    } else {
      mainWindow?.show();
      mainWindow?.focus();
    }
  });

  // 获取所有设置
  ipcMain.handle('settings:get', () => store.getAll());

  // 设置单个配置项
  ipcMain.handle('settings:set', (_, key: string, value: any) => {
    store.setAny(key, value);

    // 特殊处理开机自启
    if (key === 'autoStart') {
      app.setLoginItemSettings({
        openAtLogin: value,
        openAsHidden: true,
        name: 'Linux-Clipboard'
      });
    }
  });

  // 获取 API Key (使用安全存储)
  ipcMain.handle('get-api-key', () => {
    return secureStore.getApiKey();
  });

  // 设置 API Key (使用安全存储)
  ipcMain.handle('set-api-key', (_, apiKey: string) => {
    secureStore.setApiKey(apiKey);
  });

  // 最小化到托盘
  ipcMain.on('app:minimize', () => {
    mainWindow?.hide();
  });
}

// 管理器初始化
let clipboardManager: ClipboardManager | null = null;
let trayManager: TrayManager | null = null;
let shortcutsManager: ShortcutsManager | null = null;

app.whenReady().then(() => {
  createWindow();
  setupIpc();

  // 初始化剪贴板监听
  clipboardManager = new ClipboardManager(mainWindow);
  clipboardManager.start();

  // 初始化系统托盘
  trayManager = new TrayManager(mainWindow);
  trayManager.createTray();

  // 初始化全局快捷键
  shortcutsManager = new ShortcutsManager(mainWindow);
  const shortcut = store.get('shortcut', 'CommandOrControl+Shift+V');
  shortcutsManager.register(shortcut, () => {
    if (mainWindow?.isVisible()) {
      mainWindow.hide();
    } else {
      mainWindow?.show();
      mainWindow?.focus();
    }
  });

  // 开机自启
  if (store.get('autoStart', false)) {
    app.setLoginItemSettings({
      openAtLogin: true,
      openAsHidden: true,
      name: 'Linux-Clipboard'
    });
  }

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  // 停止剪贴板监听
  clipboardManager?.stop();
  // 注销所有快捷键
  shortcutsManager?.unregisterAll();
});

// 仅用于开发时热重载
if (isDev) {
  app.on('will-quit', () => {
    shortcutsManager?.unregisterAll();
  });
}
