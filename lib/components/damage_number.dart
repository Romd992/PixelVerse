import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Floating damage number that rises and fades.
class DamageNumber extends PositionComponent {
  final int damage;
  final bool isPlayerDamage;
  final double life;
  double _elapsed = 0;
  static const double _duration = 0.8;
  static const double _riseSpeed = 40;

  late final TextPaint _textPaint;

  DamageNumber({
    required Vector2 position,
    required this.damage,
    this.isPlayerDamage = false,
  })  : life = _duration,
        super(
          position: position,
          anchor: Anchor.bottomCenter,
        ) {
    _textPaint = TextPaint(
      style: TextStyle(
        color: isPlayerDamage
            ? const Color(0xFFFF4444)
            : const Color(0xFFFFFF00),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            color: Color(0xFF000000),
            offset: Offset(1, 1),
            blurRadius: 0,
          ),
          Shadow(
            color: Color(0xFF000000),
            offset: Offset(-1, -1),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= _riseSpeed * dt;
    if (_elapsed >= life) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final alpha = 1 - (_elapsed / life);
    // Render text with opacity by using a transparent canvas layer
    canvas.save();
    canvas.translate(position.x, position.y);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '-$damage',
        style: _textPaint.style.copyWith(
          color: _textPaint.style.color?.withOpacity(alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height));
    canvas.restore();
  }
}
