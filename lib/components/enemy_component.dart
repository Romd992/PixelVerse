import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';
import 'player_component.dart' show pixelPaint, SolidObject;
import 'shadow_component.dart';
import 'damage_number.dart';

/// Enemy types.
enum EnemyType { slime, bat, skeleton }

/// Enemy with AI, hit feedback, shadow, and damage numbers.
class EnemyComponent extends PositionComponent with SolidObject, CollisionCallbacks {
  final EnemyType type;
  final SpriteAnimation? animation;
  final Sprite? fallbackSprite;
  late final SpriteAnimationTicker? _animTicker;
  ShadowComponent? _shadow;

  int health;
  final int maxHealth;
  final int damage;
  final double speed;
  final bool flying;

  late RectangleHitbox _hitbox;
  final Random _rand = Random();

  static const double spriteSize = 48.0;

  // AI
  Vector2? _playerPos;
  double _attackCooldown = 0;
  static const double attackCooldown = 1.0;

  // Hit feedback
  double _hitFlashTimer = 0;
  static const double hitFlashDuration = 0.1;
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
    Sprite? shadowSprite,
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
          size: Vector2(spriteSize, spriteSize),
          anchor: Anchor.center,
        ) {
    _shadow = ShadowComponent(
      position: Vector2(0, spriteSize / 2 - 2),
      sprite: shadowSprite,
      shadowWidth: flying ? 20 : 28,
      shadowHeight: flying ? 6 : 8,
    );
  }

  factory EnemyComponent.byType(
    EnemyType type,
    Vector2 position, {
    SpriteAnimation? animation,
    Sprite? fallbackSprite,
    Sprite? shadowSprite,
  }) {
    switch (type) {
      case EnemyType.slime:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          shadowSprite: shadowSprite,
          health: 3,
          damage: 1,
          speed: 38,
          flying: false,
        );
      case EnemyType.bat:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          shadowSprite: shadowSprite,
          health: 2,
          damage: 1,
          speed: 75,
          flying: true,
        );
      case EnemyType.skeleton:
        return EnemyComponent(
          type: type,
          position: position,
          animation: animation,
          fallbackSprite: fallbackSprite,
          shadowSprite: shadowSprite,
          health: 5,
          damage: 2,
          speed: 48,
          flying: false,
        );
    }
  }

  @override
  Future<void> onLoad() async {
    add(_shadow!);
    _hitbox = RectangleHitbox(
      size: Vector2(28, 28),
      position: Vector2(
        (spriteSize - 28) / 2,
        spriteSize - 28 - 4,
      ),
      isSolid: true,
    );
    add(_hitbox);
  }

  @override
  Rect get hitboxRect {
    final topLeft = positionOfAnchor(Anchor.topLeft);
    return Rect.fromLTWH(
      topLeft.x + (spriteSize - 28) / 2,
      topLeft.y + spriteSize - 28 - 4,
      28,
      28,
    );
  }

  void updatePlayerPosition(Vector2 pos) {
    _playerPos = pos.clone();
  }

  /// Apply damage with knockback and flash. Returns true if dead.
  bool takeDamage(int amount, Vector2 fromPosition) {
    health -= amount;
    _hitFlashTimer = hitFlashDuration;

    final dir = (position - fromPosition).normalized();
    _knockbackVel = dir * 160;
    _knockbackTimer = 0.18;

    // Damage number
    final dmg = DamageNumber(
      position: position + Vector2(0, -spriteSize / 2),
      damage: amount,
    );
    parent?.add(dmg);

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

    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;

    // Knockback
    if (_knockbackTimer > 0) {
      _knockbackTimer -= dt;
      position += _knockbackVel * dt;
      _knockbackVel *= 0.85;
      return;
    }

    // Chase player
    if (_playerPos != null) {
      final diff = _playerPos! - position;
      final dist = diff.length;

      if (dist > 30) {
        final dir = diff.normalized();
        if (flying) {
          final wobble = Vector2(
            sin(_rand.nextDouble() * 2 * pi) * 0.25,
            cos(_rand.nextDouble() * 2 * pi) * 0.25,
          );
          position += (dir + wobble).normalized() * speed * dt;
        } else {
          position += dir * speed * dt;
        }
      } else if (_attackCooldown <= 0) {
        _attackCooldown = attackCooldown;
        onPlayerHit?.call(damage);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Always use code-drawn fallback (Flame 1.18 + Web CanvasKit sprite issue)
    final baseColor = _hitFlashTimer > 0 ? const Color(0xFFFFFFFF) : _fallbackColor();
    final cx = spriteSize / 2;
    final cy = spriteSize / 2;

    switch (type) {
      case EnemyType.slime:
        // Green blob: semicircle body + eyes
        canvas.drawOval(
          Rect.fromLTWH(cx - 16, cy - 4, 32, 24),
          Paint()..color = baseColor,
        );
        canvas.drawCircle(Offset(cx - 6, cy + 2), 3, Paint()..color = const Color(0xFFFFFFFF));
        canvas.drawCircle(Offset(cx + 6, cy + 2), 3, Paint()..color = const Color(0xFFFFFFFF));
        canvas.drawCircle(Offset(cx - 6, cy + 2), 1.5, Paint()..color = const Color(0xFF000000));
        canvas.drawCircle(Offset(cx + 6, cy + 2), 1.5, Paint()..color = const Color(0xFF000000));
        break;
      case EnemyType.bat:
        // Purple bat: body + wings
        canvas.drawOval(
          Rect.fromLTWH(cx - 8, cy - 6, 16, 16),
          Paint()..color = baseColor,
        );
        final wingPath = Path()
          ..moveTo(cx - 8, cy)
          ..lineTo(cx - 22, cy - 8)
          ..lineTo(cx - 16, cy + 4)
          ..close();
        canvas.drawPath(wingPath, Paint()..color = baseColor);
        final wingPath2 = Path()
          ..moveTo(cx + 8, cy)
          ..lineTo(cx + 22, cy - 8)
          ..lineTo(cx + 16, cy + 4)
          ..close();
        canvas.drawPath(wingPath2, Paint()..color = baseColor);
        canvas.drawCircle(Offset(cx - 3, cy - 2), 2, Paint()..color = const Color(0xFFFF0000));
        canvas.drawCircle(Offset(cx + 3, cy - 2), 2, Paint()..color = const Color(0xFFFF0000));
        break;
      case EnemyType.skeleton:
        // White skeleton: skull + body
        canvas.drawRect(
          Rect.fromLTWH(cx - 10, cy - 18, 20, 16),
          Paint()..color = baseColor,
        );
        canvas.drawRect(
          Rect.fromLTWH(cx - 8, cy - 2, 16, 18),
          Paint()..color = baseColor,
        );
        canvas.drawCircle(Offset(cx - 4, cy - 12), 2.5, Paint()..color = const Color(0xFF000000));
        canvas.drawCircle(Offset(cx + 4, cy - 12), 2.5, Paint()..color = const Color(0xFF000000));
        canvas.drawRect(Rect.fromLTWH(cx - 3, cy - 6, 6, 2), Paint()..color = const Color(0xFF000000));
        break;
    }

    // Health bar
    if (health < maxHealth) {
      const barW = 36.0;
      const barH = 5.0;
      final barX = (spriteSize - barW) / 2;
      const barY = -8.0;
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
