import 'package:flutter/material.dart';

/// BOSS 血条（屏幕顶部中央）
class BossHealthBar extends StatelessWidget {
  final String bossName;
  final double hpRatio; // 0~1

  const BossHealthBar({
    super.key,
    this.bossName = '深渊恶魔',
    required this.hpRatio,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = hpRatio.clamp(0.0, 1.0);
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bossName,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
