import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { ClipboardManager } from './clipboard-manager';
import { TrayManager } from './tray-manager';
import { ShortcutsManager } from './shortcuts-manager';
import { ConfigStore } from './store/config-store';

let mainWindow: BrowserWindow | null = null;
const isDev = process.env.NODE_ENV !== 'production';

// 获取资源路径
const getResourcesPath = () => {
  if (isDev) {
    return process.cwd(); // 开发环境使用当前目录
  }
  // 生产环境：electron-builder 打包后，app.getAppPath() 指向 asar 文件
  return path.join(process.resourcesPath || app.getAppPath(), 'app.asar.unpacked');
};

const getBasePath = () => {
  const resourcesPath = getResourcesPath();
  return isDev ? resourcesPath : path.dirname(app.getAppPath());
};

// 配置存储
const store = new ConfigStore();

// 创建窗口
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    show: false, // 初始隐藏，通过托盘/快捷键显示
    frame: true,
    title: 'Linux-Clipboard',
    webPreferences: {
      preload: path.join(getBasePath(), 'dist-electron', 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    }
  });

  // 开发环境加载 Vite 服务器，生产环境加载打包文件
  if (isDev) {
    mainWindow.loadURL('http://localhost:5173');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(getBasePath(), 'dist', 'index.html'));
  }

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

  // 获取 API Key
  ipcMain.handle('get-api-key', () => {
    return store.get('geminiApiKey', '');
  });

  // 设置 API Key
  ipcMain.handle('set-api-key', (_, apiKey: string) => {
    store.set('geminiApiKey', apiKey);
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
