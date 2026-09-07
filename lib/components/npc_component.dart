import 'package:flutter/painting.dart';
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

/// NPC definition with name, dialogue lines, and sprite.
class NpcDef {
  final String id;
  final String name;
  final List<String> dialogues;
  final String spriteFile;
  final bool isShopkeeper;

  const NpcDef({
    required this.id,
    required this.name,
    required this.dialogues,
    required this.spriteFile,
    this.isShopkeeper = false,
  });
}

/// All NPC definitions.
class NpcDefinitions {
  static const List<NpcDef> all = [
    NpcDef(
      id: 'mayor',
      name: 'Mayor Lewis',
      spriteFile: 'npc_mayor.png',
      dialogues: [
        'Welcome to PixelVerse! We\'re glad you\'re here.',
        'The town has been quiet lately. Maybe you can help liven things up.',
        'Don\'t forget to sleep before midnight! You\'ll pass out otherwise.',
        'Growing crops is a great way to earn coins in this valley.',
      ],
    ),
    NpcDef(
      id: 'blacksmith',
      name: 'Blacksmith Clint',
      spriteFile: 'npc_blacksmith.png',
      dialogues: [
        'Got some ore? Bring it to me and I\'ll smelt it for you.',
        'A good pickaxe is essential for mining in the caves.',
        'Iron and gold can be found deeper in the mine.',
        'Coal is needed for smelting. Keep an eye out for it!',
      ],
    ),
    NpcDef(
      id: 'shopkeeper',
      name: 'Shopkeeper Pierre',
      spriteFile: 'npc_shopkeeper.png',
      isShopkeeper: true,
      dialogues: [
        'Welcome to my shop! I\'ve got seeds and tools for sale.',
        'Looking for seeds? I\'ve got wheat, carrot, and potato seeds.',
        'Sell me your crops and resources! I pay fair prices.',
        'The best deals are right here at Pierre\'s!',
      ],
    ),
    NpcDef(
      id: 'farmer',
      name: 'Farmer Willy',
      spriteFile: 'npc_farmer.png',
      dialogues: [
        'Farming is hard work, but it\'s honest work.',
        'Water your crops every day for best results.',
        'Rainy days are a gift - the crops water themselves!',
        'Wheat grows fast, but carrots and potatoes sell for more.',
      ],
    ),
    NpcDef(
      id: 'girl',
      name: 'Abigail',
      spriteFile: 'npc_girl.png',
      dialogues: [
        'Hi there! New in town?',
        'I love exploring the mine, but it can be dangerous.',
        'Slimes are easy, but watch out for bats and skeletons!',
        'Maybe we can explore together sometime.',
      ],
    ),
  ];

  static NpcDef getById(String id) => all.firstWhere((n) => n.id == id);
}

/// An NPC component with simple patrol animation.
class NpcComponent extends PositionComponent {
  final NpcDef def;
  final SpriteAnimation? walkAnimation;
  final Sprite? idleSprite;
  late final SpriteAnimationTicker? _walkTicker;

  final Vector2 _homePosition;
  Vector2 _targetOffset = Vector2.zero();
  double _patrolTimer = 0;
  final Random _rand = Random();
  static const double patrolRange = 48;

  // Interaction
  bool playerNearby = false;
  void Function(NpcComponent npc)? onInteract;

  NpcComponent({
    required this.def,
    required Vector2 position,
    this.walkAnimation,
    this.idleSprite,
    this.onInteract,
  })  : _homePosition = position.clone(),
        _walkTicker = walkAnimation?.createTicker(),
        super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _walkTicker?.update(dt);

    // Simple patrol
    _patrolTimer -= dt;
    if (_patrolTimer <= 0) {
      _patrolTimer = 2 + _rand.nextDouble() * 3;
      _targetOffset = Vector2(
        (_rand.nextDouble() - 0.5) * patrolRange * 2,
        (_rand.nextDouble() - 0.5) * patrolRange * 2,
      );
    }

    final target = _homePosition + _targetOffset;
    final diff = target - position;
    if (diff.length > 2) {
      position += diff.normalized() * 20 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_walkTicker != null) {
      _walkTicker!.getSprite().render(
            canvas,
            position: Vector2(0, 0),
            size: Vector2(32, 32),
          );
    } else if (idleSprite != null) {
      idleSprite!.render(
        canvas,
        position: Vector2(0, 0),
        size: Vector2(32, 32),
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(4, 2, 24, 28),
        Paint()..color = const Color(0xFF9B59B6),
      );
    }

    // Show name if nearby
    if (playerNearby) {
      final tp = TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.render(
        canvas,
        def.name,
        Vector2(size.x / 2, -8),
        anchor: Anchor.bottomCenter,
      );
    }
  }

  /// Check if player is within interaction range.
  bool isPlayerNear(Vector2 playerPos, {double range = 48}) {
    final dx = playerPos.x - position.x;
    final dy = playerPos.y - position.y;
    playerNearby = dx * dx + dy * dy < range * range;
    return playerNearby;
  }
}
