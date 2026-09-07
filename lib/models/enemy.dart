import 'dart:math';
import 'player.dart';
import 'projectile.dart';

/// 敌人类型
enum EnemyType { slime, bat, archer, boar, bomb, boss }

/// 敌人模型
///
/// 支持六种敌人：
/// - 史莱姆（slime）：地面巡逻，2HP，经验10
/// - 蝙蝠（bat）：飞行追踪，1HP，经验15
/// - 骷髅弓箭手（archer）：保持距离射箭，3HP，经验20
/// - 野猪（boar）：冲锋攻击，4HP，经验25
/// - 炸弹怪（bomb）：接近自爆，2HP，经验20
/// - BOSS（boss）：巨型恶魔，20HP，经验100，近战+火球
class Enemy {
  final EnemyType type;
  double x;
  double y;
  final double width;
  final double height;
  int hp;
  final int maxHp;
  final double speed;

  /// 击杀经验值
  final int xpValue;

  // ==================== 通用计时器 ====================
  double hitFlash = 0;
  bool isDead = false;
  double deathTimer = 0;
  final double deathDuration = 0.3;
  bool dropProcessed = false;
  int lastHitAttackId = -1;
  int lastHitWhirlwindId = -1; // 防止旋风斩重复命中

  // ==================== 史莱姆巡逻 ====================
  double patrolDir = 1;
  double patrolTimer = 0;
  final double patrolChangeInterval = 2.5;

  // ==================== 弓箭手 ====================
  double shootTimer = 1.5; // 首次射击延迟
  final double shootInterval = 2.2;

  // ==================== 野猪冲锋 ====================
  bool isCharging = false;
  double chargeTimer = 0;
  final double chargeDuration = 0.6;
  double chargeCooldown = 0;
  final double chargeCooldownMax = 2.5;
  double chargeVx = 0;
  double chargeVy = 0;
  final double chargeSpeed = 380;
  bool chargeHitDone = false; // 本次冲锋是否已造成伤害

  // ==================== 炸弹怪 ====================
  bool fuseLit = false;
  double fuseTimer = 0;
  final double fuseDuration = 1.0;
  final double explosionRadius = 80;
  bool hasExploded = false;

  // ==================== BOSS ====================
  double bossMeleeCooldown = 0;
  double bossRangedCooldown = 1.5;
  final double bossMeleeInterval = 1.6;
  final double bossRangedInterval = 2.8;
  bool bossMeleeActive = false; // 近战挥斧判定窗口
  double bossMeleeTimer = 0;

  /// 敌人生成的弹道（世界每帧抽取）
  final List<Projectile> pendingShots = [];

  Enemy({
    required this.type,
    required this.x,
    required this.y,
  })  : width = _widthFor(type),
        height = _heightFor(type),
        hp = _hpFor(type),
        maxHp = _hpFor(type),
        speed = _speedFor(type),
        xpValue = _xpFor(type);

  static double _widthFor(EnemyType t) {
    switch (t) {
      case EnemyType.slime:
        return 40;
      case EnemyType.bat:
        return 36;
      case EnemyType.archer:
        return 40;
      case EnemyType.boar:
        return 52;
      case EnemyType.bomb:
        return 36;
      case EnemyType.boss:
        return 96;
    }
  }

  static double _heightFor(EnemyType t) {
    switch (t) {
      case EnemyType.slime:
        return 36;
      case EnemyType.bat:
        return 32;
      case EnemyType.archer:
        return 48;
      case EnemyType.boar:
        return 40;
      case EnemyType.bomb:
        return 36;
      case EnemyType.boss:
        return 96;
    }
  }

  static int _hpFor(EnemyType t) {
    switch (t) {
      case EnemyType.slime:
        return 2;
      case EnemyType.bat:
        return 1;
      case EnemyType.archer:
        return 3;
      case EnemyType.boar:
        return 4;
      case EnemyType.bomb:
        return 2;
      case EnemyType.boss:
        return 20;
    }
  }

  static double _speedFor(EnemyType t) {
    switch (t) {
      case EnemyType.slime:
        return 55;
      case EnemyType.bat:
        return 130;
      case EnemyType.archer:
        return 70;
      case EnemyType.boar:
        return 80;
      case EnemyType.bomb:
        return 90;
      case EnemyType.boss:
        return 60;
    }
  }

  static int _xpFor(EnemyType t) {
    switch (t) {
      case EnemyType.slime:
        return 10;
      case EnemyType.bat:
        return 15;
      case EnemyType.archer:
        return 20;
      case EnemyType.boar:
        return 25;
      case EnemyType.bomb:
        return 20;
      case EnemyType.boss:
        return 100;
    }
  }

  /// 素材路径
  String get asset {
    switch (type) {
      case EnemyType.slime:
        return 'assets/images/slime.png';
      case EnemyType.bat:
        return 'assets/images/bat.png';
      case EnemyType.archer:
        return 'assets/images/archer.png';
      case EnemyType.boar:
        return 'assets/images/boar.png';
      case EnemyType.bomb:
        return 'assets/images/bomb.png';
      case EnemyType.boss:
        return 'assets/images/boss.png';
    }
  }

  /// 碰撞盒
  Rectangle get hitbox => Rectangle(x + 4, y + 4, width - 8, height - 8);

  /// BOSS 近战判定盒（在朝向方向）
  Rectangle? get bossMeleeHitbox {
    if (!bossMeleeActive || type != EnemyType.boss) return null;
    const size = 80.0;
    // BOSS 始终面向玩家，由 update 中设置朝向
    return Rectangle(
      x + width / 2 - size / 2,
      y + height / 2 - size / 2,
      size,
      size,
    );
  }

  // ==================== 每帧更新 ====================

  void update(double dt, Player player, double worldW, double worldH) {
    if (isDead) {
      deathTimer += dt;
      return;
    }

    if (hitFlash > 0) {
      hitFlash -= dt;
      if (hitFlash < 0) hitFlash = 0;
    }

    switch (type) {
      case EnemyType.slime:
        _updateSlime(dt, worldW);
        break;
      case EnemyType.bat:
        _updateBat(dt, player, worldW, worldH);
        break;
      case EnemyType.archer:
        _updateArcher(dt, player, worldW, worldH);
        break;
      case EnemyType.boar:
        _updateBoar(dt, player, worldW, worldH);
        break;
      case EnemyType.bomb:
        _updateBomb(dt, player, worldW, worldH);
        break;
      case EnemyType.boss:
        _updateBoss(dt, player, worldW, worldH);
        break;
    }
  }

  // ==================== 史莱姆 ====================

  void _updateSlime(double dt, double worldW) {
    patrolTimer += dt;
    if (patrolTimer >= patrolChangeInterval) {
      patrolTimer = 0;
      patrolDir = Random().nextBool() ? 1 : -1;
    }
    x += patrolDir * speed * dt;
    if (x < 20) {
      x = 20;
      patrolDir = 1;
    } else if (x > worldW - width - 20) {
      x = worldW - width - 20;
      patrolDir = -1;
    }
  }

  // ==================== 蝙蝠 ====================

  void _updateBat(double dt, Player player, double worldW, double worldH) {
    final cx = x + width / 2;
    final cy = y + height / 2;
    final dx = (player.x + player.width / 2) - cx;
    final dy = (player.y + player.height / 2) - cy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > 1 && dist < 420) {
      x += (dx / dist) * speed * dt;
      y += (dy / dist) * speed * dt;
    } else {
      x += sin(DateTime.now().millisecondsSinceEpoch / 600 + x) * 18 * dt;
      y += cos(DateTime.now().millisecondsSinceEpoch / 700 + y) * 12 * dt;
    }
    x = x.clamp(0.0, worldW - width);
    y = y.clamp(0.0, worldH - height);
  }

  // ==================== 弓箭手 ====================

  void _updateArcher(double dt, Player player, double worldW, double worldH) {
    final cx = x + width / 2;
    final cy = y + height / 2;
    final px = player.x + player.width / 2;
    final py = player.y + player.height / 2;
    final dx = px - cx;
    final dy = py - cy;
    final dist = sqrt(dx * dx + dy * dy);

    // 保持距离：太近后退，太远前进
    if (dist > 1) {
      if (dist < 180) {
        x -= (dx / dist) * speed * dt;
        y -= (dy / dist) * speed * dt;
      } else if (dist > 320) {
        x += (dx / dist) * speed * dt;
        y += (dy / dist) * speed * dt;
      }
    }

    // 射击
    shootTimer -= dt;
    if (shootTimer <= 0 && dist < 500) {
      shootTimer = shootInterval;
      const spd = 350.0;
      pendingShots.add(Projectile(
        type: ProjectileType.arrow,
        fromPlayer: false,
        x: cx - 12,
        y: cy - 6,
        vx: (dx / dist) * spd,
        vy: (dy / dist) * spd,
        damage: 1,
      ));
    }

    x = x.clamp(0.0, worldW - width);
    y = y.clamp(0.0, worldH - height);
  }

  // ==================== 野猪 ====================

  void _updateBoar(double dt, Player player, double worldW, double worldH) {
    if (chargeCooldown > 0) {
      chargeCooldown -= dt;
      if (chargeCooldown < 0) chargeCooldown = 0;
    }

    if (isCharging) {
      chargeTimer -= dt;
      x += chargeVx * dt;
      y += chargeVy * dt;
      if (chargeTimer <= 0) {
        isCharging = false;
        chargeCooldown = chargeCooldownMax;
      }
    } else {
      // 检测玩家是否在冲锋范围内
      final cx = x + width / 2;
      final cy = y + height / 2;
      final dx = (player.x + player.width / 2) - cx;
      final dy = (player.y + player.height / 2) - cy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 280 && chargeCooldown <= 0 && dist > 1) {
        // 开始冲锋
        isCharging = true;
        chargeTimer = chargeDuration;
        chargeHitDone = false;
        chargeVx = (dx / dist) * chargeSpeed;
        chargeVy = (dy / dist) * chargeSpeed;
      } else if (dist < 400 && dist > 1) {
        // 缓慢接近
        x += (dx / dist) * speed * 0.5 * dt;
        y += (dy / dist) * speed * 0.5 * dt;
      }
    }

    x = x.clamp(0.0, worldW - width);
    y = y.clamp(0.0, worldH - height);
  }

  // ==================== 炸弹怪 ====================

  void _updateBomb(double dt, Player player, double worldW, double worldH) {
    final cx = x + width / 2;
    final cy = y + height / 2;
    final dx = (player.x + player.width / 2) - cx;
    final dy = (player.y + player.height / 2) - cy;
    final dist = sqrt(dx * dx + dy * dy);

    if (fuseLit) {
      // 引信燃烧中，不动
      fuseTimer -= dt;
      if (fuseTimer <= 0) {
        hasExploded = true; // 由世界处理爆炸伤害和粒子
      }
    } else {
      // 接近玩家
      if (dist > 1) {
        x += (dx / dist) * speed * dt;
        y += (dy / dist) * speed * dt;
      }
      // 进入爆炸范围则点燃引信
      if (dist < 70) {
        fuseLit = true;
        fuseTimer = fuseDuration;
      }
    }

    x = x.clamp(0.0, worldW - width);
    y = y.clamp(0.0, worldH - height);
  }

  // ==================== BOSS ====================

  void _updateBoss(double dt, Player player, double worldW, double worldH) {
    final cx = x + width / 2;
    final cy = y + height / 2;
    final px = player.x + player.width / 2;
    final py = player.y + player.height / 2;
    final dx = px - cx;
    final dy = py - cy;
    final dist = sqrt(dx * dx + dy * dy);

    // 近战攻击窗口
    if (bossMeleeActive) {
      bossMeleeTimer -= dt;
      if (bossMeleeTimer <= 0) bossMeleeActive = false;
    }

    // 冷却计时
    if (bossMeleeCooldown > 0) {
      bossMeleeCooldown -= dt;
      if (bossMeleeCooldown < 0) bossMeleeCooldown = 0;
    }
    if (bossRangedCooldown > 0) {
      bossRangedCooldown -= dt;
      if (bossRangedCooldown < 0) bossRangedCooldown = 0;
    }

    // 移动：缓慢接近玩家
    if (dist > 120 && dist > 1) {
      x += (dx / dist) * speed * dt;
      y += (dy / dist) * speed * dt;
    }

    // 近战攻击
    if (dist < 110 && bossMeleeCooldown <= 0) {
      bossMeleeCooldown = bossMeleeInterval;
      bossMeleeActive = true;
      bossMeleeTimer = 0.3;
    }

    // 远程火球
    if (dist >= 110 && bossRangedCooldown <= 0 && dist < 600) {
      bossRangedCooldown = bossRangedInterval;
      const spd = 260.0;
      pendingShots.add(Projectile(
        type: ProjectileType.fireball,
        fromPlayer: false,
        x: cx - 14,
        y: cy - 14,
        vx: (dx / dist) * spd,
        vy: (dy / dist) * spd,
        damage: 2,
        life: 4.0,
      ));
    }

    x = x.clamp(0.0, worldW - width);
    y = y.clamp(0.0, worldH - height);
  }

  // ==================== 受伤 ====================

  bool takeDamage(int damage) {
    if (isDead) return true;
    hp -= damage;
    hitFlash = 0.15;
    if (hp <= 0) {
      hp = 0;
      isDead = true;
      deathTimer = 0;
      return true;
    }
    return false;
  }

  bool get deathComplete => isDead && deathTimer >= deathDuration;

  /// 是否为BOSS
  bool get isBoss => type == EnemyType.boss;

  /// BOSS 血量比例（0~1）
  double get bossHpRatio => isBoss ? hp / maxHp : 0;
}
