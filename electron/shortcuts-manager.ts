import { globalShortcut, BrowserWindow } from 'electron';

export class ShortcutsManager {
  private registeredShortcuts: string[] = [];
  private win: BrowserWindow | null;

  constructor(win: BrowserWindow | null) {
    this.win = win;
  }

  register(accelerator: string, callback: () => void): boolean {
    try {
      globalShortcut.register(accelerator, callback);
      this.registeredShortcuts.push(accelerator);
      console.log(`Registered shortcut: ${accelerator}`);
      return true;
    } catch (error) {
      console.error(`Failed to register shortcut: ${accelerator}`, error);
      return false;
    }
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
