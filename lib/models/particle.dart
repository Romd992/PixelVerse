import 'dart:math';
import 'package:flutter/material.dart';

/// 粒子特效（攻击火花、死亡爆炸、拾取闪光）
class Particle {
  double x;
  double y;
  double vx;
  double vy;

  /// 已存活时间
  double age = 0;

  /// 总寿命（秒）
  final double maxLife;

  /// 颜色
  final Color color;

  /// 初始大小
  final double startSize;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.color,
    this.startSize = 6,
  });

  /// 当前大小（随寿命缩小）
  double get size => startSize * (1 - age / maxLife);

  /// 当前透明度
  double get opacity => (1 - age / maxLife).clamp(0.0, 1.0);

  bool get dead => age >= maxLife;

  void update(double dt) {
    age += dt;
    x += vx * dt;
    y += vy * dt;
    // 轻微减速
    vx *= 0.92;
    vy *= 0.92;
  }
}

/// 粒子生成工具
class ParticleEmitter {
  /// 在指定位置生成一次爆炸粒子
  static List<Particle> burst(
    double x,
    double y,
    Color color, {
    int count = 12,
    double speed = 120,
    double life = 0.5,
    double size = 6,
  }) {
    final rng = Random();
    return List.generate(count, (i) {
      final angle = rng.nextDouble() * 2 * pi;
      final spd = speed * (0.4 + rng.nextDouble() * 0.6);
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * spd,
        vy: sin(angle) * spd,
        maxLife: life * (0.6 + rng.nextDouble() * 0.4),
        color: color,
        startSize: size,
      );
    });
  }

  /// 命中火花（小范围）
  static List<Particle> hitSparks(double x, double y) =>
      burst(x, y, const Color(0xFFFFD700), count: 8, speed: 100, life: 0.3, size: 5);

  /// 敌人死亡爆炸
  static List<Particle> deathExplosion(double x, double y, Color color) =>
      burst(x, y, color, count: 16, speed: 150, life: 0.6, size: 7);

  /// 拾取闪光
  static List<Particle> pickupFlash(double x, double y) =>
      burst(x, y, const Color(0xFF00FF88), count: 10, speed: 80, life: 0.4, size: 5);

  /// 升级光环
  static List<Particle> levelUpBurst(double x, double y) =>
      burst(x, y, const Color(0xFF00BFFF), count: 24, speed: 180, life: 0.8, size: 8);
}
