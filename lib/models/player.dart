import 'dart:math';
import 'weapon.dart';
import 'skill.dart';
import 'projectile.dart';

/// 玩家朝向
enum Direction { up, down, left, right }

/// 玩家骑士模型
///
/// 持有位置、生命值、等级经验、武器、技能、装备等数据，
/// 提供每帧更新、攻击、技能释放、受伤、升级等方法。
class Player {
  // ==================== 位置与尺寸 ====================
  double x;
  double y;
  final double width = 48;
  final double height = 48;

  /// 基础移动速度（像素/秒）
  final double baseSpeed = 220;

  // ==================== 生命值 ====================
  int hp = 3;
  int maxHp = 3;

  // ==================== 等级与经验 ====================
  int level = 1;
  int xp = 0;
  int xpToNext = 50;

  /// 攻击加成（等级 +2/级，商店 +5/次）
  int attackBonus = 0;

  // ==================== 朝向与攻击 ====================
  Direction facing = Direction.down;
  bool isAttacking = false;
  double attackTimer = 0;
  final double attackDuration = 0.25;
  double attackCooldown = 0;
  double attackFlash = 0;
  int attackId = 0;

  // ==================== 武器 ====================
  WeaponType currentWeapon = WeaponType.sword;
  final List<WeaponType> ownedWeapons = [WeaponType.sword];

  /// 远程武器攻击时生成的弹道（世界每帧抽取）
  final List<Projectile> pendingShots = [];

  // ==================== 技能 ====================
  final SkillState dashSkill = SkillState(SkillType.dash);
  final SkillState whirlwindSkill = SkillState(SkillType.whirlwind);
  final SkillState healSkill = SkillState(SkillType.heal);

  /// 旋风斩激活时的视觉效果计时
  double whirlwindFlash = 0;

  // ==================== 冲刺 ====================
  bool isDashing = false;
  double dashTimer = 0;
  Direction dashDirection = Direction.down;
  final double dashDuration = 0.18;
  final double dashSpeed = 620;

  // ==================== 装备（本关有效） ====================
  bool hasShield = false; // 受伤减半
  bool hasBoots = false; // 移速 +30%

  // ==================== 无敌与反馈 ====================
  double invincibleTimer = 0;
  final double invincibleDuration = 1.5;

  /// 升级发光效果计时
  double levelUpFlash = 0;

  // ==================== 统计 ====================
  int kills = 0;

  // ==================== 输入 ====================
  double inputX = 0;
  double inputY = 0;

  Player({required this.x, required this.y});

  // ==================== 派生属性 ====================

  /// 实际移动速度（含等级加成和疾风靴）
  double get speed {
    var s = baseSpeed * (1 + 0.05 * (level - 1));
    if (hasBoots) s *= 1.3;
    return s;
  }

  /// 当前武器信息
  WeaponInfo get weapon => WeaponInfo.of(currentWeapon);

  /// 实际攻击力
  int get attackPower => weapon.baseDamage + attackBonus;

  /// 玩家碰撞盒
  Rectangle get hitbox => Rectangle(x + 8, y + 12, width - 16, height - 16);

  /// 近战攻击判定盒（仅剑类武器生效）
  Rectangle? get attackHitbox {
    if (!isAttacking || weapon.isRanged) return null;
    const reach = 42.0;
    const size = 46.0;
    switch (facing) {
      case Direction.up:
        return Rectangle(x + width / 2 - size / 2, y - reach + 8, size, size);
      case Direction.down:
        return Rectangle(x + width / 2 - size / 2, y + height - 8, size, size);
      case Direction.left:
        return Rectangle(x - reach + 8, y + height / 2 - size / 2, size, size);
      case Direction.right:
        return Rectangle(x + width - 8, y + height / 2 - size / 2, size, size);
    }
  }

  bool get isInvincible => invincibleTimer > 0 || isDashing;
  bool get canAttack => attackCooldown <= 0 && !isAttacking;

  // ==================== 每帧更新 ====================

  void update(double dt) {
    // 攻击动画
    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) {
        isAttacking = false;
        attackTimer = 0;
      }
    }
    if (attackCooldown > 0) {
      attackCooldown -= dt;
      if (attackCooldown < 0) attackCooldown = 0;
    }
    if (attackFlash > 0) {
      attackFlash -= dt;
      if (attackFlash < 0) attackFlash = 0;
    }

    // 技能冷却
    dashSkill.update(dt);
    whirlwindSkill.update(dt);
    healSkill.update(dt);
    if (whirlwindFlash > 0) {
      whirlwindFlash -= dt;
      if (whirlwindFlash < 0) whirlwindFlash = 0;
    }

    // 冲刺
    if (isDashing) {
      dashTimer -= dt;
      if (dashTimer <= 0) {
        isDashing = false;
      }
    }

    // 无敌
    if (invincibleTimer > 0) {
      invincibleTimer -= dt;
      if (invincibleTimer < 0) invincibleTimer = 0;
    }

    // 升级发光
    if (levelUpFlash > 0) {
      levelUpFlash -= dt;
      if (levelUpFlash < 0) levelUpFlash = 0;
    }
  }

  // ==================== 攻击 ====================

  /// 尝试攻击。近战设置攻击判定，远程生成弹道。
  bool tryAttack() {
    if (canAttack) {
      isAttacking = true;
      attackTimer = attackDuration;
      attackCooldown = weapon.cooldown;
      attackFlash = attackDuration;
      attackId++;

      if (weapon.isRanged) {
        _spawnProjectile();
      }
      return true;
    }
    return false;
  }

  /// 根据朝向生成远程弹道
  void _spawnProjectile() {
    double vx = 0, vy = 0;
    switch (facing) {
      case Direction.up:
        vy = -weapon.projectileSpeed;
        break;
      case Direction.down:
        vy = weapon.projectileSpeed;
        break;
      case Direction.left:
        vx = -weapon.projectileSpeed;
        break;
      case Direction.right:
        vx = weapon.projectileSpeed;
        break;
    }
    final proj = Projectile(
      type: currentWeapon == WeaponType.bow
          ? ProjectileType.arrow
          : ProjectileType.fireball,
      fromPlayer: true,
      x: x + width / 2 - 12,
      y: y + height / 2 - 12,
      vx: vx,
      vy: vy,
      damage: attackPower,
    );
    pendingShots.add(proj);
  }

  /// 切换到指定武器（必须已拥有）
  bool switchWeapon(WeaponType w) {
    if (ownedWeapons.contains(w)) {
      currentWeapon = w;
      return true;
    }
    return false;
  }

  /// 拾取武器
  void pickupWeapon(WeaponType w) {
    if (!ownedWeapons.contains(w)) {
      ownedWeapons.add(w);
      currentWeapon = w;
    }
  }

  // ==================== 技能 ====================

  /// 释放冲刺
  bool castDash() {
    if (dashSkill.tryCast()) {
      isDashing = true;
      dashTimer = dashDuration;
      dashDirection = facing;
      return true;
    }
    return false;
  }

  /// 释放旋风斩（返回是否成功，实际范围伤害由世界处理）
  bool castWhirlwind() {
    if (whirlwindSkill.tryCast()) {
      whirlwindFlash = 0.4;
      return true;
    }
    return false;
  }

  /// 释放治疗术
  bool castHeal() {
    if (healSkill.tryCast()) {
      heal(1);
      return true;
    }
    return false;
  }

  // ==================== 受伤与恢复 ====================

  /// 受到 [rawDamage] 点伤害（盾牌减半）。无敌时忽略。
  bool takeDamage(int rawDamage) {
    if (isInvincible) return false;
    var dmg = rawDamage;
    if (hasShield) dmg = (dmg / 2).ceil();
    hp -= dmg;
    invincibleTimer = invincibleDuration;
    return true;
  }

  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  // ==================== 经验与升级 ====================

  /// 获得经验，返回是否升级
  bool gainXp(int amount) {
    xp += amount;
    bool leveled = false;
    while (xp >= xpToNext) {
      xp -= xpToNext;
      level++;
      maxHp++;
      hp = maxHp; // 升级回满
      attackBonus += 2;
      xpToNext = (xpToNext * 1.4).round();
      levelUpFlash = 1.0;
      leveled = true;
    }
    return leveled;
  }

  // ==================== 重置 ====================

  /// 重置到新关卡的初始状态（保留等级、武器、攻击加成等跨关卡数据）
  void resetForLevel(double startX, double startY) {
    x = startX;
    y = startY;
    hp = maxHp;
    facing = Direction.down;
    isAttacking = false;
    attackTimer = 0;
    attackCooldown = 0;
    attackId = 0;
    invincibleTimer = 0;
    attackFlash = 0;
    isDashing = false;
    dashTimer = 0;
    levelUpFlash = 0;
    whirlwindFlash = 0;
    pendingShots.clear();
    // 技能冷却重置
    dashSkill.remainingCooldown = 0;
    whirlwindSkill.remainingCooldown = 0;
    healSkill.remainingCooldown = 0;
    // 装备每关重置
    hasShield = false;
    hasBoots = false;
    inputX = 0;
    inputY = 0;
  }

  /// 完全重置（新游戏）
  void fullReset(double startX, double startY) {
    level = 1;
    xp = 0;
    xpToNext = 50;
    attackBonus = 0;
    maxHp = 3;
    currentWeapon = WeaponType.sword;
    ownedWeapons.clear();
    ownedWeapons.add(WeaponType.sword);
    kills = 0;
    resetForLevel(startX, startY);
  }
}
