import 'package:flutter/material.dart';

/// 经验条（显示在生命值下方）
class ExperienceBar extends StatelessWidget {
  final int level;
  final int xp;
  final int xpToNext;

  const ExperienceBar({
    super.key,
    required this.level,
    required this.xp,
    required this.xpToNext,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = xpToNext > 0 ? (xp / xpToNext).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lv.$level',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.blueAccent],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
