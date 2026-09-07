import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../models/game_state.dart';
import '../models/item.dart';

/// Player movement / action state.
enum PlayerState { idle, walking, usingAxe, usingPick, usingSword }

/// Facing direction.
enum Facing { down, left, right, up }

/// The player character with animations, movement, and collision.
class PlayerComponent extends PositionComponent with CollisionCallbacks {
  final GameState gameState;

  // Animation sets: map of (state, facing) -> SpriteAnimation
  final Map<(PlayerState, Facing), SpriteAnimation> _animations = {};
  SpriteAnimation? _currentAnim;
  SpriteAnimationTicker? _currentTicker;
  Sprite? _fallbackSprite;

  // Input
  Vector2 movementInput = Vector2.zero();
  bool _actionPressed = false;
  PlayerState _state = PlayerState.idle;
  Facing _facing = Facing.down;

  // Movement
  static const double speed = 140.0;
  static const double playerWidth = 24;
  static const double playerHeight = 28;

  // Action timing
  double _actionTimer = 0;
  static const double actionDuration = 0.4;
  bool _actionConsumed = false;

  // Collision
  late RectangleHitbox _hitbox;
  final List<PositionComponent> _colliding = [];

  // Callbacks
  void Function()? onAction;
  void Function(Vector2 position)? onPositionChanged;

  PlayerComponent({
    required this.gameState,
    required Map<(PlayerState, Facing), SpriteAnimation> animations,
    Sprite? fallbackSprite,
  }) : super(
          position: Vector2(gameState.playerX, gameState.playerY),
          size: Vector2(32, 32),
          anchor: Anchor.center,
        ) {
    _animations.addAll(animations);
    _fallbackSprite = fallbackSprite;
    _updateAnimation();
  }

  Facing get facing => _facing;
  PlayerState get state => _state;
  bool get isUsingTool =>
      _state == PlayerState.usingAxe ||
      _state == PlayerState.usingPick ||
      _state == PlayerState.usingSword;

  @override
  Future<void> onLoad() async {
    _hitbox = RectangleHitbox(
      size: Vector2(playerWidth, playerHeight),
      position: Vector2((32 - playerWidth) / 2, (32 - playerHeight) / 2 + 2),
      isSolid: true,
    );
    add(_hitbox);
  }

  /// Set movement input from joystick/keyboard.
  void setMovement(Vector2 input) {
    movementInput = input;
  }

  /// Trigger an action (attack/gather/use tool).
  void triggerAction() {
    if (isUsingTool) return;
    _actionPressed = true;
    _actionTimer = 0;
    _actionConsumed = false;

    final selected = gameState.inventory.selectedSlot;
    if (!selected.isEmpty) {
      switch (selected.itemId) {
        case Items.axe:
          _state = PlayerState.usingAxe;
          break;
        case Items.pickaxe:
          _state = PlayerState.usingPick;
          break;
        case Items.sword:
          _state = PlayerState.usingSword;
          break;
        default:
          _state = PlayerState.usingAxe; // generic use
      }
    } else {
      _state = PlayerState.usingAxe;
    }
    _updateAnimation();
  }

  /// Get the world position in front of the player (for interaction).
  Vector2 getInteractionPoint() {
    const double reach = 36.0;
    switch (_facing) {
      case Facing.down:
        return Vector2(position.x, position.y + reach);
      case Facing.up:
        return Vector2(position.x, position.y - reach);
      case Facing.left:
        return Vector2(position.x - reach, position.y);
      case Facing.right:
        return Vector2(position.x + reach, position.y);
    }
  }

  /// Get direction as a string for combat system.
  String get directionString {
    switch (_facing) {
      case Facing.down:
        return 'down';
      case Facing.up:
        return 'up';
      case Facing.left:
        return 'left';
      case Facing.right:
        return 'right';
    }
  }

  void _updateAnimation() {
    final key = (_state, _facing);
    _currentAnim = _animations[key];
    _currentTicker = _currentAnim?.createTicker();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle action state
    if (isUsingTool) {
      _actionTimer += dt;
      // Fire action callback at midpoint
      if (!_actionConsumed && _actionTimer >= actionDuration * 0.3) {
        _actionConsumed = true;
        onAction?.call();
      }
      if (_actionTimer >= actionDuration) {
        _state = PlayerState.idle;
        _actionPressed = false;
        _updateAnimation();
      }
    }

    // Movement
    if (!isUsingTool) {
      if (movementInput.length > 0.1) {
        _state = PlayerState.walking;
        // Normalize and move
        final dir = movementInput.normalized();
        final newPos = position + dir * speed * dt;

        // Check collision before moving
        bool canMoveX = true;
        bool canMoveY = true;
        for (final other in _colliding) {
          if (other is SolidObject) {
            final hb = other.hitboxRect;
            // Test X movement
            final testX = Rect.fromLTWH(
              newPos.x - playerWidth / 2,
              position.y - playerHeight / 2,
              playerWidth,
              playerHeight,
            );
            if (testX.overlaps(hb)) canMoveX = false;
            // Test Y movement
            final testY = Rect.fromLTWH(
              position.x - playerWidth / 2,
              newPos.y - playerHeight / 2,
              playerWidth,
              playerHeight,
            );
            if (testY.overlaps(hb)) canMoveY = false;
          }
        }

        if (canMoveX) position.x = newPos.x;
        if (canMoveY) position.y = newPos.y;

        // Update facing based on dominant axis
        if (dir.x.abs() > dir.y.abs()) {
          if (dir.x > 0) {
            if (_facing != Facing.right) {
              _facing = Facing.right;
              _updateAnimation();
            }
          } else {
            if (_facing != Facing.left) {
              _facing = Facing.left;
              _updateAnimation();
            }
          }
        } else {
          if (dir.y > 0) {
            if (_facing != Facing.down) {
              _facing = Facing.down;
              _updateAnimation();
            }
          } else {
            if (_facing != Facing.up) {
              _facing = Facing.up;
              _updateAnimation();
            }
          }
        }
      } else {
        if (_state != PlayerState.idle) {
          _state = PlayerState.idle;
          _updateAnimation();
        }
      }
    }

    // Update animation
    _currentTicker?.update(dt);

    // Sync to game state
    gameState.playerX = position.x;
    gameState.playerY = position.y;
    onPositionChanged?.call(position);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_currentTicker != null) {
      final sprite = _currentTicker!.getSprite();
      sprite.render(
        canvas,
        position: Vector2(0, 0),
        size: Vector2(32, 32),
      );
    } else if (_fallbackSprite != null) {
      _fallbackSprite!.render(
        canvas,
        position: Vector2(0, 0),
        size: Vector2(32, 32),
      );
    } else {
      // Fallback colored rectangle
      canvas.drawRect(
        Rect.fromLTWH(4, 2, 24, 28),
        Paint()..color = const Color(0xFF4A90D9),
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_colliding.contains(other)) _colliding.add(other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    _colliding.remove(other);
  }
}

/// Mixin for objects that block player movement.
mixin SolidObject on PositionComponent {
  Rect get hitboxRect;
}
