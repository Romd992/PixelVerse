/// 武器类型
enum WeaponType { sword, bow, staff }

/// 武器静态信息
class WeaponInfo {
  final WeaponType type;
  final String name;

  /// 基础攻击力（实际伤害 = 基础攻击 + 玩家攻击加成）
  final int baseDamage;

  /// 攻击冷却（秒）
  final double cooldown;

  /// 是否为远程武器
  final bool isRanged;

  /// 地面拾取时显示的图标素材（剑无独立素材，显示文字）
  final String? pickupAsset;

  /// 弹道素材（仅远程武器）
  final String? projectileAsset;

  /// 弹道速度（像素/秒，仅远程）
  final double projectileSpeed;

  const WeaponInfo({
    required this.type,
    required this.name,
    required this.baseDamage,
    required this.cooldown,
    required this.isRanged,
    this.pickupAsset,
    this.projectileAsset,
    this.projectileSpeed = 400,
  });

  /// 所有武器信息表
  static const Map<WeaponType, WeaponInfo> table = {
    WeaponType.sword: WeaponInfo(
      type: WeaponType.sword,
      name: '剑',
      baseDamage: 10,
      cooldown: 0.45,
      isRanged: false,
    ),
    WeaponType.bow: WeaponInfo(
      type: WeaponType.bow,
      name: '弓',
      baseDamage: 8,
      cooldown: 0.35,
      isRanged: true,
      pickupAsset: 'assets/images/bow.png',
      projectileAsset: 'assets/images/arrow.png',
      projectileSpeed: 480,
    ),
    WeaponType.staff: WeaponInfo(
      type: WeaponType.staff,
      name: '法杖',
      baseDamage: 15,
      cooldown: 0.8,
      isRanged: true,
      pickupAsset: 'assets/images/staff.png',
      projectileAsset: 'assets/images/fireball.png',
      projectileSpeed: 320,
    ),
  };

  static WeaponInfo of(WeaponType type) => table[type]!;
}
