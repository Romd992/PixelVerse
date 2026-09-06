import 'package:flutter/material.dart';

/// 评级工具
String calculateRating(int score, int kills, double seconds) {
  if (score >= 800) return 'S';
  if (score >= 500) return 'A';
  if (score >= 250) return 'B';
  return 'C';
}

Color ratingColor(String rating) {
  switch (rating) {
    case 'S':
      return Colors.amber;
    case 'A':
      return Colors.greenAccent;
    case 'B':
      return Colors.blueAccent;
    default:
      return Colors.grey;
  }
}

/// 格式化时间 mm:ss
String formatTime(double seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toInt().toString().padLeft(2, '0');
  return '$m:$s';
}

/// 胜利界面
///
/// 显示详细统计（击杀、金币、用时、得分）和评级，可重开或返回主菜单。
class VictoryScreen extends StatelessWidget {
  final int score;
  final int coins;
  final int kills;
  final double elapsedTime;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const VictoryScreen({
    super.key,
    required this.score,
    required this.coins,
    required this.kills,
    required this.elapsedTime,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final rating = calculateRating(score, kills, elapsedTime);
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('胜利！',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text('你成功征服了所有关卡！',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              // 评级
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: ratingColor(rating).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: ratingColor(rating), width: 3),
                ),
                child: Center(
                  child: Text(rating,
                      style: TextStyle(
                          color: ratingColor(rating),
                          fontSize: 40,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              // 统计
              _buildStatRow('击杀数', '$kills'),
              _buildStatRow('收集金币', '$coins'),
              _buildStatRow('用时', formatTime(elapsedTime)),
              _buildStatRow('最终得分', '$score', highlight: true),
              const SizedBox(height: 24),
              _buildButton('再来一局', onRestart, primary: true),
              const SizedBox(height: 10),
              _buildButton('返回主菜单', onMenu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: highlight ? Colors.amber : Colors.white70,
                  fontSize: highlight ? 18 : 15,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: highlight ? Colors.amber : Colors.white,
                  fontSize: highlight ? 18 : 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool primary = false}) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: primary ? Colors.greenAccent : Colors.white24,
          foregroundColor: primary ? Colors.green[900] : Colors.white,
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
