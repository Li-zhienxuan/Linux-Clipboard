import { globalShortcut, BrowserWindow } from 'electron';

export class ShortcutsManager {
  private registeredShortcuts: string[] = [];
  private win: BrowserWindow | null;

  constructor(win: BrowserWindow | null) {
    this.win = win;
  }

  register(accelerator: string, callback: () => void): boolean {
    const ret = globalShortcut.register(accelerator, callback);

    if (ret) {
      this.registeredShortcuts.push(accelerator);
      console.log(`Registered shortcut: ${accelerator}`);
    } else {
      console.error(`Failed to register shortcut: ${accelerator}`);
    }

    return ret;
  }

  unregister(accelerator: string): void {
    globalShortcut.unregister(accelerator);
    this.registeredShortcuts = this.registeredShortcuts.filter(s => s !== accelerator);
  }

  unregisterAll(): void {
    globalShortcut.unregisterAll();
    this.registeredShortcuts = [];
  }

  isRegistered(accelerator: string): boolean {
    return globalShortcut.isRegistered(accelerator);
  }
}
