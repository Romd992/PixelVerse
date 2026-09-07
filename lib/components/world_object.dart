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
    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2(0, 0),
        size: size,
        overridePaint: Paint()..filterQuality = FilterQuality.none,
      );
    } else {
      final color = _fallbackColor();
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = color,
      );
    }
  }

  Color _fallbackColor() {
    switch (type) {
      case WorldObjectType.tree:
        return const Color(0xFF2D5A27);
      case WorldObjectType.rock:
        return const Color(0xFF808080);
      case WorldObjectType.bush:
        return const Color(0xFF3A7D32);
      case WorldObjectType.house:
        return const Color(0xFF8B4513);
      case WorldObjectType.shop:
        return const Color(0xFF4169E1);
      case WorldObjectType.bed:
        return const Color(0xFFCD853F);
      case WorldObjectType.mineEntrance:
        return const Color(0xFF4A4A4A);
      case WorldObjectType.chest:
        return const Color(0xFFB8860B);
      case WorldObjectType.furnace:
        return const Color(0xFF696969);
      case WorldObjectType.workbench:
        return const Color(0xFFA0522D);
      case WorldObjectType.torch:
        return const Color(0xFFFFA500);
      case WorldObjectType.plankFloor:
        return const Color(0xFFC4A35A);
    }
  }
}
