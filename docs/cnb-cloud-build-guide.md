# CNB 云原生构建使用指南

## 概述

CNB (cnb.cool) 云原生构建基于 Docker 生态，提供声明式的 CI/CD 能力。

## 核心特性

- **声明式语法**: 可编程、易分享的 YAML 配置
- **易管理**: 与代码同源管理
- **云原生**: 资源池化，屏蔽基础设施复杂性
- **高性能**: 支持最多 64 核 CPU，读秒克隆，缓存并发

## 配置文件结构

```yaml
# 分支名
main:
  # 事件名 (push, pull_request, manual)
  push:
    - name: 流水线名称
      docker:
        image: node:22          # Docker 镜像
        volumes:                # 缓存配置
          - node_modules:copy-on-write
      stages:                   # 任务序列
        - name: 任务名称
          script: 命令
      failStages:              # 失败处理（可选）
        - name: 失败通知
          script: 命令
```

## 支持的事件

| 事件 | 触发时机 | 用途 |
|------|----------|------|
| `push` | 推送代码到分支 | 持续集成 |
| `pull_request` | 创建/更新 PR | 代码检查 |
| `manual` | 手动触发 | 测试构建 |

## 项目配置说明

### 1. main 分支推送 - 前端构建

```yaml
main:
  push:
    - name: 前端构建
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 安装依赖
          script: npm ci
        - name: 构建前端
          script: npm run build
```

**触发方式**:
```bash
git push cnb main
```

**执行任务**:
- ✅ 安装依赖
- ✅ 构建前端

### 2. tags 推送 - 完整发布流程

```yaml
tags:
  push:
    - name: 构建 DEB 安装包
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 安装依赖
          script: npm ci
        - name: 构建前端
          script: npm run build
        - name: 安装构建工具
          script: |
            apt-get update
            apt-get install -y fakeroot binutils
        - name: 构建 Electron 应用
          script: npm run electron:build:deb
        - name: 显示构建结果
          script: ls -lh release/
```

**触发方式**:
```bash
git tag v0.4.0
git push cnb v0.4.0
```

**执行任务**:
- ✅ 安装依赖
- ✅ 构建前端
- ✅ 安装构建工具
- ✅ 构建 Electron 应用
- ✅ 显示构建结果

### 3. PR 检查 - 代码质量

```yaml
main:
  pull_request:
    - name: 代码质量检查
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 安装依赖
          script: npm ci
        - name: 构建检查
          script: npm run build
```

**触发方式**: 在 CNB 网页端创建 PR/MR

### 4. 手动触发 - 测试构建

```yaml
$:
  manual:
    - name: 快速测试
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 测试构建
          script: |
            npm ci
            npm run build
```

**触发方式**: 在 CNB 云原生构建页面手动触发

## 缓存配置

### copy-on-write 缓存

```yaml
docker:
  image: node:22
  volumes:
    - node_modules:copy-on-write  # 写时复制，支持并发
```

**优势**:
- 写时复制，避免并发冲突
- 多个 Pipeline 可以同时读取缓存
- 加快构建速度

## 高级配置

### 自定义 CPU 资源

```yaml
- name: 高性能构建
  runner:
    cpus: 64  # 最高 64 核
  docker:
    image: node:22
  stages:
    - script: npm run build
```

### 使用插件

```yaml
- name: 使用插件
  stages:
    - name: hello world
      image: cnbcool/hello-world
```

## 发布流程

### 完整发布步骤

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

# 5. 推送到 CNB (触发完整 CI/CD)
git push cnb main
git push cnb v0.4.0
```

### 查看构建结果

访问 CNB 云原生构建页面：
https://cnb.cool/ZhienXuan/Linux-Clipboard/-/cloud-native-build

点击对应的构建记录，查看详细日志。

## 故障排查

### 构建失败

1. 查看构建日志，定位失败阶段
2. 本地复现问题
3. 修复后重新推送

### 缓存问题

```bash
# 清理本地缓存
rm -rf node_modules package-lock.json
npm ci
```

### 权限问题

确保 CNB Token 有以下权限：
- `read_repository`
- `write_repository`

## 最佳实践

1. **使用标签发布**: 始终使用版本标签触发完整构建
2. **本地测试**: 推送前先本地构建测试
3. **版本管理**: 遵循语义化版本
4. **缓存优化**: 使用 `copy-on-write` 加快构建
5. **日志监控**: 定期检查构建日志

## 相关链接

- CNB 项目: https://cnb.cool/ZhienXuan/Linux-Clipboard
- 云原生构建文档: https://cnb.cool/docs/cloud-native-build
- GitHub 项目: https://github.com/Li-zhienxuan/Linux-Clipboard

## 配置示例参考

完整配置文件: [.cnb.yml](../.cnb.yml)

```yaml
# main 分支推送触发 - 前端构建
main:
  push:
    - name: 前端构建
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 安装依赖
          script: npm ci
        - name: 构建前端
          script: npm run build

# tags 推送触发 - 完整发布流程
tags:
  push:
    - name: 构建 DEB 安装包
      docker:
        image: node:22
        volumes:
          - node_modules:copy-on-write
      stages:
        - name: 安装依赖
          script: npm ci
        - name: 构建前端
          script: npm run build
        - name: 安装构建工具
          script: |
            apt-get update
            apt-get install -y fakeroot binutils
        - name: 构建 Electron 应用
          script: npm run electron:build:deb
        - name: 显示构建结果
          script: ls -lh release/
```
