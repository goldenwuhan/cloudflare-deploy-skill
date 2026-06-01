#!/bin/bash
# Cloudflare Pages 部署脚本
# 用法: ./deploy.sh <project-name> <build-directory> [api-token]

set -e

PROJECT_NAME=${1:-"my-project"}
BUILD_DIR=${2:-"dist"}
API_TOKEN=${3:-$CLOUDFLARE_API_TOKEN}

echo "🚀 开始部署到 Cloudflare Pages"
echo "项目名称: $PROJECT_NAME"
echo "构建目录: $BUILD_DIR"

# 检查必要工具
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler 未安装，请先运行: npm install -g wrangler"
    exit 1
fi

# 检查 API 令牌
if [ -z "$API_TOKEN" ]; then
    echo "❌ 未设置 CLOUDFLARE_API_TOKEN 环境变量"
    echo "请运行: export CLOUDFLARE_API_TOKEN=\"your_token_here\""
    exit 1
fi

# 检查构建目录
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ 构建目录 $BUILD_DIR 不存在"
    echo "请先运行构建命令: npm run build"
    exit 1
fi

# 设置环境变量
export CLOUDFLARE_API_TOKEN="$API_TOKEN"

# 禁用代理（如果需要）
if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ]; then
    echo "⚠️  检测到代理环境变量，正在临时禁用..."
    export HTTP_PROXY=""
    export HTTPS_PROXY=""
    export NO_PROXY="*"
fi

# 部署
echo "📦 开始部署..."
wrangler pages deploy "$BUILD_DIR" --project-name "$PROJECT_NAME"

echo "✅ 部署完成！"
echo "🌐 访问地址: https://$PROJECT_NAME.pages.dev"

# 可选：设置环境变量
read -p "是否需要设置环境变量？(y/N): " setup_env
if [ "$setup_env" = "y" ] || [ "$setup_env" = "Y" ]; then
    read -p "输入环境变量名称: " env_name
    read -p "输入环境变量值: " env_value
    echo "$env_value" | wrangler pages secret put "$env_name" --project-name "$PROJECT_NAME"
    echo "✅ 环境变量 $env_name 已设置"
fi

echo "🎉 部署流程完成！"