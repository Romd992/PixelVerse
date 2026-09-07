import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

/// Types of particles.
enum ParticleType {
  hitSpark,
  pickup,
  leaf,
  dust,
}

/// A single particle with velocity, life, and optional sprite animation.
class ParticleComponent extends PositionComponent {
  final ParticleType type;
  final Vector2 velocity;
  double life;
  final double maxLife;
  final SpriteAnimation? animation;
  final SpriteAnimationTicker? _ticker;
  final Color color;
  final double startSize;
  final double endSize;
  final double gravity;
  final bool fadeOut;

  final Random _rand = Random();

  ParticleComponent({
    required Vector2 position,
    required this.type,
    required this.velocity,
    required this.life,
    this.animation,
    this.color = const Color(0xFFFFD700),
    this.startSize = 8,
    this.endSize = 2,
    this.gravity = 0,
    this.fadeOut = true,
  })  : maxLife = life,
        _ticker = animation?.createTicker(),
        super(
          position: position,
          size: Vector2.all(startSize),
          anchor: Anchor.center,
        );

  /// Create a burst of hit spark particles at a position.
  static List<ParticleComponent> hitSparkBurst(
    Vector2 position, {
    SpriteAnimation? sparkAnim,
    int count = 5,
  }) {
    final rand = Random();
    final particles = <ParticleComponent>[];
    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 60 + rand.nextDouble() * 100;
      particles.add(ParticleComponent(
        position: position.clone(),
        type: ParticleType.hitSpark,
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        life: 0.3 + rand.nextDouble() * 0.3,
        animation: sparkAnim,
        color: const Color(0xFFFFAA00),
        startSize: 10,
        endSize: 3,
        gravity: 200,
      ));
    }
    return particles;
  }

  /// Create pickup sparkle particles.
  static List<ParticleComponent> pickupSparkle(Vector2 position) {
    final rand = Random();
    final particles = <ParticleComponent>[];
    for (int i = 0; i < 4; i++) {
      particles.add(ParticleComponent(
        position: position.clone() +
            Vector2((rand.nextDouble() - 0.5) * 16, 0),
        type: ParticleType.pickup,
        velocity: Vector2(0, -60 - rand.nextDouble() * 40),
        life: 0.5 + rand.nextDouble() * 0.3,
        color: const Color(0xFFFFFF00),
        startSize: 6,
        endSize: 1,
      ));
    }
    return particles;
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    _ticker?.update(dt);
    velocity.y += gravity * dt;
    position += velocity * dt;
    final t = 1 - (life / maxLife);
    final currentSize = startSize + (endSize - startSize) * t;
    size = Vector2.all(currentSize);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final alpha = fadeOut ? (life / maxLife) : 1.0;

    if (_ticker != null) {
      _ticker!.getSprite().render(
            canvas,
            position: Vector2(-size.x / 2, -size.y / 2),
            size: size,
            overridePaint: Paint()..color = color.withOpacity(alpha),
          );
    } else {
      // Fallback: colored circle
      final paint = Paint()
        ..color = color.withOpacity(alpha)
        ..isAntiAlias = false;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        paint,
      );
    }
  }
}

/// A slash arc effect for sword attacks.
class SlashEffect extends PositionComponent {
  final double duration;
  double _elapsed = 0;
  final String direction;

  static const double _slashDuration = 0.2;

  SlashEffect({
    required Vector2 position,
    required this.direction,
  })  : duration = _slashDuration,
        super(
          position: position,
          size: Vector2(64, 64),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final t = _elapsed / duration;
    final alpha = (1 - t) * 0.7;

    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw arc based on direction
    switch (direction) {
      case 'right':
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(0, 32), radius: 36),
          -pi / 3,
          pi * 2 / 3 * t,
          false,
          paint,
        );
        break;
      case 'left':
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(48, 32), radius: 36),
          pi - pi / 3,
          -pi * 2 / 3 * t,
          false,
          paint,
        );
        break;
      case 'down':
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(32, 0), radius: 36),
          pi / 2 - pi / 3,
          pi * 2 / 3 * t,
          false,
          paint,
        );
        break;
      case 'up':
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(32, 64), radius: 36),
          -pi / 2 - pi / 3,
          -pi * 2 / 3 * t,
          false,
          paint,
        );
        break;
    }
  }
}
