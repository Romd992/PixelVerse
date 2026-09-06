#!/bin/bash
# ============================================================
# PixelVerse IPA 资源替换脚本（Linux 环境最佳尝试）
# 复用原始 IPA 结构，替换 flutter_assets 中的图片素材
# 注意：由于 Linux 无法编译 iOS AOT Dart 代码，App.framework/App
#       仍为原始编译代码。此脚本仅替换资源文件。
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 原始 IPA 解压目录
ORIGINAL_IPA_EXTRACT="/home/user/.doubao/agent_mode/workspace/.sessions/38440339881427970/agents/m_0cwEQhl2zhf/ipa_extract"

# 输出
OUTPUT_DIR="$PROJECT_DIR/build"
IPA_NAME="PixelVerse_v2.0.0_assets-replaced_unsigned.ipa"
IPA_PATH="$OUTPUT_DIR/$IPA_NAME"
WORK_DIR="$OUTPUT_DIR/ipa_repack_work"

echo "=========================================="
echo "  PixelVerse IPA Resource Replace (Linux)"
echo "=========================================="

if [ ! -d "$ORIGINAL_IPA_EXTRACT/Payload" ]; then
    echo "错误：找不到原始 IPA 解压目录：$ORIGINAL_IPA_EXTRACT"
    exit 1
fi

echo ""
echo "[1/4] 复制原始 IPA 结构..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp -R "$ORIGINAL_IPA_EXTRACT/Payload" "$WORK_DIR/"

echo ""
echo "[2/4] 替换 flutter_assets 中的图片素材..."
ASSETS_DIR="$WORK_DIR/Payload/Runner.app/Frameworks/App.framework/flutter_assets/assets/images"
mkdir -p "$ASSETS_DIR"

# 复制新素材
for img in player slime bat coin heart gem tree rock grass background potion portal sign; do
    if [ -f "$PROJECT_DIR/assets/images/${img}.png" ]; then
        cp "$PROJECT_DIR/assets/images/${img}.png" "$ASSETS_DIR/"
        echo "  已替换: ${img}.png"
    fi
done

echo ""
echo "[3/4] 移除代码签名（确保 unsigned）..."
rm -rf "$WORK_DIR/Payload/Runner.app/_CodeSignature" 2>/dev/null || true
rm -rf "$WORK_DIR/Payload/Runner.app/Frameworks/App.framework/_CodeSignature" 2>/dev/null || true
rm -rf "$WORK_DIR/Payload/Runner.app/Frameworks/Flutter.framework/_CodeSignature" 2>/dev/null || true
rm -f "$WORK_DIR/Payload/Runner.app/embedded.mobileprovision" 2>/dev/null || true

echo ""
echo "[4/4] 打包 IPA..."
mkdir -p "$OUTPUT_DIR"
cd "$WORK_DIR"
zip -r "$IPA_PATH" Payload/
cd "$PROJECT_DIR"

# 清理
rm -rf "$WORK_DIR"

echo ""
echo "=========================================="
echo "  IPA 已生成：$IPA_PATH"
echo "  文件大小：$(du -h "$IPA_PATH" | cut -f1)"
echo "=========================================="
echo ""
echo "⚠️  重要提示："
echo "  此 IPA 仅替换了图片素材，App.framework/App 仍是"
echo "  原始 v1.0.0 的编译代码（代码绘制色块的旧游戏逻辑）。"
echo "  要获得完整的 v2.0 游戏，必须在 macOS 上使用"
echo "  scripts/build_ios.sh 重新编译。"
echo ""
