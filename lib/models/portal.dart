import 'dart:math';

/// 传送门模型（关卡出口）
///
/// 玩家收集足够金币后接触传送门即可通关。
/// 传送门有脉动缩放动画。
class Portal {
  /// 世界坐标（左上角）
  final double x;
  final double y;

  /// 显示尺寸
  final double width = 64;
  final double height = 80;

  /// 脉动动画相位
  double pulsePhase = 0;

  Portal({required this.x, required this.y});

  /// 碰撞盒（略小于精灵图）
  Rectangle get hitbox => Rectangle(x + 8, y + 16, width - 16, height - 24);

  /// 每帧推进脉动动画
  void update(double dt) {
    pulsePhase += dt * 3;
  }

  /// 当前脉动缩放比例（1.0 ± 0.05）
  double get pulseScale => 1.0 + sin(pulsePhase) * 0.05;
}
