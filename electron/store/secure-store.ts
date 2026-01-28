import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from 'crypto';
import Store from 'electron-store';
import { app } from 'electron';
import { chmodSync } from 'fs';
import os from 'os';
import path from 'path';

/**
 * 安全存储类 - 使用 AES-256-GCM 加密敏感数据
 * 密钥基于机器 ID，确保加密数据与机器绑定
 */
export class SecureStore {
  private readonly algorithm = 'aes-256-gcm';
  private readonly keyLength = 32;
  private key: Buffer;

  constructor() {
    // 使用机器 ID 和应用名生成加密密钥
    const machineId = this.getMachineId();
    this.key = scryptSync(machineId, 'linux-clipboard-salt', this.keyLength);
  }

  /**
   * 获取机器唯一标识符
   * 结合多个系统属性生成稳定的机器 ID
   */
  private getMachineId(): string {
    // 使用主机名、用户名和平台生成机器 ID
    const id = `${os.hostname()}-${os.userInfo().username}-${os.platform()}`;
    return id;
  }

  /**
   * 加密字符串
   */
  encrypt(text: string): string {
    if (!text) return '';

    const iv = randomBytes(16);
    const cipher = createCipheriv(this.algorithm, this.key, iv);

    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    const authTag = cipher.getAuthTag();

    // 格式: iv:authTag:encrypted
    return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`;
  }

  /**
   * 解密字符串
   */
  decrypt(encryptedData: string): string {
    if (!encryptedData) return '';

    try {
      const parts = encryptedData.split(':');
      if (parts.length !== 3) {
        throw new Error('Invalid encrypted data format');
      }

      const iv = Buffer.from(parts[0], 'hex');
      const authTag = Buffer.from(parts[1], 'hex');
      const encrypted = parts[2];

      const decipher = createDecipheriv(this.algorithm, this.key, iv);
      decipher.setAuthTag(authTag);

      let decrypted = decipher.update(encrypted, 'hex', 'utf8');
      decrypted += decipher.final('utf8');

      return decrypted;
    } catch (error) {
      console.error('Decryption failed:', error);
      return '';
    }
  }
}

interface SecureConfigSchema {
  geminiApiKey: string; // 加密存储
}

/**
 * 安全配置存储
 * 敏感数据加密后存储，并确保文件权限正确
 */
export class SecureConfigStore {
  private store: Store<SecureConfigSchema>;
  private secureStore: SecureStore;

  constructor() {
    this.store = new Store<SecureConfigSchema>({
      name: 'linux-clipboard-secure',
      defaults: {
        geminiApiKey: ''
      }
    });

    this.secureStore = new SecureStore();

    // 确保配置文件权限为 600 (只有所有者可读写)
    this.ensureSecurePermissions();
  }

  /**
   * 确保配置文件具有安全的权限
   */
  private ensureSecurePermissions(): void {
    try {
      const configPath = this.store.path;
      chmodSync(configPath, 0o600); // rw------- (600)
      console.log(`✓ Secure permissions set for: ${configPath}`);
    } catch (error) {
      console.error('Failed to set secure permissions:', error);
    }
  }

  /**
   * 获取 API Key (自动解密)
   */
  getApiKey(): string {
    const encrypted = this.store.get('geminiApiKey');
    if (!encrypted) return '';
    return this.secureStore.decrypt(encrypted);
  }

  /**
   * 设置 API Key (自动加密)
   */
  setApiKey(apiKey: string): void {
    const encrypted = this.secureStore.encrypt(apiKey);
    this.store.set('geminiApiKey', encrypted);
    this.ensureSecurePermissions(); // 每次写入后确保权限正确
  }

  /**
   * 删除 API Key
   */
  deleteApiKey(): void {
    this.store.delete('geminiApiKey');
  }
}
