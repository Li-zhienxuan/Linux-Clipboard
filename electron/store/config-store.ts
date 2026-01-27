import Store from 'electron-store';

interface ConfigSchema {
  autoStart: boolean;
  shortcut: string;
  geminiApiKey: string;
  theme: string;
  maxHistoryItems: number;
}

export class ConfigStore {
  private store: Store<ConfigSchema>;

  constructor() {
    this.store = new Store<ConfigSchema>({
      name: 'linux-clipboard-config',
      defaults: {
        autoStart: false,
        shortcut: 'CommandOrControl+Shift+V',
        geminiApiKey: '',
        theme: 'dark',
        maxHistoryItems: 1000
      }
    });
  }

  get<K extends keyof ConfigSchema>(key: K, defaultValue?: ConfigSchema[K]): ConfigSchema[K] {
    return this.store.get(key, defaultValue as ConfigSchema[K]) as ConfigSchema[K];
  }

  set<K extends keyof ConfigSchema>(key: K, value: ConfigSchema[K]): void {
    this.store.set(key, value);
  }

  setAny(key: string, value: any): void {
    (this.store as any).set(key, value);
  }

  getAll(): ConfigSchema {
    return this.store.store;
  }

  delete<K extends keyof ConfigSchema>(key: K): void {
    this.store.delete(key);
  }

  clear(): void {
    this.store.clear();
  }
}
