# GitHub Actions 自动构建 IPA 指南

## 为什么需要这个？

云电脑的 IP 地址被 GitHub 识别为数据中心/机器人 IP，无法直接注册 GitHub 账号。
因此需要你在自己的设备（手机/电脑）上完成注册，然后将代码推送到 GitHub，
GitHub Actions 会自动在 macOS 服务器上编译并生成 unsigned IPA。

## 第一步：注册 GitHub 账号（在你自己的设备上）

1. 用手机或个人电脑浏览器访问 https://github.com/signup
2. 输入邮箱（建议用常用邮箱，如 QQ邮箱/163/Gmail）
3. 设置密码和用户名
4. 完成邮箱验证
5. 登录账号

## 第二步：创建仓库

1. 登录后点击右上角 **+** → **New repository**
2. Repository name 填：`PixelVerse`
3. 选择 **Public**（公开仓库有免费的 macOS Actions 额度）
4. **不要**勾选 "Add a README file"（代码已经准备好了）
5. 点击 **Create repository**

## 第三步：推送代码

### 方式 A：在云电脑终端中执行（推荐）

在云电脑终端中运行以下命令，将 `你的用户名` 替换为你的 GitHub 用户名：

```bash
cd /home/user/Doubao/chats/38440339881427970/pixelverse_game

# 添加远程仓库（替换 你的用户名）
git remote add origin https://github.com/你的用户名/PixelVerse.git

# 添加所有文件
git add -A

# 提交
git commit -m "PixelVerse v3.0 - Enhanced edition"

# 推送（会提示输入 GitHub 用户名和密码）
git branch -M main
git push -u origin main
```

> **注意**：如果密码认证失败，需要使用 Personal Access Token：
> 1. GitHub 右上角头像 → Settings → Developer settings → Personal access tokens → Tokens (classic)
> 2. Generate new token → 勾选 `repo` 权限 → Generate
> 3. 用生成的 token 代替密码

### 方式 B：使用一键推送脚本

```bash
cd /home/user/Doubao/chats/38440339881427970/pixelverse_game
chmod +x scripts/push_to_github.sh
./scripts/push_to_github.sh 你的用户名
```

## 第四步：触发 GitHub Actions 构建

1. 推送代码后，访问你的仓库页面：`https://github.com/你的用户名/PixelVerse`
2. 点击顶部的 **Actions** 标签
3. 你会看到一个名为 "Build iOS IPA (unsigned)" 的工作流正在运行
4. 等待约 10-20 分钟（macOS runner 启动 + Flutter 编译）
5. 构建完成后，点击该工作流运行记录
6. 页面底部 **Artifacts** 区域会有两个文件：
   - `PixelVerse_unsigned_ipa` — 下载解压后得到 IPA 文件
   - `PixelVerse_web` — Web 版本

## 第五步：下载 IPA

1. 在 Artifacts 区域点击 `PixelVerse_unsigned_ipa` 下载
2. 下载的是 zip 文件，解压后得到 `PixelVerse_v2.0.0_unsigned.ipa`
3. 使用 AltStore / Sideloadly 安装到 iPhone

## GitHub Actions 工作流说明

工作流配置文件位于 `.github/workflows/build_ios.yml`，执行以下步骤：
1. 启动 macOS latest 虚拟机
2. 安装 Flutter 3.24.5
3. 执行 `flutter pub get`
4. 执行 `flutter build ios --release --no-codesign`
5. 打包为 unsigned IPA（移除代码签名）
6. 上传 IPA 和 Web 构建产物作为 Artifacts

## 常见问题

**Q: Actions 显示黄色感叹号？**
A: 首次使用 Actions 需要在仓库 Settings → Actions → General 中启用 "Allow all actions and reusable workflows"。

**Q: 构建失败怎么办？**
A: 点击失败的工作流 → 查看日志 → 常见原因是依赖解析失败，通常重试即可。

**Q: 免费额度够用吗？**
A: 公开仓库的 GitHub Actions 完全免费，无分钟数限制。私有仓库每月有 2000 分钟免费额度。

**Q: IPA 可以直接安装吗？**
A: unsigned IPA 需要侧载工具（AltStore/Sideloadly）或越狱设备安装。
