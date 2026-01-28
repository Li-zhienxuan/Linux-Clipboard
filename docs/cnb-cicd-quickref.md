# CNB CI/CD 快速参考

## 触发方式速查

| 操作 | 命令 | 触发阶段 | 适用场景 |
|------|------|----------|----------|
| **完整发布** | `git push cnb v0.4.0` | build → package → release | 生产环境发布 |
| **测试构建** | `git push cnb main` | build → package | 测试代码构建 |
| **手动触发** | 网页端点击 "Run pipeline" | 可选阶段 | 紧急修复/调试 |

## 完整发布流程

```bash
# 1. 更新版本号
npm version patch   # v0.3.7 → v0.3.8
npm version minor   # v0.3.7 → v0.4.0
npm version major   # v0.3.7 → v1.0.0

# 2. 本地测试
npm run electron:build:deb

# 3. 提交代码
git add .
git commit -m "chore: release version v0.4.0"

# 4. 创建标签
git tag v0.4.0

# 5. 推送到 CNB (触发 CI/CD)
git push cnb main
git push cnb v0.4.0

# 6. 查看构建进度
# 访问: https://cnb.cool/ZhienXuan/Linux-Clipboard/-/pipelines
```

## Pipeline 状态

| 状态 | 图标 | 说明 |
|------|------|------|
| pending | ⏳ | 等待执行 |
| running | ▶️ | 正在构建 |
| success | ✅ | 构建成功 |
| failed | ❌ | 构建失败 |
| skipped | ⏭️ | 已跳过 |
| manual | 🔧 | 等待手动触发 |

## 阶段说明

### Stage 1: build (构建)
- 安装依赖: `npm ci`
- 构建前端: `npm run build`
- 保存产物: `dist/`
- 耗时: ~2-3 分钟

### Stage 2: package (打包)
- 构建 Electron: `npm run electron:build:deb`
- 生成安装包: `release/*.deb`
- 保存产物: `release/*.deb`
- 耗时: ~3-5 分钟

### Stage 3: release (发布)
- 生成发布信息: `RELEASE_INFO_*.txt`
- 上传安装包
- 创建 Release
- 耗时: ~1 分钟

## 常用链接

| 功能 | 链接 |
|------|------|
| Pipelines | https://cnb.cool/ZhienXuan/Linux-Clipboard/-/pipelines |
| Jobs | https://cnb.cool/ZhienXuan/Linux-Clipboard/-/jobs |
| Releases | https://cnb.cool/ZhienXuan/Linux-Clipboard/-/releases |
| Packages | https://cnb.cool/ZhienXuan/Linux-Clipboard/-/packages |

## 故障排查

### 构建失败
```bash
# 查看最近的失败任务
git log --oneline -5

# 重新构建
git push cnb main --force-with-lease
```

### 清理缓存
```bash
# 在 CNB 网页端清理缓存
# Settings → CI/CD → Pipelines → Clear runner caches
```

## 环境变量

| 变量 | 值 | 用途 |
|------|-----|------|
| `$CI_COMMIT_TAG` | `v0.4.0` | 当前标签 |
| `$CI_COMMIT_SHORT_SHA` | `a1b2c3d` | 短哈希 |
| `$CI_COMMIT_REF_NAME` | `main` | 分支名 |
| `$CI_PIPELINE_URL` | - | Pipeline 链接 |

## 版本策略

- **主版本 (Major)**: 不兼容的 API 变更
- **次版本 (Minor)**: 向下兼容的功能新增
- **修订版 (Patch)**: 向下兼容的问题修正

示例:
```
v1.0.0 → v1.0.1 (Patch: Bug 修复)
v1.0.1 → v1.1.0 (Minor: 新功能)
v1.1.0 → v2.0.0 (Major: 重大变更)
```

## 双平台同步

### 推送到两个平台
```bash
# 同时推送到 GitHub 和 CNB
git push origin main    # GitHub
git push cnb main       # CNB
```

### 标签同步
```bash
# 推送标签到两个平台
git push origin v0.4.0  # GitHub (触发 GitHub Actions)
git push cnb v0.4.0     # CNB (触发 CNB CI/CD)
```

## 快捷命令

```bash
# 查看当前版本
grep '"version"' package.json | cut -d'"' -f4

# 查看最新标签
git describe --tags --abbrev=0

# 删除本地标签
git tag -d v0.4.0

# 删除远程标签
git push cnb :refs/tags/v0.4.0

# 查看远程仓库
git remote -v
```

## 注意事项

⚠️ **重要提示:**
1. 推送前确保本地已测试通过
2. 版本号必须遵循 `v*.*.*` 格式
3. Tag 名称需与 package.json 版本一致
4. CNB Token 需有 write 权限
5. 构建失败时检查日志并修复

## 获取帮助

- CNB 文档: https://cnb.cool/help
- GitLab CI/CD: https://docs.gitlab.com/ee/ci/
- 项目 Issues: https://cnb.cool/ZhienXuan/Linux-Clipboard/-/issues
