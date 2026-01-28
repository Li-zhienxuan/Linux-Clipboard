# Linux-Clipboard 修复记录

## 版本 v0.3.4 - 问题修复记录

### 问题总结
本版本主要修复了 **ES Module 与 CommonJS 兼容性问题**，该问题导致应用在运行时抛出 `require is not defined` 错误。

---

## 问题 #1: SecureStore 中的 require() 错误

### 发现时间
2026-01-28 10:06:25 (CST, UTC+8)

### 错误信息
```
ReferenceError: require is not defined in ES module scope, you can use import instead
This file is being treated as an ES module because it has a '.js' file extension and '/Code/Dev/Linux-Clipboard/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.
    at SecureStore.getMachineId (file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:15893:16)
    at new SecureStore (file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:15885:28)
    at new SecureConfigStore (file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:15941:24)
    at file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:15989:21
```

### 问题分析

#### 根本原因
1. 项目在 `package.json` 中配置了 `"type": "module"`，启用了 ES Module 模式
2. 在 `electron/store/secure-store.ts` 文件的 `getMachineId()` 方法中使用了 `const os = require('os')`
3. ES Module 不支持 `require()` 语法，必须使用 `import` 语句

#### 影响范围
- 应用启动时立即崩溃
- 所有依赖 `SecureStore` 的功能无法使用
- API Key 加密存储功能受影响

### 解决方案

#### 修改文件
`electron/store/secure-store.ts`

#### 修改步骤

1. **在文件顶部添加导入语句**:
   ```typescript
   import os from 'os';
   ```

2. **删除函数内的 require 调用**:
   ```typescript
   // 修改前
   private getMachineId(): string {
     const os = require('os');  // ❌ 错误
     const id = `${os.hostname()}-${os.userInfo().username}-${os.platform()}`;
     return id;
   }

   // 修改后
   private getMachineId(): string {
     const id = `${os.hostname()}-${os.userInfo().username}-${os.platform()}`;
     return id;
   }
   ```

#### 验证步骤
1. 重新构建: `npm run build`
2. 运行测试: `npm run electron:dev`
3. 观察是否还有 `require is not defined` 错误

### 修复结果
✓ 问题已解决，`getMachineId()` 方法正常工作

---

## 问题 #2: Main Process 中的 require() 错误

### 发现时间
2026-01-28 10:10:10 (CST, UTC+8)

### 错误信息
```
Migration failed: ReferenceError: require is not defined
    at migrateApiKeyToSecureStore (file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:15992:17)
    at file:///Code/Dev/Linux-Clipboard/dist-electron/main.js:16007:1
```

### 问题分析

#### 根本原因
在修复第一个问题后，发现 `electron/main.ts` 中的 `migrateApiKeyToSecureStore()` 函数也使用了 `require('fs')`。

#### 影响范围
- API Key 迁移功能失败
- 虽然不影响应用启动，但会在控制台输出错误信息

### 解决方案

#### 修改文件
`electron/main.ts`

#### 修改步骤

1. **在文件顶部添加导入语句**:
   ```typescript
   import fs from 'fs';
   ```

2. **删除函数内的 require 调用**:
   ```typescript
   // 修改前
   function migrateApiKeyToSecureStore() {
     try {
       const oldConfigPath = path.join(app.getPath('userData'), 'linux-clipboard-config.json');
       const fs = require('fs');  // ❌ 错误
       if (fs.existsSync(oldConfigPath)) {
         // ...
       }
     } catch (error) {
       console.error('Migration failed:', error);
     }
   }

   // 修改后
   function migrateApiKeyToSecureStore() {
     try {
       const oldConfigPath = path.join(app.getPath('userData'), 'linux-clipboard-config.json');
       if (fs.existsSync(oldConfigPath)) {
         // ...
       }
     } catch (error) {
       console.error('Migration failed:', error);
     }
   }
   ```

### 修复结果
✓ 问题已解决，迁移功能正常工作

---

## 全局检查

为了确保没有遗漏其他 `require()` 调用，进行了全局搜索：

```bash
grep -rn "require(" electron/**/*.ts
```

**结果**: 无匹配项，所有问题已修复

---

## 修复总结

### 修改的文件
1. `electron/store/secure-store.ts`
   - 添加: `import os from 'os';`
   - 删除: `const os = require('os');`

2. `electron/main.ts`
   - 添加: `import fs from 'fs';`
   - 删除: `const fs = require('fs');`

### 修复前后对比

#### 修复前
- ✗ 应用启动失败
- ✗ 抛出 `require is not defined` 错误
- ✗ 功能完全不可用

#### 修复后
- ✓ 应用正常启动
- ✓ 安全存储正常工作
- ✓ API Key 迁移成功
- ✓ 快捷键注册成功
- ✓ 无 JavaScript 错误

### 经验教训

#### 为什么会出现这个问题？
1. 项目从 CommonJS 迁移到 ES Module 时，没有完全清理所有的 `require()` 调用
2. TypeScript 编译时不会检测运行时的 `require()` 错误
3. 这些代码路径在之前的版本中可能没有被执行到

#### 如何预防类似问题？
1. **使用 ESLint 规则**: 配置 `no-restricted-syntax` 规则禁止 `require()`
   ```json
   {
     "rules": {
       "no-restricted-syntax": [
         "error",
         {
           "selector": "CallExpression[callee.name='require']",
           "message": "Use import instead of require"
         }
       ]
     }
   }
   ```

2. **TypeScript 配置**: 确保 `tsconfig.json` 中的 `module` 设置为 `"ESNext"` 或 `"NodeNext"`

3. **代码审查**: 在合并代码前检查是否有新增的 `require()` 调用

4. **自动化测试**: 添加启动测试确保应用能正常初始化

#### 检测方法
```bash
# 搜索所有 require() 调用
grep -rn "require(" electron/**/*.ts

# 或使用 ripgrep（更精确）
rg "require\(" --type ts electron/
```

---

## 相关资源

### ES Module vs CommonJS
- [Node.js ES Modules](https://nodejs.org/api/esm.html)
- [MDN: import](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import)
- [TypeScript: Module Resolution](https://www.typescriptlang.org/docs/handbook/modules/theory.html#module-resolution)

### 迁移指南
- [Moving from CommonJS to ES Modules](https://nodejs.org/api/esm.html#commonjs-namespaces)
- [TypeScript: ESM Migration](https://www.typescriptlang.org/docs/handbook/modules/reference.html#module-commonjs)

---

## 历史修复记录

### v0.3.4 (2026-01-28)
- 修复 ES Module 兼容性问题
- 移除所有 `require()` 调用，替换为 `import` 语句
- 涉及文件: `electron/store/secure-store.ts`, `electron/main.ts`

### v0.3.3 及更早版本
- 详见各版本的发布说明

---

**文档维护**: 本文档记录了所有的 bug 修复和故障排查过程
**最后更新**: 2026-01-28 10:13:51 (CST, UTC+8)
**维护者**: Claude Code
