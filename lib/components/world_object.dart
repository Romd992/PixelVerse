import 'package:flutter/painting.dart';
import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'player_component.dart';

/// Types of world objects.
enum WorldObjectType {
  tree,
  rock,
  bush,
  house,
  shop,
  bed,
  mineEntrance,
  chest,
  furnace,
  workbench,
  torch,
  plankFloor,
}

/// A static or placed object in the world (tree, rock, building, etc.).
class WorldObject extends PositionComponent with SolidObject, CollisionCallbacks {
  final WorldObjectType type;
  final Sprite? sprite;
  final int health;
  int currentHealth;
  final bool destructible;
  final bool interactive;
  final String? label;

  late RectangleHitbox _hitbox;
  final Random _rand = Random();

  // Tree sway
  double _swayTimer = 0;
  final double _swayPhase = Random().nextDouble() * 2 * pi;

  // For placed objects that can be removed
  final bool isPlaced;

  // Callback when destroyed
  void Function(WorldObject obj)? onDestroyed;
  // Callback when interacted (bed, mine entrance, etc.)
  void Function(WorldObject obj)? onInteract;

  WorldObject({
    required this.type,
    required Vector2 position,
    Vector2? size,
    this.sprite,
    this.health = 3,
    this.destructible = true,
    this.interactive = false,
    this.label,
    this.isPlaced = false,
    this.onDestroyed,
    this.onInteract,
  })  : currentHealth = health,
        super(
          position: position,
          size: size ?? _defaultSize(type),
          anchor: Anchor.bottomCenter,
        );

  static Vector2 _defaultSize(WorldObjectType type) {
    switch (type) {
      case WorldObjectType.tree:
        return Vector2(48, 64);
      case WorldObjectType.rock:
        return Vector2(32, 32);
      case WorldObjectType.bush:
        return Vector2(32, 32);
      case WorldObjectType.house:
        return Vector2(96, 80);
      case WorldObjectType.shop:
        return Vector2(96, 80);
      case WorldObjectType.bed:
        return Vector2(32, 48);
      case WorldObjectType.mineEntrance:
        return Vector2(64, 64);
      case WorldObjectType.chest:
        return Vector2(32, 24);
      case WorldObjectType.furnace:
        return Vector2(32, 32);
      case WorldObjectType.workbench:
        return Vector2(32, 24);
      case WorldObjectType.torch:
        return Vector2(16, 32);
      case WorldObjectType.plankFloor:
        return Vector2(32, 32);
    }
  }

  bool get isSolid => type != WorldObjectType.plankFloor &&
      type != WorldObjectType.torch;

  @override
  Future<void> onLoad() async {
    if (isSolid) {
      double hbW = size.x * 0.7;
      double hbH = size.y * 0.35;
      if (type == WorldObjectType.tree) {
        hbW = 20;
        hbH = 12;
      } else if (type == WorldObjectType.rock) {
        hbW = 24;
        hbH = 16;
      } else if (type == WorldObjectType.house ||
          type == WorldObjectType.shop) {
        hbW = size.x * 0.85;
        hbH = size.y * 0.5;
      }
      _hitbox = RectangleHitbox(
        size: Vector2(hbW, hbH),
        position: Vector2((size.x - hbW) / 2, size.y - hbH),
        isSolid: true,
      );
      add(_hitbox);
    }
  }

  @override
  Rect get hitboxRect {
    final topLeft = positionOfAnchor(Anchor.topLeft);
    return Rect.fromLTWH(
      topLeft.x + (size.x - size.x * 0.7) / 2,
      topLeft.y + size.y - size.y * 0.35,
      size.x * 0.7,
      size.y * 0.35,
    );
  }

  /// Apply damage to this object. Returns true if destroyed.
  bool takeDamage(int amount) {
    if (!destructible) return false;
    currentHealth -= amount;
    if (currentHealth <= 0) {
      onDestroyed?.call(this);
      return true;
    }
    return false;
  }

  /// Get the center position for drop spawning.
  Vector2 get dropPosition => position + Vector2(0, -size.y / 2);

  @override
  void update(double dt) {
    super.update(dt);
    if (type == WorldObjectType.tree) {
      _swayTimer += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Tree sway: rotate slightly around base
    if (type == WorldObjectType.tree) {
      final sway = sin(_swayTimer * 1.5 + _swayPhase) * 0.03;
      canvas.save();
      canvas.translate(size.x / 2, size.y);
      canvas.rotate(sway);
      canvas.translate(-size.x / 2, -size.y);
      _renderSprite(canvas);
      canvas.restore();
      return;
    }

    _renderSprite(canvas);
  }

  void _renderSprite(Canvas canvas) {
    // Always use code-drawn fallback (Flame 1.18 + Web CanvasKit sprite issue)
    final w = size.x;
    final h = size.y;
    switch (type) {
      case WorldObjectType.tree:
        // Trunk
        canvas.drawRect(
          Rect.fromLTWH(w / 2 - 5, h - 20, 10, 20),
          Paint()..color = const Color(0xFF6D4C2A),
        );
        // Canopy (3 circles)
        canvas.drawCircle(Offset(w / 2, h - 32), 18, Paint()..color = const Color(0xFF2D5A27));
        canvas.drawCircle(Offset(w / 2 - 10, h - 26), 12, Paint()..color = const Color(0xFF3A7D32));
        canvas.drawCircle(Offset(w / 2 + 10, h - 26), 12, Paint()..color = const Color(0xFF3A7D32));
        break;
      case WorldObjectType.rock:
        // Gray polygon
        final path = Path()
          ..moveTo(w * 0.2, h)
          ..lineTo(w * 0.1, h * 0.5)
          ..lineTo(w * 0.3, h * 0.15)
          ..lineTo(w * 0.7, h * 0.1)
          ..lineTo(w * 0.9, h * 0.45)
          ..lineTo(w * 0.8, h)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF808080));
        canvas.drawPath(path, Paint()..color = const Color(0xFF555555)..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
      case WorldObjectType.bush:
        // Green circle + red berries
        canvas.drawCircle(Offset(w / 2, h / 2 + 4), w * 0.4, Paint()..color = const Color(0xFF3A7D32));
        canvas.drawCircle(Offset(w * 0.35, h * 0.45), 3, Paint()..color = const Color(0xFFE74C3C));
        canvas.drawCircle(Offset(w * 0.6, h * 0.4), 3, Paint()..color = const Color(0xFFE74C3C));
        canvas.drawCircle(Offset(w * 0.5, h * 0.6), 3, Paint()..color = const Color(0xFFE74C3C));
        break;
      case WorldObjectType.house:
        // Body
        canvas.drawRect(Rect.fromLTWH(0, h * 0.35, w, h * 0.65), Paint()..color = const Color(0xFF8B4513));
        // Roof (triangle)
        final roof = Path()
          ..moveTo(0, h * 0.35)
          ..lineTo(w / 2, 0)
          ..lineTo(w, h * 0.35)
          ..close();
        canvas.drawPath(roof, Paint()..color = const Color(0xFFB22222));
        // Door
        canvas.drawRect(Rect.fromLTWH(w / 2 - 8, h * 0.6, 16, h * 0.4), Paint()..color = const Color(0xFF5D3A1A));
        // Window
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.5, 14, 14), Paint()..color = const Color(0xFF87CEEB));
        canvas.drawRect(Rect.fromLTWH(w * 0.7, h * 0.5, 14, 14), Paint()..color = const Color(0xFF87CEEB));
        break;
      case WorldObjectType.shop:
        // Body
        canvas.drawRect(Rect.fromLTWH(0, h * 0.3, w, h * 0.7), Paint()..color = const Color(0xFF4169E1));
        // Awning
        canvas.drawRect(Rect.fromLTWH(0, h * 0.25, w, h * 0.1), Paint()..color = const Color(0xFFFFD700));
        // Roof
        final roof = Path()
          ..moveTo(0, h * 0.3)
          ..lineTo(w / 2, h * 0.05)
          ..lineTo(w, h * 0.3)
          ..close();
        canvas.drawPath(roof, Paint()..color = const Color(0xFF2E4A8E));
        // Door
        canvas.drawRect(Rect.fromLTWH(w / 2 - 8, h * 0.55, 16, h * 0.45), Paint()..color = const Color(0xFF8B4513));
        // Sign
        canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.32, w * 0.4, 12), Paint()..color = const Color(0xFFFFFF));
        break;
      case WorldObjectType.bed:
        // Frame
        canvas.drawRect(Rect.fromLTWH(0, h * 0.2, w, h * 0.8), Paint()..color = const Color(0xFFCD853F));
        // Mattress
        canvas.drawRect(Rect.fromLTWH(2, h * 0.35, w - 4, h * 0.55), Paint()..color = const Color(0xFFF5F5DC));
        // Pillow
        canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.25, w * 0.35, h * 0.15), Paint()..color = const Color(0xFFFFFFFF));
        break;
      case WorldObjectType.mineEntrance:
        // Dark arch
        canvas.drawRect(Rect.fromLTWH(0, h * 0.3, w, h * 0.7), Paint()..color = const Color(0xFF4A4A4A));
        final arch = Path()
          ..moveTo(0, h * 0.5)
          ..quadraticBezierTo(w / 2, 0, w, h * 0.5)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(arch, Paint()..color = const Color(0xFF1A1A1A));
        break;
      case WorldObjectType.chest:
        // Body
        canvas.drawRect(Rect.fromLTWH(0, h * 0.3, w, h * 0.7), Paint()..color = const Color(0xFFB8860B));
        // Lid
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.35), Paint()..color = const Color(0xFFDAA520));
        // Lock
        canvas.drawRect(Rect.fromLTWH(w / 2 - 4, h * 0.25, 8, 10), Paint()..color = const Color(0xFFFFD700));
        break;
      case WorldObjectType.furnace:
        // Body
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF696969));
        // Fire opening
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.5), Paint()..color = const Color(0xFF1A1A1A));
        // Flame
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.55, w * 0.3, h * 0.3), Paint()..color = const Color(0xFFFF6600));
        break;
      case WorldObjectType.workbench:
        // Top
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.35), Paint()..color = const Color(0xFFA0522D));
        // Legs
        canvas.drawRect(Rect.fromLTWH(2, h * 0.35, 6, h * 0.65), Paint()..color = const Color(0xFF6D4C2A));
        canvas.drawRect(Rect.fromLTWH(w - 8, h * 0.35, 6, h * 0.65), Paint()..color = const Color(0xFF6D4C2A));
        // Tools on top
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.05, 8, h * 0.25), Paint()..color = const Color(0xFF808080));
        break;
      case WorldObjectType.torch:
        // Handle
        canvas.drawRect(Rect.fromLTWH(w / 2 - 2, h * 0.3, 4, h * 0.7), Paint()..color = const Color(0xFF6D4C2A));
        // Flame
        canvas.drawCircle(Offset(w / 2, h * 0.2), 6, Paint()..color = const Color(0xFFFF6600));
        canvas.drawCircle(Offset(w / 2, h * 0.18), 3, Paint()..color = const Color(0xFFFFFF00));
        break;
      case WorldObjectType.plankFloor:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFC4A35A));
        // Wood grain lines
        for (int i = 0; i < 3; i++) {
          canvas.drawRect(
            Rect.fromLTWH(0, h * (0.25 + i * 0.25), w, 1),
            Paint()..color = const Color(0xFF8B6914),
          );
        }
        break;
    }
  }
}
