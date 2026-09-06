import 'dart:math';

/// 弹道类型
enum ProjectileType { arrow, fireball }

/// 弹道实体（玩家箭矢/火球，敌人箭矢/火球）
class Projectile {
  final ProjectileType type;

  /// 是否由玩家发射（决定伤害对象）
  final bool fromPlayer;

  /// 世界坐标（左上角）
  double x;
  double y;

  /// 速度分量
  final double vx;
  final double vy;

  /// 伤害值
  final int damage;

  /// 显示尺寸
  final double width;
  final double height;

  /// 剩余存活时间（秒），超时自动消失
  double life;

  /// 是否已命中（待移除）
  bool hit = false;

  Projectile({
    required this.type,
    required this.fromPlayer,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.damage,
    this.life = 3.0,
  })  : width = type == ProjectileType.arrow ? 24 : 28,
        height = type == ProjectileType.arrow ? 12 : 28;

  /// 碰撞盒
  Rectangle get hitbox => Rectangle(x, y, width, height);

  /// 素材路径
  String get asset => type == ProjectileType.arrow
      ? 'assets/images/arrow.png'
      : 'assets/images/fireball.png';

  /// 旋转角度（用于箭矢朝向）
  double get angle => atan2(vy, vx);

  /// 每帧推进
  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
  }

  bool get expired => life <= 0 || hit;
}
