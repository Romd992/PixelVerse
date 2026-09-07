import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:flame/components.dart';

/// A growing crop on tilled soil.
class CropComponent extends PositionComponent {
  final String cropType;
  int growthStage; // 0-4
  final bool mature;
  final bool watered;

  static const double tileSize = 32;

  CropComponent({
    required this.cropType,
    required Vector2 position,
    this.growthStage = 0,
    this.mature = false,
    this.watered = false,
  }) : super(
          position: position,
          size: Vector2(tileSize, tileSize),
          anchor: Anchor.bottomLeft,
        );

  /// Get the color for the crop based on type and growth stage.
  Color get _cropColor {
    if (growthStage == 0) return const Color(0xFF8B7355); // seed/dirt
    switch (cropType) {
      case 'Wheat':
        return mature ? const Color(0xFFF4D03F) : const Color(0xFF7CB342);
      case 'Carrot':
        return mature ? const Color(0xFFE67E22) : const Color(0xFF558B2F);
      case 'Potato':
        return mature ? const Color(0xFFD4A574) : const Color(0xFF689F38);
      default:
        return const Color(0xFF7CB342);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (growthStage == 0) {
      // Just a small seed marker
      canvas.drawCircle(
        const Offset(16, 24),
        3,
        Paint()..color = const Color(0xFF5D4037),
      );
      return;
    }

    final height = 4 + growthStage * 5.0;
    final width = 4 + growthStage * 3.0;

    // Stem
    canvas.drawRect(
      Rect.fromLTWH(
        tileSize / 2 - 2,
        tileSize - height,
        4,
        height,
      ),
      Paint()..color = const Color(0xFF558B2F),
    );

    // Leaves / crop body
    if (growthStage >= 2) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(tileSize / 2, tileSize - height),
          width: width,
          height: height * 0.7,
        ),
        Paint()..color = _cropColor,
      );
    }

    // Mature indicator
    if (mature) {
      final tp = TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.render(canvas, '!', Vector2(tileSize / 2, 6),
          anchor: Anchor.topCenter);
    }

    // Watered indicator (small blue dot)
    if (watered) {
      canvas.drawCircle(
        Offset(tileSize - 6, 6),
        3,
        Paint()..color = const Color(0xFF3498DB),
      );
    }
  }
}
