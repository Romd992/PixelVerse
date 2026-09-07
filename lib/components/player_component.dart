import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import 'shadow_component.dart';
import 'damage_number.dart';

/// Player animation states.
enum PlayerAnimState { idle, walk, axe, pick, sword, hoe, water, hurt }

/// Facing direction.
enum Facing { down, left, right, up }

/// Shared pixel-perfect paint.
final Paint pixelPaint = Paint()..filterQuality = FilterQuality.none;

/// The player character with high-quality animations, shadows, and effects.
class PlayerComponent extends PositionComponent with CollisionCallbacks {
  final GameState gameState;

  // Animation sets: (state, facing) -> SpriteAnimation
  final Map<(PlayerAnimState, Facing), SpriteAnimation> _animations = {};
  SpriteAnimation? _currentAnim;
  SpriteAnimationTicker? _currentTicker;
  Sprite? _fallbackSprite;

  // Shadow
  ShadowComponent? _shadow;

  // State
  PlayerAnimState _state = PlayerAnimState.idle;
  Facing _facing = Facing.down;
  bool _isOneShotPlaying = false;
  double _oneShotTimer = 0;
  double _oneShotDuration = 0;
  bool _actionFired = false;

  // Input
  Vector2 movementInput = Vector2.zero();

  // Movement
  static const double speed = 150.0;
  static const double playerWidth = 22;
  static const double playerHeight = 26;
  static const double spriteSize = 48.0;

  // Hurt / invincibility
  double _hurtTimer = 0;
  static const double hurtDuration = 0.5;
  static const double hurtFlashInterval = 0.08;
  Vector2 _knockbackVel = Vector2.zero();
  double _knockbackTimer = 0;

  // Collision
  late RectangleHitbox _hitbox;
  final List<PositionComponent> _colliding = [];

  // Callbacks
  void Function()? onAction;
  void Function(Vector2 pos, int damage)? onDamageDealt;
  void Function()? onDamaged;

  PlayerComponent({
    required this.gameState,
    required Map<(PlayerAnimState, Facing), SpriteAnimation> animations,
    Sprite? fallbackSprite,
    Sprite? shadowSprite,
  }) : super(
          position: Vector2(gameState.playerX, gameState.playerY),
          size: Vector2(spriteSize, spriteSize),
          anchor: Anchor.center,
        ) {
    _animations.addAll(animations);
    _fallbackSprite = fallbackSprite;
    _shadow = ShadowComponent(
      position: Vector2(0, spriteSize / 2 - 4),
      sprite: shadowSprite,
      shadowWidth: 32,
      shadowHeight: 10,
    );
    _updateAnimation();
  }

  Facing get facing => _facing;
  PlayerAnimState get state => _state;
  bool get isUsingTool =>
      _state == PlayerAnimState.axe ||
      _state == PlayerAnimState.pick ||
      _state == PlayerAnimState.sword ||
      _state == PlayerAnimState.hoe ||
      _state == PlayerAnimState.water;
  bool get isHurt => _hurtTimer > 0;

  @override
  Future<void> onLoad() async {
    add(_shadow!);
    _hitbox = RectangleHitbox(
      size: Vector2(playerWidth, playerHeight),
      position: Vector2(
        (spriteSize - playerWidth) / 2,
        spriteSize - playerHeight - 4,
      ),
      isSolid: true,
    );
    add(_hitbox);
  }

  void setMovement(Vector2 input) {
    movementInput = input;
  }

  /// Trigger an action (attack/gather/use tool).
  void triggerAction() {
    if (_isOneShotPlaying || _hurtTimer > 0) return;

    final selected = gameState.inventory.selectedSlot;
    PlayerAnimState animState;
    double duration;

    if (!selected.isEmpty) {
      switch (selected.itemId) {
        case Items.axe:
          animState = PlayerAnimState.axe;
          duration = 0.08 * 4; // 4 frames
          break;
        case Items.pickaxe:
          animState = PlayerAnimState.pick;
          duration = 0.08 * 4;
          break;
        case Items.sword:
          animState = PlayerAnimState.sword;
          duration = 0.10 * 4;
          break;
        case Items.hoe:
          animState = PlayerAnimState.hoe;
          duration = 0.08 * 4;
          break;
        case Items.wateringCan:
          animState = PlayerAnimState.water;
          duration = 0.10 * 4;
          break;
        default:
          animState = PlayerAnimState.axe;
          duration = 0.08 * 4;
      }
    } else {
      animState = PlayerAnimState.axe;
      duration = 0.08 * 4;
    }

    _state = animState;
    _isOneShotPlaying = true;
    _oneShotTimer = 0;
    _oneShotDuration = duration;
    _actionFired = false;
    _updateAnimation();
  }

  /// Apply damage and knockback to the player.
  void takeDamage(int damage, Vector2 fromPosition) {
    if (_hurtTimer > 0) return;
    gameState.health -= damage;
    if (gameState.health < 0) gameState.health = 0;

    _hurtTimer = hurtDuration;
    final dir = (position - fromPosition).normalized();
    _knockbackVel = dir * 180;
    _knockbackTimer = 0.15;

    // Damage number
    final dmg = DamageNumber(
      position: position + Vector2(0, -spriteSize / 2),
      damage: damage,
      isPlayerDamage: true,
    );
    parent?.add(dmg);

    onDamaged?.call();
  }

  /// Get the world position in front of the player.
  Vector2 getInteractionPoint() {
    const double reach = 40.0;
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

    // Hurt timer
    if (_hurtTimer > 0) {
      _hurtTimer -= dt;
    }

    // Knockback
    if (_knockbackTimer > 0) {
      _knockbackTimer -= dt;
      position += _knockbackVel * dt;
      _knockbackVel *= 0.85;
    }

    // One-shot animation handling
    if (_isOneShotPlaying) {
      _oneShotTimer += dt;
      // Fire action at ~40% through animation
      if (!_actionFired && _oneShotTimer >= _oneShotDuration * 0.4) {
        _actionFired = true;
        onAction?.call();
      }
      if (_oneShotTimer >= _oneShotDuration) {
        _isOneShotPlaying = false;
        _state = PlayerAnimState.idle;
        _updateAnimation();
      }
    }

    // Movement (only when not in one-shot or hurt)
    if (!_isOneShotPlaying && _knockbackTimer <= 0) {
      if (movementInput.length > 0.1) {
        if (_state != PlayerAnimState.walk) {
          _state = PlayerAnimState.walk;
          _updateAnimation();
        }
        final dir = movementInput.normalized();
        final newPos = position + dir * speed * dt;

        // Collision check
        bool canMoveX = true;
        bool canMoveY = true;
        for (final other in _colliding) {
          if (other is SolidObject) {
            final hb = other.hitboxRect;
            final testX = Rect.fromLTWH(
              newPos.x - playerWidth / 2,
              position.y - playerHeight / 2,
              playerWidth,
              playerHeight,
            );
            if (testX.overlaps(hb)) canMoveX = false;
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

        // Update facing
        if (dir.x.abs() > dir.y.abs()) {
          final newFacing = dir.x > 0 ? Facing.right : Facing.left;
          if (_facing != newFacing) {
            _facing = newFacing;
            if (!_isOneShotPlaying) _updateAnimation();
          }
        } else {
          final newFacing = dir.y > 0 ? Facing.down : Facing.up;
          if (_facing != newFacing) {
            _facing = newFacing;
            if (!_isOneShotPlaying) _updateAnimation();
          }
        }
      } else {
        if (_state != PlayerAnimState.idle && !_isOneShotPlaying) {
          _state = PlayerAnimState.idle;
          _updateAnimation();
        }
      }
    }

    // Update animation ticker
    _currentTicker?.update(dt);

    // Sync shadow position
    _shadow?.position = Vector2(0, spriteSize / 2 - 4);

    // Sync to game state
    gameState.playerX = position.x;
    gameState.playerY = position.y;
  }

  @override
  void render(Canvas canvas) {
    // Hurt flash: skip rendering on alternating intervals
    if (_hurtTimer > 0) {
      final flashPhase = (_hurtTimer / hurtFlashInterval).floor();
      if (flashPhase % 2 == 0) {
        super.render(canvas);
        _renderFallback(canvas, const Color(0xFFFFFFFF));
        return;
      }
    }

    super.render(canvas);
    // Always use code-drawn fallback (Flame 1.18 + Web CanvasKit sprite issue)
    _renderFallback(canvas, const Color(0xFF4A90D9));
  }

  /// Render a visible fallback player shape (blue rectangle + P label).
  void _renderFallback(Canvas canvas, Color color) {
    // Body
    canvas.drawRect(
      Rect.fromLTWH(
        (spriteSize - 28) / 2,
        spriteSize - 38,
        28,
        34,
      ),
      Paint()..color = color,
    );
    // Head
    canvas.drawRect(
      Rect.fromLTWH(
        (spriteSize - 18) / 2,
        spriteSize - 48,
        18,
        14,
      ),
      Paint()..color = color.withOpacity(0.9),
    );
    // Border
    canvas.drawRect(
      Rect.fromLTWH(
        (spriteSize - 28) / 2,
        spriteSize - 48,
        28,
        44,
      ),
      Paint()
        ..color = const Color(0xFF1A1A2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // "P" label
    final tp = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.render(canvas, 'P', Vector2(spriteSize / 2, spriteSize - 24),
        anchor: Anchor.center);

    // Facing indicator: small arrow showing direction
    final arrowPaint = Paint()..color = const Color(0xFFFFFF00);
    final cx = spriteSize / 2;
    final cy = spriteSize - 24;
    void tri(Offset p1, Offset p2, Offset p3) {
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();
      canvas.drawPath(path, arrowPaint);
    }
    switch (_facing) {
      case Facing.down:
        tri(Offset(cx, cy + 16), Offset(cx - 4, cy + 10), Offset(cx + 4, cy + 10));
        break;
      case Facing.up:
        tri(Offset(cx, cy - 16), Offset(cx - 4, cy - 10), Offset(cx + 4, cy - 10));
        break;
      case Facing.left:
        tri(Offset(cx - 16, cy), Offset(cx - 10, cy - 4), Offset(cx - 10, cy + 4));
        break;
      case Facing.right:
        tri(Offset(cx + 16, cy), Offset(cx + 10, cy - 4), Offset(cx + 10, cy + 4));
        break;
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
