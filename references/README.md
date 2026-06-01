# Cloudflare 部署参考资料

## 官方文档

### Cloudflare Pages
- [入门指南](https://developers.cloudflare.com/pages/get-started/guide/)
- [构建配置](https://developers-pages/get-started/configuration/)
- [环境变量](https://developers.cloudflare.com/pages/configuration/environment-variables/)
- [自定义域名](https://developers.cloudflare.com/pages/configuration/custom-domains/)

### Cloudflare Workers
- [Workers 入门](https://developers.cloudflare.com/workers/get-started/guide/)
- [Wrangler 配置](https://developers.cloudflare.com/workers/wrangler/configuration/)
- [KV 存储](https://developers.cloudflare.com/workers/learning/how-kv-works/)
- [D1 数据库](https://developers.cloudflare.com/d1/get-started/)

### API 和认证
- [API 令牌创建](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [API 令牌权限](https://developers.cloudflare.com/fundamentals/api/reference/permissions/)
- [Wrangler 认证](https://developers.cloudflare.com/workers/wrangler/commands/#login)

## 常见项目类型部署

### 静态站点（HTML/CSS/JS）
```bash
# 直接部署 dist 目录
wrangler pages deploy dist --project-name my-static-site
```

### React/Vue/Angular 应用
```bash
# 1. 构建项目
npm run build  # 通常生成 dist 或 build 目录

# 2. 部署
wrangler pages deploy dist --project-name my-react-app
```

### Next.js 应用
```bash
# 1. 构建
npm run build

# 2. 部署（需要适配器）
wrangler pages deploy .next --project-name my-nextjs-app
```

### Node.js 全栈应用（使用 Workers）
```bash
# 1. 确保有 wrangler.toml 配置
# 2. 部署
wrangler deploy
```

## 故障排除指南

### 常见错误及解决方案

#### 1. "Error: The specified account does not exist"
**原因**：API 令牌权限不足或账户信息错误
**解决**：
- 检查 API 令牌权限
- 运行 `wrangler whoami` 验证账户

#### 2. "Error: Not found"
**原因**：项目名称不存在或拼写错误
**解决**：
- 运行 `wrangler pages project list` 查看现有项目
- 确保项目名称正确

#### 3. "Error: Invalid route"
**原因**：Wrangler 版本过旧
**解决**：
```bash
npm install -g wrangler@latest
```

#### 4. 部署后页面空白
**原因**：资源路径错误或构建配置问题
**解决**：
- 检查 `base` 路径配置（Vite: `vite.config.ts`，Webpack: `publicPath`）
- 确保构建输出目录正确

### 性能优化建议

1. **启用 Brotli 压缩**：Cloudflare 自动提供
2. **配置缓存头**：在 `_headers` 文件中设置
3. **使用边缘缓存**：对于动态内容
4. **优化图片**：使用 Cloudflare Images 或 Image Resizing

## 高级功能

### 预览部署
每次 Git 推送会自动创建预览部署：
- 主分支 → 生产部署
- 其他分支 → 预览部署
- Pull Request → 临时预览 URL

### 函数绑定
在 `functions/` 目录中添加服务器端逻辑：
```
functions/
├── api/
│   └── hello.js  # 访问 /api/hello
└── [[catchall]].js  # 捕获所有路由
```

### KV 绑定示例
```javascript
// 在 Pages Function 中使用 KV
export async function onRequest(context) {
  const value = await context.env.MY_KV.get("key");
  return new Response(value);
}
```

## 实用脚本

### 批量设置环境变量
```bash
#!/bin/bash
# batch-set-env.sh
PROJECT_NAME="my-project"
ENV_FILE=".env.production"

while IFS='=' read -r key value; do
  if [[ $key != \#* ]] && [[ -n $key ]]; then
    echo "设置 $key..."
    echo "$value" | wrangler pages secret put "$key" --project-name "$PROJECT_NAME"
  fi
done < "$ENV_FILE"
```

### 部署状态检查
```bash
#!/bin/bash
# check-deployment.sh
PROJECT_NAME="my-project"
echo "检查 $PROJECT_NAME 的部署状态..."
wrangler pages deployment list --project-name "$PROJECT_NAME" | head -10
```

## 社区资源

- [Awesome Cloudflare](https://github.com/irazasyed/awesome-cloudflare)
- [Cloudflare Workers 模板](https://github.com/cloudflare/worker-typescript-template)
- [Wrangler 示例](https://github.com/cloudflare/wrangler-example)

## 更新日志

- **v1.0.0** (2026-06-01): 初始版本，基于焊接参数和 otter-music 项目部署经验