import 'dart:math';

/// 商人 NPC
///
/// 玩家靠近时可打开商店界面。
class Merchant {
  final double x;
  final double y;
  final double width = 48;
  final double height = 56;

  const Merchant({required this.x, required this.y});

  Rectangle get hitbox => Rectangle(x, y, width, height);

  /// 交互范围（玩家在此范围内可打开商店）
  Rectangle get interactBox =>
      Rectangle(x - 30, y - 30, width + 60, height + 60);

  String get asset => 'assets/images/merchant.png';
}
