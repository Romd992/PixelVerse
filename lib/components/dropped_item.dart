import 'package:flutter/painting.dart';
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import '../models/item.dart';

/// A dropped item in the world that can be picked up.
class DroppedItem extends PositionComponent {
  final int itemId;
  int count;
  final Sprite? sprite;

  final Random _rand = Random();
  double _bobTimer = 0;
  double _lifeTimer = 0;
  static const double maxLife = 120; // despawn after 2 minutes

  // Pickup
  bool _pickedUp = false;
  void Function(DroppedItem item)? onPickup;

  DroppedItem({
    required this.itemId,
    required Vector2 position,
    this.count = 1,
    this.sprite,
    this.onPickup,
  }) : super(
          position: position,
          size: Vector2(16, 16),
          anchor: Anchor.center,
        );

  ItemDef get itemDef => Items.getById(itemId);

  /// Try to pick up this item. Returns true if picked up.
  bool tryPickup(Vector2 playerPos, {double range = 32}) {
    if (_pickedUp) return false;
    final dx = playerPos.x - position.x;
    final dy = playerPos.y - position.y;
    if (dx * dx + dy * dy < range * range) {
      _pickedUp = true;
      onPickup?.call(this);
      return true;
    }
    return false;
  }

  /// Magnet: move toward player if close.
  void updateMagnet(Vector2 playerPos, double dt) {
    final dx = playerPos.x - position.x;
    final dy = playerPos.y - position.y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 64 && dist > 0) {
      position += Vector2(dx / dist, dy / dist) * 120 * dt;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt;
    _lifeTimer += dt;
    if (_lifeTimer > maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final bobOffset = sin(_bobTimer * 3) * 2;

    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2(0, bobOffset),
        size: Vector2(16, 16),
      );
    } else {
      // Fallback: colored square based on item category
      final def = itemDef;
      Color color;
      switch (def.category) {
        case ItemCategory.tool:
          color = const Color(0xFFB0B0B0);
          break;
        case ItemCategory.resource:
          color = const Color(0xFF8B4513);
          break;
        case ItemCategory.seed:
          color = const Color(0xFF6B8E23);
          break;
        case ItemCategory.crop:
          color = const Color(0xFFFFA500);
          break;
        case ItemCategory.food:
          color = const Color(0xFFFF6347);
          break;
        case ItemCategory.material:
          color = const Color(0xFFDAA520);
          break;
        case ItemCategory.misc:
          color = const Color(0xFF00CED1);
          break;
      }
      canvas.drawRect(
        Rect.fromLTWH(2, 2 + bobOffset, 12, 12),
        Paint()..color = color,
      );
    }

    // Stack count
    if (count > 1) {
      final tp = TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.render(canvas, '$count', Vector2(14, 14),
          anchor: Anchor.bottomRight);
    }
  }
}
