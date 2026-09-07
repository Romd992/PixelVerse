import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// An elliptical shadow rendered under characters.
class ShadowComponent extends PositionComponent {
  final Sprite? sprite;
  final double shadowWidth;
  final double shadowHeight;

  ShadowComponent({
    required Vector2 position,
    this.sprite,
    this.shadowWidth = 36,
    this.shadowHeight = 12,
  }) : super(
          position: position,
          size: Vector2(shadowWidth, shadowHeight),
          anchor: Anchor.center,
          priority: -1,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2(-shadowWidth / 2, -shadowHeight / 2),
        size: Vector2(shadowWidth, shadowHeight),
        overridePaint: Paint()..color = const Color(0xFF000000).withOpacity(0.35),
      );
    } else {
      // Fallback: semi-transparent ellipse
      final paint = Paint()
        ..color = const Color(0xFF000000).withOpacity(0.3)
        ..isAntiAlias = true;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(shadowWidth / 2, shadowHeight / 2),
          width: shadowWidth,
          height: shadowHeight,
        ),
        paint,
      );
    }
  }
}
