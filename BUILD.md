# PixelVerse 构建说明

## 项目概述
PixelVerse 是一个像素风动作冒险游戏，使用 Flutter 开发。
- 当前版本：v2.0.0
- 技术栈：Flutter 3.24.5 / Dart 3.5.4
- 支持平台：iOS、Web（Android/Windows/macOS/Linux 也可编译）

## 目录结构
```
pixelverse_game/
├── lib/                    # Dart 源代码
│   ├── main.dart          # 入口
│   ├── game/              # 游戏核心逻辑
│   ├── models/            # 数据模型
│   ├── screens/           # 界面（开始/暂停/胜利/失败）
│   └── widgets/           # 可复用组件
├── assets/images/         # 游戏图片素材（13张PNG）
├── ios/                   # iOS 平台配置
├── web/                   # Web 平台配置
├── scripts/
│   ├── build_ios.sh       # macOS 一键构建 IPA
│   └── repack_ipa_linux.sh # Linux 资源替换重打包（最佳尝试）
├── .github/workflows/
│   └── build_ios.yml      # GitHub Actions 自动构建
└── pubspec.yaml
```

## 方式一：在 macOS 上构建 IPA（推荐，获得完整游戏）

### 前置要求
- macOS 13+
- Xcode 15+（命令行工具：`xcode-select --install`）
- Flutter SDK 3.24.5+
- CocoaPods（`sudo gem install cocoapods`）

### 构建步骤
```bash
# 1. 进入项目目录
cd pixelverse_game

# 2. 执行一键构建脚本
chmod +x scripts/build_ios.sh
./scripts/build_ios.sh
```

构建完成后，IPA 文件位于：
`build/PixelVerse_v2.0.0_unsigned.ipa`

### 手动构建（如需更多控制）
```bash
flutter pub get
flutter clean
flutter build ios --release --no-codesign

# 手动打包
cd build/ios/iphoneos
mkdir -p Payload
cp -R Runner.app Payload/
# 移除签名
rm -rf Payload/Runner.app/_CodeSignature
rm -rf Payload/Runner.app/embedded.mobileprovision
zip -r ../../PixelVerse_unsigned.ipa Payload/
```

## 方式二：使用 GitHub Actions 自动构建（无需 Mac）

1. 将项目推送到 GitHub 仓库
2. 确保 `.github/workflows/build_ios.yml` 已提交
3. 在 GitHub 仓库的 Actions 页面手动触发 "Build iOS IPA (unsigned)"
4. 等待构建完成（约 10-20 分钟）
5. 从 Artifacts 下载 `PixelVerse_unsigned_ipa`

GitHub Actions 使用 macOS runner，会编译完整的游戏代码并生成 IPA。

## 方式三：Linux 资源替换重打包（仅替换图片，不推荐）

由于 Linux 无法编译 iOS AOT Dart 代码，此方式仅替换图片素材：
```bash
chmod +x scripts/repack_ipa_linux.sh
./scripts/repack_ipa_linux.sh
```
生成的 IPA 中 App 二进制仍是旧版代码，**游戏逻辑不会更新**。

## 方式四：Web 版本预览（任意平台）

```bash
flutter pub get
flutter run -d chrome          # 开发模式
flutter build web --release    # 发布构建
# 产物在 build/web/ 目录，可部署到任意静态服务器
```

## unsigned IPA 安装方法

生成的 IPA 未签名，可通过以下方式安装到 iOS 设备：

1. **AltStore**（免费，需电脑配合刷新）
   - 下载 AltServer，连接手机，通过 AltStore 侧载 IPA

2. **Sideloadly**（免费）
   - 下载 Sideloadly，连接手机，拖入 IPA 即可安装

3. **自签名 + Xcode**
   - 使用免费 Apple ID 签名后通过 Xcode 安装（7天有效期）

4. **越狱设备**
   - 可直接安装 unsigned IPA

5. **企业证书 / TestFlight**
   - 需要付费 Apple Developer 账号

## 游戏操作

### 桌面端（Web/macOS/Windows）
- **WASD / 方向键**：移动角色
- **空格键**：攻击
- **ESC / P**：暂停

### 移动端（iOS）
- **左下角虚拟摇杆**：移动
- **右下角攻击按钮**：攻击
- 游戏内暂停按钮

## 游戏目标
1. 在地图上探索，收集金币（至少 10 枚）
2. 击败史莱姆和蝙蝠敌人
3. 收集宝石获得高分，收集药水恢复生命
4. 收集足够金币后前往魔法传送门通关
5. 生命值归零则游戏失败
