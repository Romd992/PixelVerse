import 'package:flutter/painting.dart';
import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'player_component.dart';

/// Enemy types.
enum EnemyType { slime, bat, skeleton }

/// An enemy with simple AI (chase player) and combat.
class EnemyComponent extends PositionComponent with SolidObject, CollisionCallbacks {
  final EnemyType type;
  final SpriteAnimation? animation;
  final Sprite? fallbackSprite;
  late final SpriteAnimationTicker? _animTicker;

  int health;
  final int maxHealth;
  final int damage;
  final double speed;
  final bool flying;

  late RectangleHitbox _hitbox;
  final Random _rand = Random();

  // AI state
  Vector2? _playerPos;
  double _attackCooldown = 0;
  static const double attackCooldown = 1.0;
  double _knockbackTimer = 0;
  Vector2 _knockbackVel = Vector2.zero();

  // Callbacks
  void Function(EnemyComponent enemy)? onDeath;
  void Function(int damage)? onPlayerHit;

  EnemyComponent({
    required this.type,
    required Vector2 position,
    this.animation,
    this.fallbackSprite,
    this.health = 3,
    this.damage = 1,
    this.speed = 50,
    this.flying = false,
    this.onDeath,
    this.onPlayerHit,
  })  : maxHealth = health,
        _animTicker = animation?.createTicker(),
        super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  /// Create an enemy by type with default stats.
  factory EnemyComponent.byType(
    EnemyType type,
    Vector2 position, {
    SpriteAnimation? animation,
    Sprite? fallbackSprite,
  }) {
    switch (type) {
      case EnemyType.slime:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          health: 3,
          damage: 1,
          speed: 35,
          flying: false,
        );
      case EnemyType.bat:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          health: 2,
          damage: 1,
          speed: 70,
          flying: true,
        );
      case EnemyType.skeleton:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          health: 5,
          damage: 2,
          speed: 45,
          flying: false,
        );
    }
  }

  @override
  Future<void> onLoad() async {
    _hitbox = RectangleHitbox(
      size: Vector2(24, 24),
      position: Vector2(4, 4),
      isSolid: true,
    );
    add(_hitbox);
  }

  @override
  Rect get hitboxRect {
    final topLeft = positionOfAnchor(Anchor.topLeft);
    return Rect.fromLTWH(topLeft.x + 4, topLeft.y + 4, 24, 24);
  }

  /// Update the player's position for AI targeting.
  void updatePlayerPosition(Vector2 pos) {
    _playerPos = pos.clone();
  }

  /// Apply damage and knockback. Returns true if dead.
  bool takeDamage(int amount, Vector2 fromPosition) {
    health -= amount;
    // Knockback
    final dir = (position - fromPosition).normalized();
    _knockbackVel = dir * 150;
    _knockbackTimer = 0.2;

    if (health <= 0) {
      onDeath?.call(this);
      return true;
    }
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTicker?.update(dt);

    _attackCooldown -= dt;

    // Apply knockback
    if (_knockbackTimer > 0) {
      _knockbackTimer -= dt;
      position += _knockbackVel * dt;
      _knockbackVel *= 0.9;
      return;
    }

    // Chase player
    if (_playerPos != null) {
      final diff = _playerPos! - position;
      final dist = diff.length;

      if (dist > 24) {
        final dir = diff.normalized();
        // Add slight wobble for bats
        if (flying) {
          final wobble = Vector2(
            sin(_rand.nextDouble() * 2 * pi) * 0.3,
            cos(_rand.nextDouble() * 2 * pi) * 0.3,
          );
          position += (dir + wobble).normalized() * speed * dt;
        } else {
          position += dir * speed * dt;
        }
      } else if (_attackCooldown <= 0) {
        // Attack player
        _attackCooldown = attackCooldown;
        onPlayerHit?.call(damage);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_animTicker != null) {
      _animTicker!.getSprite().render(
            canvas,
            position: Vector2(0, 0),
            size: Vector2(32, 32),
          );
    } else if (fallbackSprite != null) {
      fallbackSprite!.render(
        canvas,
        position: Vector2(0, 0),
        size: Vector2(32, 32),
      );
    } else {
      final color = _fallbackColor();
      canvas.drawRect(
        Rect.fromLTWH(4, 4, 24, 24),
        Paint()..color = color,
      );
    }

    // Health bar
    if (health < maxHealth) {
      final barW = 28.0;
      final barH = 4.0;
      final barX = (32 - barW) / 2;
      final barY = -6.0;
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barW, barH),
        Paint()..color = const Color(0xFF333333),
      );
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barW * (health / maxHealth), barH),
        Paint()..color = const Color(0xFFE74C3C),
      );
    }
  }

  Color _fallbackColor() {
    switch (type) {
      case EnemyType.slime:
        return const Color(0xFF2ECC71);
      case EnemyType.bat:
        return const Color(0xFF6C3483);
      case EnemyType.skeleton:
        return const Color(0xFFECF0F1);
    }
  }
}
