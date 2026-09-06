import 'dart:math';

/// 障碍物/装饰物类型
enum ObstacleType { tree, rock, sign }

/// 障碍物模型
///
/// - 树（tree）：不可穿越
/// - 岩石（rock）：不可穿越
/// - 木牌（sign）：纯装饰，不阻挡移动
class Obstacle {
  /// 类型
  final ObstacleType type;

  /// 世界坐标（左上角）
  final double x;
  final double y;

  /// 显示尺寸
  final double width;
  final double height;

  Obstacle({
    required this.type,
    required this.x,
    required this.y,
  })  : width = type == ObstacleType.tree
            ? 56
            : type == ObstacleType.rock
                ? 48
                : 40,
        height = type == ObstacleType.tree
            ? 56
            : type == ObstacleType.rock
                ? 44
                : 48;

  /// 碰撞盒。木牌为纯装饰，返回 null（不阻挡）。
  Rectangle? get hitbox {
    if (type == ObstacleType.sign) return null;
    // 碰撞盒略小于精灵图，并内缩
    return Rectangle(x + 6, y + 6, width - 12, height - 12);
  }

  /// 是否阻挡玩家移动
  bool get blocksMovement => type != ObstacleType.sign;
}
