import { Tray, Menu, BrowserWindow, nativeImage, app } from 'electron';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class TrayManager {
  private tray: Tray | null = null;
  private win: BrowserWindow | null;

  constructor(win: BrowserWindow | null) {
    this.win = win;
  }

  createTray() {
    // 加载托盘图标
    // 开发环境使用临时图标，生产环境使用 resources/icons/icon.png
    let iconPath: string;

    if (process.env.NODE_ENV === 'development') {
      // 开发环境：创建一个简单的图标
      iconPath = path.join(__dirname, '../resources/icons/icon.png');
    } else {
      // 生产环境
      iconPath = path.join(process.resourcesPath, 'icons/icon.png');
    }

    try {
      const icon = nativeImage.createFromPath(iconPath);
      // 确保图标不为空
      if (icon.isEmpty()) {
        console.warn('Tray icon is empty, using default icon');
        // 使用默认的 Electron 图标
        this.tray = new Tray(nativeImage.createEmpty());
      } else {
        this.tray = new Tray(icon);
      }
    } catch (error) {
      console.error('Error loading tray icon:', error);
      // 如果图标加载失败，使用空图标
      this.tray = new Tray(nativeImage.createEmpty());
    }

    const contextMenu = Menu.buildFromTemplate([
      {
        label: 'Show/Hide',
        click: () => {
          this.toggleWindow();
        }
      },
      { type: 'separator' },
      {
        label: 'Settings',
        click: () => {
          this.showWindow();
        }
      },
      {
        label: 'Quit',
        click: () => {
          app.isQuitting = true;
          app.quit();
        }
      }
    ]);

    this.tray.setContextMenu(contextMenu);
    this.tray.setToolTip('Smart Clipboard Pro');

    // 双击托盘图标显示窗口
    this.tray.on('double-click', () => {
      this.showWindow();
    });
  }

  private toggleWindow() {
    if (this.win && !this.win.isDestroyed()) {
      if (this.win.isVisible()) {
        this.win.hide();
      } else {
        this.win.show();
        this.win.focus();
      }
    }
  }

  private showWindow() {
    if (this.win && !this.win.isDestroyed()) {
      this.win.show();
      this.win.focus();
    }
  }
}
