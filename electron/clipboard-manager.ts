import { clipboard, BrowserWindow } from 'electron';

export class ClipboardManager {
  private lastContent: string = '';
  private pollingInterval: NodeJS.Timeout | null = null;
  private win: BrowserWindow | null;

  constructor(win: BrowserWindow | null) {
    this.win = win;
  }

  start() {
    // 每秒检查剪贴板变化
    this.pollingInterval = setInterval(() => {
      this.checkClipboard();
    }, 1000);
  }

  stop() {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
      this.pollingInterval = null;
    }
  }

  private checkClipboard() {
    if (!this.win || this.win.isDestroyed()) return;

    const formats = clipboard.availableFormats();

    // 检测图片
    if (formats.includes('image/png')) {
      const image = clipboard.readImage();
      if (!image.isEmpty()) {
        try {
          const buffer = image.toPNG();
          const base64 = `data:image/png;base64,${buffer.toString('base64')}`;

          if (base64 !== this.lastContent && base64.length < 50 * 1024 * 1024) { // 限制 50MB
            this.lastContent = base64;
            this.sendToRenderer({
              type: 'image',
              content: base64,
              timestamp: Date.now()
            });
          }
        } catch (error) {
          console.error('Error processing clipboard image:', error);
        }
      }
    }
    // 检测文本
    else if (formats.includes('text/plain')) {
      const text = clipboard.readText();
      if (text && text !== this.lastContent && text.trim().length > 0) {
        this.lastContent = text;
        this.sendToRenderer({
          type: 'text',
          content: text,
          timestamp: Date.now()
        });
      }
    }
  }

  private sendToRenderer(data: { type: string; content: string; timestamp: number }) {
    if (this.win && !this.win.isDestroyed()) {
      this.win.webContents.send('clipboard:new', data);
    }
  }

  read(): { type: string; content: string } | null {
    const formats = clipboard.availableFormats();

    if (formats.includes('image/png')) {
      const image = clipboard.readImage();
      if (!image.isEmpty()) {
        const buffer = image.toPNG();
        return {
          type: 'image',
          content: buffer.toString('base64')
        };
      }
    }

    if (formats.includes('text/plain')) {
      const text = clipboard.readText();
      if (text) {
        return {
          type: 'text',
          content: text
        };
      }
    }

    return null;
  }
}
