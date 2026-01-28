# CNB CI/CD 使用指南

## 概述

CNB (cnb.cool) 是基于 GitLab 的代码托管平台，本项目配置了完整的 CI/CD 自动化流程。

## CI/CD 流程架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      CNB CI/CD 流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  触发方式:                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Push to main │  │  Push Tag    │  │ Manual Trigger│         │
│  │   (可选)     │  │  (推荐)      │  │   (测试)      │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                   │
│         └─────────────────┴─────────────────┘                   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Stage 1: build (构建前端)                               │   │
│  │   - 安装依赖 (npm ci)                                    │   │
│  │   - 构建前端 (npm run build)                             │   │
│  │   - 缓存 node_modules                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Stage 2: package (打包 .deb)                            │   │
│  │   - 构建 Electron 应用                                    │   │
│  │   - 生成 .deb 安装包                                      │   │
│  │   - 保存构建产物                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Stage 3: release (创建 Release)                         │   │
│  │   - 生成发布信息                                          │   │
│  │   - 上传安装包到 Release                                  │   │
│  │   - 保存 Release 信息                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 触发条件

### 自动触发

1. **推送 Tag (推荐)**
   ```bash
   # 创建并推送版本标签
   git tag v0.4.0
   git push cnb v0.4.0
   ```
   - 会触发完整的 build → package → release 流程
   - 自动生成 Release 信息
   - 保存 .deb 安装包

2. **推送到 main 分支**
   ```bash
   git push cnb main
   ```
   - 只触发 build 和 package 阶段
   - 不会创建 Release

### 手动触发

在 CNB 网页端手动触发构建测试：
1. 访问: https://cnb.cool/ZhienXuan/Linux-Clipboard/-/pipelines
2. 点击 "Run pipeline" 按钮
3. 选择分支和变量
4. 点击 "Run pipeline"

## 配置文件说明

### .gitlab-ci.yml 结构

```yaml
stages:
  - build       # 构建阶段
  - package     # 打包阶段
  - release     # 发布阶段

jobs:
  build:frontend     # 前端构建任务
  package:deb        # .deb 打包任务
  release:create     # Release 创建任务
  build:manual       # 手动测试任务
```

### 环境变量

| 变量名 | 值 | 说明 |
|--------|-----|------|
| NODE_VERSION | 22 | Node.js 版本 |
| PROJECT_NAME | linux-clipboard | 项目名称 |

### 构建产物

| 阶段 | 产物 | 过期时间 |
|------|------|----------|
| build | dist/ | 1 小时 |
| package | release/*.deb | 1 天 |
| release | RELEASE_INFO_*.txt | 30 天 |

## 使用步骤

### 1. 首次配置

```bash
# 1. 克隆 CNB 仓库
git clone https://cnb.cool/ZhienXuan/Linux-Clipboard.git
cd Linux-Clipboard

# 2. 配置 CNB 远程
git remote add cnb https://cnb.cool/ZhienXuan/Linux-Clipboard.git

# 3. 推送代码
git push cnb main
```

### 2. 发布新版本

```bash
# 1. 更新版本号
npm version patch  # 或 minor, major

# 2. 本地构建测试
npm run electron:build:deb

# 3. 提交并打标签
git add .
git commit -m "chore: release version v0.4.0"
git tag v0.4.0

# 4. 推送到 CNB (触发 CI/CD)
git push cnb main
git push cnb v0.4.0
```

### 3. 监控构建

访问 CNB Pipeline 页面查看构建进度：
https://cnb.cool/ZhienXuan/Linux-Clipboard/-/pipelines

### 4. 下载安装包

构建完成后，可以从以下位置下载：
- CNB Releases: https://cnb.cool/ZhienXuan/Linux-Clipboard/-/releases
- CI/CD Artifacts: https://cnb.cool/ZhienXuan/Linux-Clipboard/-/jobs

## 故障排查

### 构建失败

1. 查看 Pipeline 日志
2. 检查 Node.js 版本是否正确
3. 验证依赖是否完整安装

### 打包失败

1. 确认 `electron-builder` 配置正确
2. 检查 `package.json` 中的版本号
3. 验证前端构建是否成功

### 推送失败

1. 检查访问权限
2. 验证 Token 是否有效
3. 确认分支名称正确

## 高级配置

### 自定义构建变量

在 CNB 项目设置中添加自定义变量：
1. 访问: Settings → CI/CD → Variables
2. 添加变量（如 `CUSTOM_VAR`）
3. 在 `.gitlab-ci.yml` 中使用 `$CUSTOM_VAR`

### 定时构建

使用 GitLab CI/CD 的 Schedules 功能：
1. 访问: CI/CD → Schedules
2. 创建新的定时任务
3. 设置 Cron 表达式

### 构建缓存

CI/CD 自动缓存 `node_modules`，加快构建速度：
- 缓存 Key: 分支名称
- 缓存路径: node_modules/

## GitHub 与 CNB 同步

### 自动同步工作流

```
┌──────────────┐
│ 本地开发     │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│ 推送到 GitHub│────▶│ GitHub Action│
│ (触发 release)│     │  (构建发布)  │
└──────────────┘     └──────┬───────┘
                            │
                            ▼
                     ┌──────────────┐
                     │ 同步到 CNB   │
                     │ (git push)   │
                     └──────────────┘
```

### 手动同步

```bash
# 推送到两个平台
git push origin main    # GitHub
git push cnb main       # CNB
```

## 最佳实践

1. **使用标签发布**: 始终使用版本标签触发 Release
2. **本地测试**: 推送前先本地构建测试
3. **版本管理**: 遵循语义化版本 (Semantic Versioning)
4. **日志监控**: 定期检查 CI/CD 日志
5. **清理产物**: 及时清理过期的构建产物

## 相关链接

- CNB 项目: https://cnb.cool/ZhienXuan/Linux-Clipboard
- GitHub 项目: https://github.com/Li-zhienxuan/Linux-Clipboard
- CI/CD 文档: https://docs.gitlab.com/ee/ci/
- CNB 帮助: https://cnb.cool/help
