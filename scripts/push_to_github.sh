#!/bin/bash
# ============================================================
# PixelVerse 一键推送到 GitHub 脚本
# 用法: ./scripts/push_to_github.sh <你的GitHub用户名>
# ============================================================
set -e

if [ -z "$1" ]; then
    echo "用法: $0 <你的GitHub用户名>"
    echo "示例: $0 myusername"
    exit 1
fi

USERNAME="$1"
REPO_URL="https://github.com/${USERNAME}/PixelVerse.git"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$PROJECT_DIR"

echo "=========================================="
echo "  PixelVerse GitHub 推送脚本"
echo "=========================================="
echo ""
echo "目标仓库: $REPO_URL"
echo ""

# 确保 git 已初始化
if [ ! -d ".git" ]; then
    echo "[1/4] 初始化 git 仓库..."
    git init
    git config user.email "pixelverse@dev.local"
    git config user.name "PixelVerse Dev"
else
    echo "[1/4] Git 仓库已初始化"
fi

# 移除旧的 remote（如果有）
git remote remove origin 2>/dev/null || true

echo "[2/4] 添加远程仓库..."
git remote add origin "$REPO_URL"

echo "[3/4] 提交所有文件..."
git add -A
git commit -m "PixelVerse v3.0 - Enhanced edition with levels, boss, weapons, skills" --allow-empty

echo "[4/4] 推送到 GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "=========================================="
echo "  推送完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 访问 https://github.com/${USERNAME}/PixelVerse/actions"
echo "  2. 等待 'Build iOS IPA (unsigned)' 构建完成（约10-20分钟）"
echo "  3. 在 Artifacts 中下载 IPA"
echo ""
