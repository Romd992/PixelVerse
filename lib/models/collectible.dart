import 'dart:math';

/// 收集物类型
enum CollectibleType { coin, gem, potion }

/// 收集物模型
///
/// 支持三种收集物：
/// - 金币（coin）：+10 分，计入通关所需金币数
/// - 宝石（gem）：+50 分，稀有
/// - 药水（potion）：恢复 1 点生命值
class Collectible {
  /// 类型
  final CollectibleType type;

  /// 世界坐标（左上角）
  double x;
  double y;

  /// 显示尺寸
  final double width;
  final double height;

  /// 是否已被收集（收集后播放消失动画）
  bool collected = false;

  /// 收集消失动画已播放时间（秒）
  double collectAnim = 0;

  /// 消失动画总时长
  final double collectDuration = 0.35;

  /// 浮动动画相位（随机起始，避免所有物品同步浮动）
  final double bobPhase;

  Collectible({
    required this.type,
    required this.x,
    required this.y,
  })  : width = type == CollectibleType.coin ? 24 : 28,
        height = type == CollectibleType.coin ? 24 : 28,
        bobPhase = Random().nextDouble() * 2 * pi;

  /// 碰撞盒
  Rectangle get hitbox => Rectangle(x, y, width, height);

  /// 分数价值
  int get scoreValue {
    switch (type) {
      case CollectibleType.coin:
        return 10;
      case CollectibleType.gem:
        return 50;
      case CollectibleType.potion:
        return 0;
    }
  }

  /// 恢复生命值（仅药水为 1）
  int get healValue => type == CollectibleType.potion ? 1 : 0;

  /// 是否为金币
  bool get isCoin => type == CollectibleType.coin;

  /// 每帧更新（浮动动画由渲染时实时计算，此处只推进收集动画）
  void update(double dt) {
    if (collected) {
      collectAnim += dt;
    }
  }

  /// 收集动画是否完成（可从列表移除）
  bool get removeReady => collected && collectAnim >= collectDuration;

  /// 当前浮动偏移量（用于渲染时上下漂浮）
  double get bobOffset =>
      collected ? 0 : sin(DateTime.now().millisecondsSinceEpoch / 300 + bobPhase) * 3;
}
