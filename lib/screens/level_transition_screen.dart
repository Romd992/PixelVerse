import 'package:flutter/material.dart';

/// 关卡过渡画面
///
/// 显示关卡名称和目标提示，2秒后自动进入关卡。
class LevelTransitionScreen extends StatelessWidget {
  final int levelIndex;
  final String levelName;
  final String objective;

  const LevelTransitionScreen({
    super.key,
    required this.levelIndex,
    required this.levelName,
    required this.objective,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '第 ${levelIndex + 1} 关',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              levelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                shadows: [
                  Shadow(color: Colors.amber, blurRadius: 12),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                objective,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
