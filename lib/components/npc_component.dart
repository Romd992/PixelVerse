import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';
import 'shadow_component.dart';
import 'player_component.dart' show pixelPaint;

/// NPC definition.
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
      name: '村长·李大爷',
      spriteFile: 'npc_mayor.png',
      dialogues: [
        '欢迎来到像素谷！这里是个宁静的小村庄，很高兴你能来。',
        '最近村子里有些冷清，希望你的到来能给大家带来活力。',
        '记得在午夜前睡觉哦，不然会体力不支昏倒在外面的。',
        '种植作物是在这个山谷里赚钱的好方法，试试种些小麦吧。',
        '矿洞里有丰富的矿石，但也很危险，记得带上武器再去。',
        '下雨天不用浇水，作物会自己喝饱雨水的。',
      ],
    ),
    NpcDef(
      id: 'blacksmith',
      name: '铁匠·老锤',
      spriteFile: 'npc_blacksmith.png',
      dialogues: [
        '有矿石吗？拿来我可以帮你熔炼成锭，不过得有煤炭才行。',
        '一把好镐子是挖矿的必备工具，石头做的镐子就能挖铁矿了。',
        '铁矿和金矿在矿洞深处才能找到，越往下走矿石越丰富。',
        '煤炭是熔炼的必需品，挖矿的时候多留意黑色的石头。',
        '铁锭可以做更好的工具，金锭虽然不能做工具，但能卖个好价钱。',
        '小心矿洞里的史莱姆和蝙蝠，它们会主动攻击入侵者。',
      ],
    ),
    NpcDef(
      id: 'shopkeeper',
      name: '店主·皮埃尔',
      spriteFile: 'npc_shopkeeper.png',
      isShopkeeper: true,
      dialogues: [
        '欢迎光临我的小店！这里有各种种子和工具出售。',
        '需要种子吗？我这里有小麦、胡萝卜和土豆种子，价格公道。',
        '把你的作物和资源卖给我吧，我给的价格绝对公平。',
        '最好的商品都在皮埃尔商店里，买不了吃亏买不了上当！',
        '小麦种子最便宜，适合新手；胡萝卜和土豆种子贵一些，但卖价也高。',
        '记得每天早上9点到晚上9点来，其他时间我要休息。',
      ],
    ),
    NpcDef(
      id: 'farmer',
      name: '农夫·老王',
      spriteFile: 'npc_farmer.png',
      dialogues: [
        '种地是辛苦活儿，但也是最踏实的活儿，一分耕耘一分收获。',
        '每天都要给作物浇水，浇了水才能长得快，不浇水就会停止生长。',
        '下雨天是老天爷的恩赐，作物会自己被雨水浇透，省得我们动手。',
        '小麦长得最快，三天就能成熟；胡萝卜和土豆要五天，但卖的价钱更高。',
        '先用锄头把草地翻成耕地，再撒种子，最后浇水，一步都不能少。',
        '不同季节适合种不同的作物，冬天太冷，什么都种不了。',
      ],
    ),
    NpcDef(
      id: 'girl',
      name: '阿比盖尔',
      spriteFile: 'npc_girl.png',
      dialogues: [
        '你好呀！你是新来的吗？这个村子很久没有新人来了。',
        '我喜欢去矿洞探险，那里有很多有趣的东西，不过也挺危险的。',
        '史莱姆最好对付了，挥几下剑就搞定；蝙蝠会飞，要注意走位；骷髅最麻烦。',
        '也许哪天我们可以一起去探险？两个人总比一个人安全。',
        '村子旁边的池塘里可以钓鱼，钓到的鱼能卖不少钱呢。',
        '秋天的枫叶最美了，到时候整个山谷都是红色和金色的。',
      ],
    ),
  ];

  static NpcDef getById(String id) => all.firstWhere((n) => n.id == id);
}

/// NPC component with smooth patrol animation and shadow.
class NpcComponent extends PositionComponent {
  final NpcDef def;
  final SpriteAnimation? walkAnimation;
  final Sprite? idleSprite;
  late final SpriteAnimationTicker? _walkTicker;
  ShadowComponent? _shadow;

  final Vector2 _homePosition;
  Vector2 _targetOffset = Vector2.zero();
  double _patrolTimer = 0;
  final Random _rand = Random();
  static const double patrolRange = 56;
  static const double spriteSize = 48.0;

  bool playerNearby = false;
  void Function(NpcComponent npc)? onInteract;

  NpcComponent({
    required this.def,
    required Vector2 position,
    this.walkAnimation,
    this.idleSprite,
    Sprite? shadowSprite,
    this.onInteract,
  })  : _homePosition = position.clone(),
        _walkTicker = walkAnimation?.createTicker(),
        super(
          position: position,
          size: Vector2(spriteSize, spriteSize),
          anchor: Anchor.center,
        ) {
    _shadow = ShadowComponent(
      position: Vector2(0, spriteSize / 2 - 4),
      sprite: shadowSprite,
      shadowWidth: 30,
      shadowHeight: 9,
    );
  }

  @override
  Future<void> onLoad() async {
    add(_shadow!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _walkTicker?.update(dt);

    _patrolTimer -= dt;
    if (_patrolTimer <= 0) {
      _patrolTimer = 2.5 + _rand.nextDouble() * 3.5;
      _targetOffset = Vector2(
        (_rand.nextDouble() - 0.5) * patrolRange * 2,
        (_rand.nextDouble() - 0.5) * patrolRange * 2,
      );
    }

    final target = _homePosition + _targetOffset;
    final diff = target - position;
    if (diff.length > 2) {
      position += diff.normalized() * 24 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_walkTicker != null) {
      _walkTicker!.getSprite().render(
            canvas,
            position: Vector2(0, 0),
            size: Vector2(spriteSize, spriteSize),
            overridePaint: pixelPaint,
          );
    } else if (idleSprite != null) {
      idleSprite!.render(
        canvas,
        position: Vector2(0, 0),
        size: Vector2(spriteSize, spriteSize),
        overridePaint: pixelPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(
          (spriteSize - 28) / 2,
          spriteSize - 34,
          28,
          30,
        ),
        Paint()..color = const Color(0xFF9B59B6),
      );
    }

    if (playerNearby) {
      final tp = TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFF000000), offset: Offset(1, 1)),
          ],
        ),
      );
      tp.render(
        canvas,
        def.name,
        Vector2(spriteSize / 2, -6),
        anchor: Anchor.bottomCenter,
      );
    }
  }

  bool isPlayerNear(Vector2 playerPos, {double range = 56}) {
    final dx = playerPos.x - position.x;
    final dy = playerPos.y - position.y;
    playerNearby = dx * dx + dy * dy < range * range;
    return playerNearby;
  }
}
