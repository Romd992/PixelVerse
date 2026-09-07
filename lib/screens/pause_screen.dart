import 'package:flutter/material.dart';

/// 暂停界面（覆盖在游戏画面之上）
///
/// 提供继续游戏、重新开始本关、返回主菜单三个选项。
class PauseScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestartLevel;
  final VoidCallback onMenu;

  const PauseScreen({
    super.key,
    required this.onResume,
    required this.onRestartLevel,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.brown[800],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('暂停',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 24),
              _buildButton('继续游戏', onResume),
              const SizedBox(height: 12),
              _buildButton('重新开始本关', onRestartLevel),
              const SizedBox(height: 12),
              _buildButton('返回主菜单', onMenu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.brown[900],
          textStyle:
              const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text),
      ),
    );
  }
}
