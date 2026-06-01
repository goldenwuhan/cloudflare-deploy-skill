---
name: cloudflare-deploy
description: 部署项目到 Cloudflare Pages 或 Workers 的完整指南。包括认证、构建、部署、环境变量设置、KV 绑定等。
version: 1.0.0
author: WorkBuddy
tags: [cloudflare, pages, workers, deployment, wrangler]
category: deployment
triggers:
  - "部署到 Cloudflare"
  - "CF Pages 部署"
  - "Cloudflare Workers 部署"
  - "wrangler 部署"
  - "Cloudflare 部署"
---

# Cloudflare 部署技能

本技能提供将 Web 项目部署到 Cloudflare Pages 或 Workers 的完整流程，基于两次实际部署经验（焊接参数管理应用和 otter-music 音乐应用）总结而成。

## 前置条件

1. **Cloudflare 账户**：拥有 Cloudflare 账户（免费即可）
2. **API 令牌**：在 Cloudflare Dashboard → My Profile → API Tokens 中创建
   - 需要权限：Cloudflare Pages: Edit, Workers: Edit, KV: Edit
3. **Node.js**：已安装 Node.js（推荐 v18+）
4. **Wrangler CLI**：全局安装 `npm install -g wrangler`
5. **项目代码**：已准备好的 Web 项目（支持静态站点或 Node.js 应用）

## 部署流程

### 步骤 1：设置 Cloudflare API 令牌

```bash
# 设置环境变量（推荐）
export CLOUDFLARE_API_TOKEN="your_api_token_here"

# 或者使用交互式登录
wrangler login
```

**网络问题解决**：
如果遇到超时或代理问题，可以禁用代理：
```bash
export HTTP_PROXY=""
export HTTPS_PROXY=""
export NO_PROXY="*"
```

### 步骤 2：项目准备

确保项目可以构建：
```bash
# 安装依赖
npm install

# 构建项目（根据项目类型调整命令）
npm run build  # 通常生成 dist 或 build 目录
```

### 步骤 3：创建 Cloudflare Pages 项目

```bash
# 创建新项目
wrangler pages project create your-project-name --production-branch main

# 或者直接部署（会自动创建项目）
wrangler pages deploy dist --project-name your-project-name
```

### 步骤 4：部署静态文件

```bash
# 部署到 Cloudflare Pages
wrangler pages deploy dist --project-name your-project-name

# 部署到 Workers（适用于全栈应用）
wrangler deploy
```

### 步骤 5：设置环境变量

```bash
# 设置单个秘密变量
echo "your_secret_value" | wrangler pages secret put SECRET_NAME --project-name your-project-name

# 批量设置（通过 .env 文件）
wrangler pages secret put SECRET_NAME --project-name your-project-name < .env
```

### 步骤 6：KV 命名空间绑定（可选）

如果应用需要键值存储：
```bash
# 创建 KV 命名空间
wrangler kv namespace create "MY_KV"

# 绑定到 Pages 项目（需在 Dashboard 手动操作）
# 1. 进入 Cloudflare Dashboard → Workers & Pages → 你的项目
# 2. 设置 → 函数 → KV 命名空间绑定
# 3. 添加绑定：变量名 + KV 命名空间
```

## 常见问题解决

### 1. Wrangler 超时/网络错误
**原因**：代理环境变量干扰
**解决**：
```bash
# 临时禁用代理
export HTTP_PROXY=""
export HTTPS_PROXY=""
export NO_PROXY="*"

# 或者设置正确的代理
export HTTP_PROXY="http://proxy-server:port"
export HTTPS_PROXY="http://proxy-server:port"
```

### 2. 构建失败
**检查项**：
- 确保 `package.json` 中有正确的 build 脚本
- 检查 Node.js 版本兼容性
- 查看构建日志中的具体错误

### 3. 部署后环境变量不生效
**解决**：
- 确保变量已添加到正确的环境（Production/Preview）
- 重新部署以应用更改
- 检查变量名拼写

### 4. KV 绑定问题
**确保**：
- KV 命名空间名称与代码中使用的完全一致
- 绑定变量名正确
- 重新部署后绑定才生效

## 实际项目示例

### 示例 1：焊接参数管理应用（React + Cloudflare Pages + D1）
```bash
# 1. 克隆并进入项目
git clone https://github.com/user/welding-params.git
cd welding-params

# 2. 安装依赖并构建
npm install
npm run build

# 3. 设置 API 令牌
export CLOUDFLARE_API_TOKEN="cfut_..."

# 4. 创建 D1 数据库（可选）
wrangler d1 create welding-params-db

# 5. 部署
wrangler pages deploy dist --project-name welding-params

# 6. 设置环境变量
echo "database_id" | wrangler pages secret put D1_DATABASE_ID --project-name welding-params
```

### 示例 2：otter-music 音乐应用（React + Vite + Capacitor）
```bash
# 1. 克隆项目
git clone https://github.com/goldenwuhan/otter-music.git
cd otter-music

# 2. 安装依赖并构建
npm install
npm run build

# 3. 部署到 Pages
wrangler pages deploy dist --project-name otter-music

# 4. 设置管理员密码
echo "Yy83774676" | wrangler pages secret put PASSWORD --project-name otter-music

# 5. 创建 KV 命名空间（用于数据同步）
wrangler kv namespace create "oh_file_url"

# 6. 在 Dashboard 绑定 KV（手动步骤）
```

## 高级配置

### 自定义域名
1. 在 Cloudflare Dashboard → Workers & Pages → 你的项目
2. 设置 → 自定义域名 → 添加域名
3. 配置 DNS 记录（CNAME 指向 *.pages.dev）

### 自动部署（Git 集成）
1. 在创建 Pages 项目时连接 GitHub/GitLab 仓库
2. 每次推送代码自动构建部署
3. 支持预览部署（Pull Request 环境）

### 性能优化
```bash
# 启用 Auto Minify
wrangler pages deployment tail --project-name your-project-name

# 配置边缘缓存
# 在 wrangler.toml 中添加：
# [site]
# bucket = "./dist"
```

## 命令速查表

| 操作 | 命令 |
|------|------|
| 登录 Cloudflare | `wrangler login` |
| 查看账户信息 | `wrangler whoami` |
| 列出 Pages 项目 | `wrangler pages project list` |
| 创建 Pages 项目 | `wrangler pages project create <name>` |
| 部署静态文件 | `wrangler pages deploy <directory> --project-name <name>` |
| 设置秘密变量 | `echo "value" \| wrangler pages secret put <key> --project-name <name>` |
| 列出秘密变量 | `wrangler pages secret list --project-name <name>` |
| 创建 KV 命名空间 | `wrangler kv namespace create "<name>"` |
| 列出 KV 命名空间 | `wrangler kv namespace list` |
| 部署 Workers | `wrangler deploy` |

## 参考资料

- [Cloudflare Pages 文档](https://developers.cloudflare.com/pages/)
- [Wrangler CLI 文档](https://developers.cloudflare.com/workers/wrangler/)
- [Cloudflare API 令牌管理](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [KV 命名空间文档](https://developers.cloudflare.com/kv/)

## 贡献与改进

本技能基于实际部署经验持续更新。如发现问题或有改进建议，请更新 SKILL.md 文件。