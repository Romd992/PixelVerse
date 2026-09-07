import 'dart:math';

/// 宝箱
///
/// 玩家走过即可打开，获得金币奖励（可能包含武器）。
class Chest {
  final double x;
  final double y;
  final double width = 40;
  final double height = 36;

  /// 是否已打开
  bool opened = false;

  Chest({required this.x, required this.y});

  Rectangle get hitbox => Rectangle(x, y, width, height);

  String get asset => 'assets/images/chest.png';

  /// 打开宝箱，返回获得的金币数
  int open() {
    if (opened) return 0;
    opened = true;
    return 30 + Random().nextInt(21); // 30~50 金币
  }
}
