import 'package:flutter/material.dart';
import '../models/save_manager.dart';

/// 开始界面（主菜单）
///
/// 显示游戏标题、最高分、开始游戏/关卡选择/设置按钮，以及触屏操作说明。
class StartScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onLevelSelect;
  final VoidCallback onSettings;

  const StartScreen({
    super.key,
    required this.onStart,
    required this.onLevelSelect,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.png',
            fit: BoxFit.cover, filterQuality: FilterQuality.low),
        Container(color: Colors.black45),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  const Text(
                    'PixelVerse',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(3, 3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'v3.0  ·  像素风动作冒险',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // 最高分
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/coin.png',
                            width: 20, height: 20, filterQuality: FilterQuality.low),
                        const SizedBox(width: 6),
                        Text(
                          '最高分: ${SaveManager.highScore}',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 按钮
                  _buildMenuButton('开始游戏', onStart, primary: true),
                  const SizedBox(height: 14),
                  _buildMenuButton('关卡选择', onLevelSelect),
                  const SizedBox(height: 14),
                  _buildMenuButton('设置', onSettings),
                  const SizedBox(height: 32),
                  // 触屏操作说明
                  _buildControlsCard(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed,
      {bool primary = false}) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: primary ? Colors.amber : Colors.brown[700],
          foregroundColor: primary ? Colors.brown[900] : Colors.white,
          textStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('操作说明',
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('拖动摇杆移动角色',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 4),
          Text('点击攻击按钮战斗',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 4),
          Text('Q冲刺 · W旋风斩 · E治疗术',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 4),
          Text('靠近商人打开商店',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
