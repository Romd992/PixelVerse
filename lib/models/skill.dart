/// 技能类型
enum SkillType { dash, whirlwind, heal }

/// 技能静态信息
class SkillInfo {
  final SkillType type;
  final String name;

  /// 快捷键提示
  final String keyLabel;

  /// 冷却时间（秒）
  final double cooldown;

  /// 图标文字（无独立图标素材，用文字标识）
  final String iconText;

  const SkillInfo({
    required this.type,
    required this.name,
    required this.keyLabel,
    required this.cooldown,
    required this.iconText,
  });

  static const Map<SkillType, SkillInfo> table = {
    SkillType.dash: SkillInfo(
      type: SkillType.dash,
      name: '冲刺',
      keyLabel: 'Q',
      cooldown: 5.0,
      iconText: '冲',
    ),
    SkillType.whirlwind: SkillInfo(
      type: SkillType.whirlwind,
      name: '旋风斩',
      keyLabel: 'W',
      cooldown: 8.0,
      iconText: '旋',
    ),
    SkillType.heal: SkillInfo(
      type: SkillType.heal,
      name: '治疗术',
      keyLabel: 'E',
      cooldown: 15.0,
      iconText: '愈',
    ),
  };

  static SkillInfo of(SkillType type) => table[type]!;
}

/// 技能运行时状态（冷却计时）
class SkillState {
  final SkillType type;
  double remainingCooldown = 0;

  SkillState(this.type);

  double get maxCooldown => SkillInfo.of(type).cooldown;
  bool get isReady => remainingCooldown <= 0;
  double get cooldownRatio =>
      isReady ? 0 : remainingCooldown / maxCooldown;

  void update(double dt) {
    if (remainingCooldown > 0) {
      remainingCooldown -= dt;
      if (remainingCooldown < 0) remainingCooldown = 0;
    }
  }

  /// 尝试释放，成功则进入冷却
  bool tryCast() {
    if (isReady) {
      remainingCooldown = maxCooldown;
      return true;
    }
    return false;
  }
}
