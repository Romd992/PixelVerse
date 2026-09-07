import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player_component.dart';
import '../components/npc_component.dart';
import '../components/enemy_component.dart';
import '../components/world_object.dart';
import '../components/crop_component.dart';
import '../components/dropped_item.dart';
import '../components/particle_component.dart';
import '../components/damage_number.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../systems/gathering_system.dart';
import '../systems/building_system.dart';
import '../systems/farming_system.dart';
import '../systems/combat_system.dart';
import '../systems/save_system.dart';
import 'world_map.dart';
import 'time_system.dart';

/// The main Flame game class for PixelVerse.
class PixelVerseGame extends FlameGame with HasCollisionDetection {
  final GameState gameState;
  late final TimeSystem timeSystem;

  // Components
  late World _world;
  late CameraComponent _camera;
  PlayerComponent? player;
  WorldMap? worldMap;
  final List<NpcComponent> npcs = [];
  final List<EnemyComponent> enemies = [];
  final List<WorldObject> worldObjects = [];
  final List<CropComponent> cropComponents = [];
  final List<DroppedItem> droppedItems = [];

  // Sprite animations
  final Map<(PlayerAnimState, Facing), SpriteAnimation> playerAnimations = {};
  final Map<String, SpriteAnimation> npcAnimations = {};
  final Map<EnemyType, SpriteAnimation> enemyAnimations = {};

  // Effect sprites/animations
  Sprite? shadowSprite;
  SpriteAnimation? hitSparkAnimation;

  // Color filter overlay
  late RectangleComponent _colorFilter;

  // Smooth camera target
  Vector2 _cameraTarget = Vector2.zero();

  // Item sprites (from items.png)
  final List<Sprite?> itemSprites = List.filled(32, null);

  // Object sprites
  final Map<String, Sprite?> objectSprites = {};

  // UI sprites
  Sprite? heartSprite;
  Sprite? energySprite;
  Sprite? coinSprite;

  // Night overlay
  late RectangleComponent _nightOverlay;

  // Input
  Vector2 _joystickInput = Vector2.zero();
  final Random _rand = Random();

  // Scene management
  bool _mineLoaded = false;

  // Callbacks for UI
  void Function()? onStateChanged;
  void Function(String message)? onShowMessage;
  void Function(NpcComponent npc)? onOpenDialog;
  void Function()? onOpenShop;
  void Function()? onOpenCrafting;
  void Function()? onOpenInventory;
  void Function()? onSleep;
  void Function()? onPlayerDeath;

  PixelVerseGame({required this.gameState}) {
    timeSystem = TimeSystem(gameState);
    timeSystem.onBedtime = _handleBedtime;
  }

  @override
  Future<void> onLoad() async {
    await _loadAllSprites();

    // Create world and camera
    _world = World();
    add(_world);

    _camera = CameraComponent(world: _world);
    _camera.viewfinder.anchor = Anchor.center;
    add(_camera);

    // Night overlay (in camera viewport, not world)
    _nightOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0),
      priority: 1000,
    );
    add(_nightOverlay);

    // Color filter overlay (morning/evening tint)
    _colorFilter = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.transparent,
      priority: 1001,
    );
    add(_colorFilter);

    // Load the farm scene
    await _loadFarmScene();

    // Create player
    player = PlayerComponent(
      gameState: gameState,
      animations: playerAnimations,
      shadowSprite: shadowSprite,
    );
    player!.onAction = _handlePlayerAction;
    player!.onDamaged = () {
      onStateChanged?.call();
      if (gameState.health <= 0) {
        CombatSystem.respawnPlayer(gameState);
        player!.position = Vector2(gameState.playerX, gameState.playerY);
        if (gameState.scene == GameScene.mine) {
          exitMine();
        }
        onPlayerDeath?.call();
      }
    };
    _world.add(player!);
    _cameraTarget = player!.position.clone();
    _camera.viewfinder.position = _cameraTarget.clone();

    // Load crops from save
    _rebuildCropComponents();

    // Load placed objects from save
    _rebuildPlacedObjects();

    // Set up time system callbacks
    timeSystem.onDayStart = () {
      _rebuildCropComponents();
      onStateChanged?.call();
    };
  }

  Future<void> _loadAllSprites() async {
    // Load player animations
    await _loadPlayerAnimations();

    // Load NPC animations
    await _loadNpcAnimations();

    // Load enemy animations
    await _loadEnemyAnimations();

    // Load item spritesheet
    try {
      final itemsImg = await images.load('items.png');
      final itemsSheet = SpriteSheet(
        image: itemsImg,
        srcSize: Vector2(16, 16),
      );
      for (int i = 0; i < 32; i++) {
        itemSprites[i] = itemsSheet.getSprite(i ~/ 8, i % 8);
      }
    } catch (_) {
      // items.png not available, use fallback colors
    }

    // Load object sprites
    final objectFiles = {
      'tree': 'tree.png',
      'rock': 'rock.png',
      'bush': 'bush.png',
      'chest': 'chest.png',
      'furnace': 'furnace.png',
      'workbench': 'workbench.png',
      'house': 'house.png',
      'shop': 'shop.png',
      'bed': 'bed.png',
    };
    objectFiles.forEach((key, file) async {
      try {
        objectSprites[key] = await Sprite.load(file);
      } catch (_) {
        objectSprites[key] = null;
      }
    });

    // Load UI sprites
    try {
      heartSprite = await Sprite.load('heart.png');
    } catch (_) {}
    try {
      energySprite = await Sprite.load('energy.png');
    } catch (_) {}
    try {
      coinSprite = await Sprite.load('coin_ui.png');
    } catch (_) {}

    // Load shadow
    try {
      shadowSprite = await Sprite.load('shadow.png');
    } catch (_) {}

    // Load hit spark animation (4 cols x 2 rows = 8 frames)
    try {
      final sparkImg = await images.load('hit_spark.png');
      final sparkSheet = SpriteSheet(image: sparkImg, srcSize: Vector2(32, 32));
      final sparkSprites = <Sprite>[];
      for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 4; c++) {
          sparkSprites.add(sparkSheet.getSprite(r, c));
        }
      }
      hitSparkAnimation = SpriteAnimation.spriteList(
        sparkSprites,
        stepTime: 0.05,
        loop: false,
      );
    } catch (_) {}
  }

  Future<void> _loadPlayerAnimations() async {
    // Helper to load a row-based animation (48x48 frames)
    SpriteAnimation? loadRowAnim(
      String file,
      int row,
      int cols,
      double stepTime, {
      bool loop = true,
    }) {
      try {
        final img = images.fromCache(file);
        final sheet = SpriteSheet(image: img, srcSize: Vector2(48, 48));
        final sprites = <Sprite>[];
        for (int c = 0; c < cols; c++) {
          sprites.add(sheet.getSprite(row, c));
        }
        return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
      } catch (_) {
        return null;
      }
    }

    // Pre-load images into cache
    final playerFiles = [
      'player_walk.png',
      'player_idle.png',
      'player_axe.png',
      'player_pick.png',
      'player_sword.png',
    ];
    for (final f in playerFiles) {
      try {
        await images.load(f);
      } catch (_) {}
    }

    // Rows: 0=down, 1=left, 2=right, 3=up
    final facingRows = {
      Facing.down: 0,
      Facing.left: 1,
      Facing.right: 2,
      Facing.up: 3,
    };

    for (final entry in facingRows.entries) {
      final facing = entry.key;
      final row = entry.value;

      // Walk animation (6 cols, 0.12s/frame)
      final walk = loadRowAnim('player_walk.png', row, 6, 0.12);
      if (walk != null) playerAnimations[(PlayerAnimState.walk, facing)] = walk;

      // Idle animation (4 cols, 0.3s/frame)
      final idle = loadRowAnim('player_idle.png', row, 4, 0.3);
      if (idle != null) playerAnimations[(PlayerAnimState.idle, facing)] = idle;

      // Tool animations (4 cols each, one-shot)
      final axe = loadRowAnim('player_axe.png', row, 4, 0.08, loop: false);
      if (axe != null) playerAnimations[(PlayerAnimState.axe, facing)] = axe;

      final pick = loadRowAnim('player_pick.png', row, 4, 0.08, loop: false);
      if (pick != null) playerAnimations[(PlayerAnimState.pick, facing)] = pick;

      final sword = loadRowAnim('player_sword.png', row, 4, 0.10, loop: false);
      if (sword != null) playerAnimations[(PlayerAnimState.sword, facing)] = sword;

      // Hoe and watering can reuse axe animation as fallback
      if (axe != null) {
        playerAnimations[(PlayerAnimState.hoe, facing)] = axe;
        playerAnimations[(PlayerAnimState.water, facing)] = axe;
      }
    }
  }

  Future<void> _loadNpcAnimations() async {
    final npcFiles = {
      'mayor': 'npc_mayor.png',
      'blacksmith': 'npc_blacksmith.png',
      'shopkeeper': 'npc_shopkeeper.png',
      'farmer': 'npc_farmer.png',
      'girl': 'npc_girl.png',
    };

    npcFiles.forEach((key, file) async {
      try {
        await images.load(file);
        final img = images.fromCache(file);
        final sheet = SpriteSheet(image: img, srcSize: Vector2(48, 48));
        final sprites = <Sprite>[];
        for (int c = 0; c < 6; c++) {
          sprites.add(sheet.getSprite(0, c)); // down-facing row, 6 frames
        }
        npcAnimations[key] =
            SpriteAnimation.spriteList(sprites, stepTime: 0.15);
      } catch (_) {}
    });
  }

  Future<void> _loadEnemyAnimations() async {
    final enemyFiles = {
      EnemyType.slime: ('slime.png', 1, 6, 0.12),
      EnemyType.bat: ('bat.png', 1, 4, 0.08),
      EnemyType.skeleton: ('skeleton.png', 4, 4, 0.15),
    };

    for (final entry in enemyFiles.entries) {
      try {
        final file = entry.value.$1;
        final rows = entry.value.$2;
        final cols = entry.value.$3;
        final step = entry.value.$4;
        await images.load(file);
        final img = images.fromCache(file);
        final sheet = SpriteSheet(image: img, srcSize: Vector2(48, 48));
        final sprites = <Sprite>[];
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            sprites.add(sheet.getSprite(r, c));
          }
        }
        enemyAnimations[entry.key] =
            SpriteAnimation.spriteList(sprites, stepTime: step);
      } catch (_) {}
    }
  }

  Future<void> _loadFarmScene() async {
    // Create and generate world map
    worldMap = WorldMap(gameState: gameState, isMine: false);

    // Load tileset
    try {
      final tilesetImg = await images.load('tileset.png');
      final tilesetSheet = SpriteSheet(
        image: tilesetImg,
        srcSize: Vector2(16, 16),
      );
      worldMap!.loadTiles(tilesetSheet);
    } catch (_) {
      // tileset not available, use fallback colors
    }

    worldMap!.generateFarmMap();
    _world.add(worldMap!);

    // Place buildings
    _addWorldObject(
      WorldObjectType.house,
      Vector2(896, 900),
      sprite: objectSprites['house'],
      destructible: false,
      interactive: true,
    );
    _addWorldObject(
      WorldObjectType.shop,
      Vector2(1400, 700),
      sprite: objectSprites['shop'],
      destructible: false,
      interactive: true,
    );

    // Place bed inside house area
    _addWorldObject(
      WorldObjectType.bed,
      Vector2(896, 940),
      sprite: objectSprites['bed'],
      destructible: false,
      interactive: true,
    );

    // Mine entrance (left side)
    _addWorldObject(
      WorldObjectType.mineEntrance,
      Vector2(400, 1300),
      sprite: null,
      destructible: false,
      interactive: true,
      label: 'Mine Entrance',
    );

    // Place trees
    final treePositions = [
      Vector2(300, 300), Vector2(500, 250), Vector2(700, 350),
      Vector2(200, 600), Vector2(400, 700), Vector2(600, 550),
      Vector2(1500, 300), Vector2(1700, 400), Vector2(1600, 600),
      Vector2(300, 1100), Vector2(500, 1500), Vector2(1500, 1400),
      Vector2(1700, 1600), Vector2(1100, 1600), Vector2(1300, 300),
      Vector2(200, 1600), Vector2(1800, 1000),
    ];
    for (final pos in treePositions) {
      final key = 'tree_${pos.x}_${pos.y}';
      if (!gameState.destroyedObjects.contains(key)) {
        final obj = _addWorldObject(
          WorldObjectType.tree,
          pos,
          sprite: objectSprites['tree'],
          health: 3,
        );
        obj.onDestroyed = (o) {
          gameState.destroyedObjects.add(key);
          _spawnDrops(o.dropPosition, [Items.wood, Items.wood, Items.wood]);
          _world.remove(o);
          worldObjects.remove(o);
        };
      }
    }

    // Place rocks
    final rockPositions = [
      Vector2(600, 900), Vector2(800, 1100), Vector2(1200, 500),
      Vector2(1400, 1100), Vector2(1000, 1400), Vector2(400, 900),
      Vector2(1700, 800), Vector2(1100, 300),
    ];
    for (final pos in rockPositions) {
      final key = 'rock_${pos.x}_${pos.y}';
      if (!gameState.destroyedObjects.contains(key)) {
        final obj = _addWorldObject(
          WorldObjectType.rock,
          pos,
          sprite: objectSprites['rock'],
          health: 3,
        );
        obj.onDestroyed = (o) {
          gameState.destroyedObjects.add(key);
          _spawnDrops(o.dropPosition, [Items.stone, Items.stone]);
          _world.remove(o);
          worldObjects.remove(o);
        };
      }
    }

    // Place bushes
    final bushPositions = [
      Vector2(750, 400), Vector2(950, 600), Vector2(1250, 900),
      Vector2(550, 1200), Vector2(1550, 500), Vector2(350, 1400),
    ];
    for (final pos in bushPositions) {
      final key = 'bush_${pos.x}_${pos.y}';
      if (!gameState.destroyedObjects.contains(key)) {
        final obj = _addWorldObject(
          WorldObjectType.bush,
          pos,
          sprite: objectSprites['bush'],
          health: 1,
        );
        obj.onDestroyed = (o) {
          gameState.destroyedObjects.add(key);
          _spawnDrops(o.dropPosition, [Items.berry, Items.berry]);
          _world.remove(o);
          worldObjects.remove(o);
        };
      }
    }

    // Place NPCs
    _spawnNpc('mayor', Vector2(1000, 850));
    _spawnNpc('shopkeeper', Vector2(1400, 800));
    _spawnNpc('blacksmith', Vector2(1200, 1000));
    _spawnNpc('farmer', Vector2(800, 1200));
    _spawnNpc('girl', Vector2(1100, 750));
  }

  WorldObject _addWorldObject(
    WorldObjectType type,
    Vector2 position, {
    Sprite? sprite,
    int health = 3,
    bool destructible = true,
    bool interactive = false,
    String? label,
  }) {
    final obj = WorldObject(
      type: type,
      position: position,
      sprite: sprite,
      health: health,
      destructible: destructible,
      interactive: interactive,
      label: label,
    );
    _world.add(obj);
    worldObjects.add(obj);
    return obj;
  }

  void _spawnNpc(String id, Vector2 position) {
    final def = NpcDefinitions.getById(id);
    final npc = NpcComponent(
      def: def,
      position: position,
      walkAnimation: npcAnimations[id],
      shadowSprite: shadowSprite,
    );
    npc.onInteract = (n) {
      if (def.isShopkeeper) {
        onOpenShop?.call();
      } else {
        onOpenDialog?.call(n);
      }
    };
    _world.add(npc);
    npcs.add(npc);
  }

  void _spawnDrops(Vector2 position, List<int> itemIds) {
    for (int i = 0; i < itemIds.length; i++) {
      final offset = Vector2(
        (_rand.nextDouble() - 0.5) * 24,
        (_rand.nextDouble() - 0.5) * 24,
      );
      final drop = DroppedItem(
        itemId: itemIds[i],
        position: position + offset,
        sprite: itemSprites[itemIds[i]],
      );
      drop.onPickup = (item) {
        final overflow = gameState.inventory.addItem(item.itemId, item.count);
        if (overflow > 0) {
          // Inventory full, don't pick up
          item.count = overflow;
          return;
        }
        // Pickup sparkle particles
        for (final p in ParticleComponent.pickupSparkle(item.position)) {
          _world.add(p);
        }
        _world.remove(item);
        droppedItems.remove(item);
        onStateChanged?.call();
      };
      _world.add(drop);
      droppedItems.add(drop);
    }
  }

  void _rebuildCropComponents() {
    for (final c in cropComponents) {
      _world.remove(c);
    }
    cropComponents.clear();

    for (final cropData in gameState.crops) {
      final tx = (cropData['tileX'] as num).toInt();
      final ty = (cropData['tileY'] as num).toInt();
      final crop = CropComponent(
        cropType: cropData['cropType'] as String,
        position: Vector2(tx * 32.0, (ty + 1) * 32.0),
        growthStage: (cropData['growthStage'] as num).toInt(),
        mature: cropData['mature'] == true,
        watered: cropData['watered'] == true,
      );
      _world.add(crop);
      cropComponents.add(crop);
    }
  }

  void _rebuildPlacedObjects() {
    for (final objData in gameState.placedObjects) {
      final typeStr = objData['type'] as String;
      final x = (objData['x'] as num).toDouble();
      final y = (objData['y'] as num).toDouble();

      WorldObjectType? type;
      switch (typeStr) {
        case 'chest':
          type = WorldObjectType.chest;
          break;
        case 'workbench':
          type = WorldObjectType.workbench;
          break;
        case 'furnace':
          type = WorldObjectType.furnace;
          break;
        case 'torch':
          type = WorldObjectType.torch;
          break;
        case 'plank_floor':
          type = WorldObjectType.plankFloor;
          break;
      }
      if (type != null) {
        final obj = WorldObject(
          type: type,
          position: Vector2(x, y),
          sprite: objectSprites[typeStr],
          destructible: true,
          isPlaced: true,
        );
        obj.onDestroyed = (o) {
          BuildingSystem.removeObjectAt(gameState, x, y);
          _world.remove(o);
          worldObjects.remove(o);
        };
        _world.add(obj);
        worldObjects.add(obj);
      }
    }
  }

  // === INPUT HANDLING ===

  void setJoystickInput(Vector2 input) {
    _joystickInput = input;
    player?.setMovement(input);
  }

  void handleActionButton() {
    player?.triggerAction();
  }

  void handleInteractButton() {
    if (player == null) return;
    final interactPos = player!.getInteractionPoint();

    // Check NPCs
    for (final npc in npcs) {
      if (npc.isPlayerNear(player!.position, range: 56)) {
        npc.onInteract?.call(npc);
        return;
      }
    }

    // Check interactive world objects
    for (final obj in worldObjects) {
      if (!obj.interactive) continue;
      final dx = obj.position.x - interactPos.x;
      final dy = obj.position.y - interactPos.y;
      if (dx * dx + dy * dy < 64 * 64) {
        switch (obj.type) {
          case WorldObjectType.bed:
            onSleep?.call();
            return;
          case WorldObjectType.mineEntrance:
            _enterMine();
            return;
          case WorldObjectType.house:
          case WorldObjectType.shop:
            // Just show message
            onShowMessage?.call(obj.type == WorldObjectType.shop
                ? 'Talk to the shopkeeper inside'
                : 'Your home');
            return;
          default:
            break;
        }
      }
    }

    // Check for workbench/furnace nearby for crafting
    for (final obj in worldObjects) {
      if (obj.type == WorldObjectType.workbench ||
          obj.type == WorldObjectType.furnace) {
        final dx = obj.position.x - player!.position.x;
        final dy = obj.position.y - player!.position.y;
        if (dx * dx + dy * dy < 64 * 64) {
          onOpenCrafting?.call();
          return;
        }
      }
    }
  }

  void _handlePlayerAction() {
    if (player == null) return;
    final interactPos = player!.getInteractionPoint();
    final selected = gameState.inventory.selectedSlot;

    // Combat: if sword equipped, attack enemies
    if (!selected.isEmpty && selected.itemId == Items.sword) {
      _performSwordAttack();
      return;
    }

    // Farming: hoe -> till, seeds -> plant, watering can -> water
    if (!selected.isEmpty) {
      if (selected.itemId == Items.hoe) {
        if (FarmingSystem.tillTile(gameState, interactPos.x, interactPos.y)) {
          onStateChanged?.call();
        }
        return;
      }
      if (CropTypes.fromSeedId(selected.itemId) != null) {
        if (FarmingSystem.plantSeed(gameState, interactPos.x, interactPos.y)) {
          _rebuildCropComponents();
          onStateChanged?.call();
        }
        return;
      }
      if (selected.itemId == Items.wateringCan) {
        if (FarmingSystem.waterTile(gameState, interactPos.x, interactPos.y)) {
          _rebuildCropComponents();
          onStateChanged?.call();
        }
        return;
      }
    }

    // Harvest mature crops
    if (FarmingSystem.harvestCrop(gameState, interactPos.x, interactPos.y)) {
      _rebuildCropComponents();
      onStateChanged?.call();
      return;
    }

    // Gathering: trees, rocks, bushes
    for (final obj in worldObjects) {
      if (!obj.destructible) continue;
      final dx = obj.position.x - interactPos.x;
      final dy = obj.position.y - interactPos.y;
      if (dx * dx + dy * dy < 56 * 56) {
        if (obj.type == WorldObjectType.tree &&
            (selected.isEmpty || selected.itemId != Items.axe)) {
          onShowMessage?.call('Equip an axe to chop trees');
          return;
        }
        if (obj.type == WorldObjectType.rock &&
            (selected.isEmpty || selected.itemId != Items.pickaxe)) {
          onShowMessage?.call('Equip a pickaxe to mine rocks');
          return;
        }
        if (gameState.energy < 5) {
          onShowMessage?.call('Not enough energy!');
          return;
        }
        gameState.energy -= 5;
        if (gameState.energy < 0) gameState.energy = 0;

        // Hit sparks at object position
        for (final p in ParticleComponent.hitSparkBurst(
          obj.dropPosition,
          sparkAnim: hitSparkAnimation,
          count: 4,
        )) {
          _world.add(p);
        }

        final destroyed = obj.takeDamage(1);
        if (destroyed) {
          // Drops handled in onDestroyed callback
        }
        onStateChanged?.call();
        return;
      }
    }

    // Building: place selected placeable item
    if (BuildingSystem.hasPlaceableSelected(gameState)) {
      if (BuildingSystem.placeObject(
          gameState, interactPos.x, interactPos.y)) {
        _rebuildPlacedObjects();
        onStateChanged?.call();
      } else {
        onShowMessage?.call('Cannot place here');
      }
      return;
    }
  }

  void _performSwordAttack() {
    if (player == null) return;
    final hitbox = CombatSystem.getAttackHitbox(
      player!.position.x,
      player!.position.y,
      player!.directionString,
    );

    // Slash effect
    final slash = SlashEffect(
      position: player!.position +
          Vector2(
            player!.directionString == 'left' ? -32 : (player!.directionString == 'right' ? 32 : 0),
            player!.directionString == 'up' ? -32 : (player!.directionString == 'down' ? 32 : 0),
          ),
      direction: player!.directionString,
    );
    _world.add(slash);

    bool hitSomething = false;
    for (final enemy in List<EnemyComponent>.from(enemies)) {
      if (CombatSystem.isInHitbox(
        enemy.position.x,
        enemy.position.y,
        hitbox.x,
        hitbox.y,
        hitbox.w,
        hitbox.h,
      )) {
        hitSomething = true;
        final dead = enemy.takeDamage(
          CombatSystem.baseSwordDamage,
          player!.position,
        );
        // Hit sparks
        for (final p in ParticleComponent.hitSparkBurst(
          enemy.position,
          sparkAnim: hitSparkAnimation,
        )) {
          _world.add(p);
        }
        if (dead) {
          final drops = CombatSystem.getDrops(
            enemy.type.toString().split('.').last,
          );
          _spawnDrops(enemy.position, drops);
          _world.remove(enemy);
          enemies.remove(enemy);
        }
      }
    }
  }

  // === SCENE MANAGEMENT ===

  void _enterMine() {
    if (gameState.scene == GameScene.mine) return;
    gameState.scene = GameScene.mine;

    // Remove farm entities (keep world map for now, we'll swap)
    for (final npc in npcs) {
      _world.remove(npc);
    }
    npcs.clear();

    // Save player position for return
    gameState.playerX = player!.position.x;
    gameState.playerY = player!.position.y;

    // Load mine scene
    _loadMineScene();

    // Move player to mine entrance
    player!.position = Vector2(960, 960);
    onShowMessage?.call('Entered the mine');
  }

  void exitMine() {
    if (gameState.scene != GameScene.mine) return;
    gameState.scene = GameScene.farm;

    // Remove mine entities
    for (final enemy in enemies) {
      _world.remove(enemy);
    }
    enemies.clear();
    for (final obj in worldObjects) {
      if (obj.type == WorldObjectType.rock ||
          obj.type == WorldObjectType.mineEntrance) {
        _world.remove(obj);
      }
    }
    worldObjects.removeWhere(
      (o) => o.type == WorldObjectType.rock ||
          o.type == WorldObjectType.mineEntrance,
    );

    // Remove mine world map, reload farm
    if (worldMap != null) {
      _world.remove(worldMap!);
    }
    _mineLoaded = false;
    _loadFarmScene();

    // Move player back to mine entrance position
    player!.position = Vector2(400, 1300);
    onShowMessage?.call('Left the mine');
  }

  void _loadMineScene() {
    if (_mineLoaded) return;
    _mineLoaded = true;

    // Swap world map
    if (worldMap != null) {
      _world.remove(worldMap!);
    }
    worldMap = WorldMap(gameState: gameState, isMine: true);
    try {
      final tilesetImg = images.fromCache('tileset.png');
      final tilesetSheet = SpriteSheet(
        image: tilesetImg,
        srcSize: Vector2(16, 16),
      );
      worldMap!.loadTiles(tilesetSheet);
    } catch (_) {}
    worldMap!.generateMineMap();
    _world.add(worldMap!);

    // Place mine rocks (with ore)
    for (int i = 0; i < 20; i++) {
      final pos = Vector2(
        100 + _rand.nextDouble() * 1720,
        100 + _rand.nextDouble() * 1720,
      );
      final obj = _addWorldObject(
        WorldObjectType.rock,
        pos,
        sprite: objectSprites['rock'],
        health: 3,
      );
      obj.onDestroyed = (o) {
        final result = GatheringSystem.mineRock(gameState);
        if (result.success) {
          _spawnDrops(o.dropPosition, result.droppedItemIds);
        }
        _world.remove(o);
        worldObjects.remove(o);
      };
    }

    // Place exit
    final exit = _addWorldObject(
      WorldObjectType.mineEntrance,
      Vector2(960, 1000),
      sprite: null,
      destructible: false,
      interactive: true,
      label: 'Exit Mine',
    );
    exit.onInteract = (o) => exitMine();

    // Spawn enemies
    for (int i = 0; i < 8; i++) {
      final pos = Vector2(
        200 + _rand.nextDouble() * 1520,
        200 + _rand.nextDouble() * 1520,
      );
      EnemyType type;
      final r = _rand.nextDouble();
      if (r < 0.5) {
        type = EnemyType.slime;
      } else if (r < 0.8) {
        type = EnemyType.bat;
      } else {
        type = EnemyType.skeleton;
      }
      _spawnEnemy(type, pos);
    }
  }

  void _spawnEnemy(EnemyType type, Vector2 position) {
    final enemy = EnemyComponent.byType(
      type,
      position,
      animation: enemyAnimations[type],
      shadowSprite: shadowSprite,
    );
    enemy.onPlayerHit = (damage) {
      // Player takes damage with knockback
      player?.takeDamage(damage, enemy.position);
    };
    _world.add(enemy);
    enemies.add(enemy);
  }

  // === SLEEP / SAVE ===

  Future<void> sleepAndSave() async {
    await SaveSystem.saveGame(gameState);
    timeSystem.advanceDay();
    // Restore player to bed area
    player!.position = Vector2(896, 960);
    gameState.playerX = 896;
    gameState.playerY = 960;
    onStateChanged?.call();
    onShowMessage?.call('Day ${gameState.day} - ${gameState.seasonName}');
  }

  void _handleBedtime() {
    onShowMessage?.call('You passed out! Sleep to recover.');
    // Auto-save and advance
    sleepAndSave();
  }

  // === UPDATE ===

  @override
  void update(double dt) {
    super.update(dt);

    // Update time
    timeSystem.update(dt);

    // Smooth camera follow
    if (player != null) {
      final followSpeed = 1 - pow(0.001, dt).toDouble();
      _cameraTarget.lerp(player!.position, followSpeed);
      _camera.viewfinder.position = _cameraTarget.clone();
    }

    // Update night overlay (smooth darkness)
    final darkness = timeSystem.darknessAlpha;
    _nightOverlay.paint =
        Paint()..color = Colors.black.withOpacity(darkness);

    // Color filter: morning/evening warm tint, night cool tint
    final filterColor = timeSystem.getFilterColor();
    _colorFilter.paint = Paint()..color = filterColor;

    // Update NPC player proximity
    if (player != null) {
      for (final npc in npcs) {
        npc.isPlayerNear(player!.position);
      }
    }

    // Update enemy AI with player position
    if (player != null) {
      for (final enemy in enemies) {
        enemy.updatePlayerPosition(player!.position);
      }
    }

    // Pickup dropped items
    if (player != null) {
      for (final drop in List<DroppedItem>.from(droppedItems)) {
        drop.updateMagnet(player!.position, dt);
        drop.tryPickup(player!.position);
      }
    }
  }

  @override
  void onRemove() {
    super.onRemove();
  }
}
