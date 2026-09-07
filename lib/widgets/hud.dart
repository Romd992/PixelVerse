import 'package:flutter/material.dart';
import 'experience_bar.dart';

/// 游戏内 HUD（头顶信息层）
///
/// 左上角：生命值（红心x3，失去变灰）+ 等级经验条
/// 右上角：暂停按钮 + 金币数 + 分数
/// 顶部中央：提示信息
class HUD extends StatelessWidget {
  final int hp;
  final int maxHp;
  final int coins;
  final int score;
  final String hint;
  final int level;
  final int xp;
  final int xpToNext;
  final VoidCallback onPause;

  const HUD({
    super.key,
    required this.hp,
    required this.maxHp,
    required this.coins,
    required this.score,
    required this.hint,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---- 左上角：生命值 + 经验条 ----
        Positioned(
          top: 12,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(maxHp, (i) {
                  final full = i < hp;
                  return Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: full
                        ? Image.asset('assets/images/heart.png',
                            width: 30, height: 30, filterQuality: FilterQuality.low)
                        : ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                                Colors.grey, BlendMode.saturation),
                            child: Image.asset('assets/images/heart.png',
                                width: 30, height: 30, filterQuality: FilterQuality.low),
                          ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              ExperienceBar(level: level, xp: xp, xpToNext: xpToNext),
            ],
          ),
        ),

        // ---- 右上角：暂停 + 金币 + 分数 ----
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onPause,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset('assets/images/coin.png',
                      width: 24, height: 24, filterQuality: FilterQuality.low),
                  const SizedBox(width: 4),
                  Text('$coins',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                ],
              ),
              const SizedBox(height: 2),
              Text('分数: $score',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            ],
          ),
        ),

        // ---- 顶部中央：提示 ----
        Positioned(
          top: 14,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(hint,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }
}
