/// 伤害飘字（向上飘动后消失）
class DamageNumber {
  /// 世界坐标（飘字起点）
  final double x;
  final double y;

  /// 数值
  final int value;

  /// 已存活时间
  double age = 0;

  /// 总寿命
  final double maxLife = 0.9;

  /// 是否为治疗（绿色）
  final bool isHeal;

  /// 是否为暴击/大额（放大）
  final bool big;

  DamageNumber({
    required this.x,
    required this.y,
    required this.value,
    this.isHeal = false,
    this.big = false,
  });

  /// 向上飘动偏移
  double get floatOffset => -age * 40;

  /// 透明度（后半段淡出）
  double get opacity => age < maxLife * 0.6
      ? 1.0
      : (1 - (age - maxLife * 0.6) / (maxLife * 0.4)).clamp(0.0, 1.0);

  /// 字体大小
  double get fontSize => big ? 22 : 16;

  bool get dead => age >= maxLife;

  void update(double dt) {
    age += dt;
  }
}
