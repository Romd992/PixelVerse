#!/bin/bash
# ============================================================
# PixelVerse iOS IPA 构建脚本 (unsigned)
# 在 macOS 上执行即可生成无需签名的 IPA 文件
# ============================================================
set -e

echo "=========================================="
echo "  PixelVerse IPA Build Script (unsigned)"
echo "=========================================="

# 检查是否在 macOS 上
if [[ "$(uname)" != "Darwin" ]]; then
    echo "错误：此脚本必须在 macOS 上运行"
    exit 1
fi

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "错误：未找到 Flutter SDK，请先安装 Flutter"
    echo "  参考：https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "错误：未找到 Xcode，请先安装 Xcode"
    exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo ""
echo "[1/5] 获取依赖..."
flutter pub get

echo ""
echo "[2/5] 清理旧构建..."
flutter clean

echo ""
echo "[3/5] 构建 iOS (release, no codesign)..."
# 使用 --no-codesign 生成未签名的构建产物
flutter build ios --release --no-codesign

echo ""
echo "[4/5] 打包 IPA..."
BUILD_DIR="$PROJECT_DIR/build/ios/iphoneos"
PAYLOAD_DIR="$PROJECT_DIR/build/ipa_payload"
IPA_NAME="PixelVerse_v3.0.0_unsigned.ipa"
IPA_PATH="$PROJECT_DIR/build/$IPA_NAME"

# 清理旧的打包目录
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR/Payload"

# 复制 .app 到 Payload
cp -R "$BUILD_DIR/Runner.app" "$PAYLOAD_DIR/Payload/"

# 移除代码签名（确保 unsigned）
rm -rf "$PAYLOAD_DIR/Payload/Runner.app/_CodeSignature"
rm -rf "$PAYLOAD_DIR/Payload/Runner.app/Frameworks/App.framework/_CodeSignature"
rm -rf "$PAYLOAD_DIR/Payload/Runner.app/Frameworks/Flutter.framework/_CodeSignature"

# 移除 embedded.mobileprovision（如果有）
rm -f "$PAYLOAD_DIR/Payload/Runner.app/embedded.mobileprovision"

# 打包为 IPA（zip 格式）
cd "$PAYLOAD_DIR"
zip -r "$IPA_PATH" Payload/
cd "$PROJECT_DIR"

# 清理临时目录
rm -rf "$PAYLOAD_DIR"

echo ""
echo "[5/5] 完成！"
echo "=========================================="
echo "  IPA 已生成：$IPA_PATH"
echo "  文件大小：$(du -h "$IPA_PATH" | cut -f1)"
echo "=========================================="
echo ""
echo "注意：这是 unsigned IPA，需要通过以下方式安装："
echo "  - 使用 AltStore / Sideloadly 侧载"
echo "  - 使用自签名证书重签名后通过 Xcode 安装"
echo "  - 越狱设备可直接安装"
echo ""
