import 'enemy.dart';
import 'obstacle.dart';
import 'collectible.dart';
import 'weapon.dart';

/// 关卡目标类型
enum ObjectiveType {
  collectCoins, // 收集指定数量金币后到传送门
  killAll, // 消灭所有敌人后到传送门
  defeatBoss, // 击败BOSS通关
}

/// 敌人生成配置
class EnemySpawn {
  final EnemyType type;
  final double x;
  final double y;
  const EnemySpawn({required this.type, required this.x, required this.y});
}

/// 障碍物生成配置
class ObstacleSpawn {
  final ObstacleType type;
  final double x;
  final double y;
  const ObstacleSpawn({required this.type, required this.x, required this.y});
}

/// 收集物生成配置
class CollectibleSpawn {
  final CollectibleType type;
  final double x;
  final double y;
  const CollectibleSpawn({required this.type, required this.x, required this.y});
}

/// 武器拾取生成配置
class WeaponSpawn {
  final WeaponType weapon;
  final double x;
  final double y;
  const WeaponSpawn({required this.weapon, required this.x, required this.y});
}

/// 关卡配置
///
/// 定义一个关卡的所有静态数据：背景、目标、敌人、障碍物、收集物、
/// 武器拾取、商人、宝箱、传送门位置、玩家出生点。
class LevelConfig {
  final int index;
  final String name;
  final String backgroundAsset;
  final String objectiveText;
  final ObjectiveType objectiveType;
  final int objectiveValue; // 金币数量等

  final List<EnemySpawn> enemies;
  final List<ObstacleSpawn> obstacles;
  final List<CollectibleSpawn> collectibles;
  final List<WeaponSpawn> weaponPickups;

  /// 商人位置（null 表示本关无商人）
  final ({double x, double y})? merchant;

  /// 宝箱位置（null 表示本关无宝箱）
  final ({double x, double y})? chest;

  /// 传送门位置（BOSS 关为 null）
  final ({double x, double y})? portal;

  /// 玩家出生点
  final double playerStartX;
  final double playerStartY;

  const LevelConfig({
    required this.index,
    required this.name,
    required this.backgroundAsset,
    required this.objectiveText,
    required this.objectiveType,
    this.objectiveValue = 0,
    required this.enemies,
    required this.obstacles,
    required this.collectibles,
    this.weaponPickups = const [],
    this.merchant,
    this.chest,
    this.portal,
    required this.playerStartX,
    required this.playerStartY,
  });

  /// 全部关卡定义
  static final List<LevelConfig> levels = [level1, level2, level3];

  // ==================== 第1关：翠绿草原 ====================
  static const LevelConfig level1 = LevelConfig(
    index: 0,
    name: '翠绿草原',
    backgroundAsset: 'assets/images/grass.png',
    objectiveText: '收集 10 枚金币后前往传送门',
    objectiveType: ObjectiveType.collectCoins,
    objectiveValue: 10,
    playerStartX: 100,
    playerStartY: 720,
    portal: (x: 1850, y: 1320),
    merchant: (x: 320, y: 680),
    chest: (x: 1550, y: 280),
    weaponPickups: [
      WeaponSpawn(weapon: WeaponType.bow, x: 900, y: 500),
    ],
    enemies: [
      EnemySpawn(type: EnemyType.slime, x: 400, y: 480),
      EnemySpawn(type: EnemyType.slime, x: 800, y: 280),
      EnemySpawn(type: EnemyType.slime, x: 1120, y: 480),
      EnemySpawn(type: EnemyType.slime, x: 620, y: 980),
      EnemySpawn(type: EnemyType.slime, x: 1420, y: 780),
      EnemySpawn(type: EnemyType.bat, x: 900, y: 180),
      EnemySpawn(type: EnemyType.bat, x: 1320, y: 580),
      EnemySpawn(type: EnemyType.bat, x: 520, y: 1280),
    ],
    obstacles: [
      ObstacleSpawn(type: ObstacleType.tree, x: 300, y: 180),
      ObstacleSpawn(type: ObstacleType.tree, x: 520, y: 340),
      ObstacleSpawn(type: ObstacleType.tree, x: 720, y: 140),
      ObstacleSpawn(type: ObstacleType.tree, x: 1200, y: 380),
      ObstacleSpawn(type: ObstacleType.tree, x: 1520, y: 220),
      ObstacleSpawn(type: ObstacleType.tree, x: 420, y: 880),
      ObstacleSpawn(type: ObstacleType.tree, x: 920, y: 1080),
      ObstacleSpawn(type: ObstacleType.tree, x: 1420, y: 980),
      ObstacleSpawn(type: ObstacleType.rock, x: 600, y: 580),
      ObstacleSpawn(type: ObstacleType.rock, x: 860, y: 440),
      ObstacleSpawn(type: ObstacleType.rock, x: 1100, y: 780),
      ObstacleSpawn(type: ObstacleType.rock, x: 1620, y: 580),
      ObstacleSpawn(type: ObstacleType.rock, x: 360, y: 1180),
      ObstacleSpawn(type: ObstacleType.rock, x: 1720, y: 1080),
      ObstacleSpawn(type: ObstacleType.sign, x: 200, y: 380),
      ObstacleSpawn(type: ObstacleType.sign, x: 1020, y: 680),
    ],
    collectibles: [
      CollectibleSpawn(type: CollectibleType.coin, x: 250, y: 280),
      CollectibleSpawn(type: CollectibleType.coin, x: 460, y: 440),
      CollectibleSpawn(type: CollectibleType.coin, x: 660, y: 240),
      CollectibleSpawn(type: CollectibleType.coin, x: 760, y: 540),
      CollectibleSpawn(type: CollectibleType.coin, x: 960, y: 340),
      CollectibleSpawn(type: CollectibleType.coin, x: 1060, y: 640),
      CollectibleSpawn(type: CollectibleType.coin, x: 1260, y: 280),
      CollectibleSpawn(type: CollectibleType.coin, x: 1360, y: 540),
      CollectibleSpawn(type: CollectibleType.coin, x: 1560, y: 380),
      CollectibleSpawn(type: CollectibleType.coin, x: 500, y: 780),
      CollectibleSpawn(type: CollectibleType.coin, x: 800, y: 880),
      CollectibleSpawn(type: CollectibleType.coin, x: 1120, y: 980),
      CollectibleSpawn(type: CollectibleType.coin, x: 1620, y: 880),
      CollectibleSpawn(type: CollectibleType.coin, x: 300, y: 1080),
      CollectibleSpawn(type: CollectibleType.coin, x: 1720, y: 1280),
      CollectibleSpawn(type: CollectibleType.gem, x: 1000, y: 140),
      CollectibleSpawn(type: CollectibleType.gem, x: 1660, y: 340),
      CollectibleSpawn(type: CollectibleType.gem, x: 700, y: 1240),
      CollectibleSpawn(type: CollectibleType.potion, x: 560, y: 680),
      CollectibleSpawn(type: CollectibleType.potion, x: 1460, y: 1140),
    ],
  );

  // ==================== 第2关：幽暗地牢 ====================
  static const LevelConfig level2 = LevelConfig(
    index: 1,
    name: '幽暗地牢',
    backgroundAsset: 'assets/images/dungeon.png',
    objectiveText: '消灭所有敌人后前往传送门',
    objectiveType: ObjectiveType.killAll,
    playerStartX: 100,
    playerStartY: 720,
    portal: (x: 1850, y: 1320),
    merchant: (x: 400, y: 380),
    chest: (x: 1600, y: 1080),
    weaponPickups: [
      WeaponSpawn(weapon: WeaponType.staff, x: 1000, y: 700),
    ],
    enemies: [
      EnemySpawn(type: EnemyType.archer, x: 700, y: 300),
      EnemySpawn(type: EnemyType.archer, x: 1200, y: 500),
      EnemySpawn(type: EnemyType.archer, x: 900, y: 1000),
      EnemySpawn(type: EnemyType.boar, x: 500, y: 800),
      EnemySpawn(type: EnemyType.boar, x: 1400, y: 900),
      EnemySpawn(type: EnemyType.slime, x: 1100, y: 200),
      EnemySpawn(type: EnemyType.slime, x: 1600, y: 700),
    ],
    obstacles: [
      ObstacleSpawn(type: ObstacleType.rock, x: 350, y: 250),
      ObstacleSpawn(type: ObstacleType.rock, x: 600, y: 500),
      ObstacleSpawn(type: ObstacleType.rock, x: 850, y: 350),
      ObstacleSpawn(type: ObstacleType.rock, x: 1050, y: 600),
      ObstacleSpawn(type: ObstacleType.rock, x: 1300, y: 300),
      ObstacleSpawn(type: ObstacleType.rock, x: 1550, y: 500),
      ObstacleSpawn(type: ObstacleType.rock, x: 450, y: 1050),
      ObstacleSpawn(type: ObstacleType.rock, x: 750, y: 1200),
      ObstacleSpawn(type: ObstacleType.rock, x: 1150, y: 1100),
      ObstacleSpawn(type: ObstacleType.rock, x: 1700, y: 900),
      ObstacleSpawn(type: ObstacleType.sign, x: 250, y: 550),
      ObstacleSpawn(type: ObstacleType.sign, x: 1350, y: 1200),
    ],
    collectibles: [
      CollectibleSpawn(type: CollectibleType.coin, x: 300, y: 400),
      CollectibleSpawn(type: CollectibleType.coin, x: 550, y: 650),
      CollectibleSpawn(type: CollectibleType.coin, x: 800, y: 500),
      CollectibleSpawn(type: CollectibleType.coin, x: 1000, y: 300),
      CollectibleSpawn(type: CollectibleType.coin, x: 1250, y: 700),
      CollectibleSpawn(type: CollectibleType.coin, x: 1500, y: 400),
      CollectibleSpawn(type: CollectibleType.coin, x: 700, y: 950),
      CollectibleSpawn(type: CollectibleType.coin, x: 1300, y: 1050),
      CollectibleSpawn(type: CollectibleType.gem, x: 1700, y: 300),
      CollectibleSpawn(type: CollectibleType.gem, x: 200, y: 1200),
      CollectibleSpawn(type: CollectibleType.potion, x: 950, y: 850),
      CollectibleSpawn(type: CollectibleType.potion, x: 1450, y: 1250),
    ],
  );

  // ==================== 第3关：熔岩深渊 ====================
  static const LevelConfig level3 = LevelConfig(
    index: 2,
    name: '熔岩深渊',
    backgroundAsset: 'assets/images/lava.png',
    objectiveText: '击败深渊恶魔BOSS！',
    objectiveType: ObjectiveType.defeatBoss,
    playerStartX: 100,
    playerStartY: 720,
    merchant: (x: 280, y: 280),
    chest: (x: 1650, y: 280),
    enemies: [
      EnemySpawn(type: EnemyType.bomb, x: 600, y: 400),
      EnemySpawn(type: EnemyType.bomb, x: 800, y: 1000),
      EnemySpawn(type: EnemyType.bat, x: 1000, y: 200),
      EnemySpawn(type: EnemyType.bat, x: 1200, y: 1100),
      EnemySpawn(type: EnemyType.archer, x: 500, y: 1200),
      EnemySpawn(type: EnemyType.archer, x: 1500, y: 500),
      EnemySpawn(type: EnemyType.boss, x: 1400, y: 680),
    ],
    obstacles: [
      ObstacleSpawn(type: ObstacleType.rock, x: 400, y: 500),
      ObstacleSpawn(type: ObstacleType.rock, x: 700, y: 700),
      ObstacleSpawn(type: ObstacleType.rock, x: 1000, y: 500),
      ObstacleSpawn(type: ObstacleType.rock, x: 1100, y: 900),
      ObstacleSpawn(type: ObstacleType.rock, x: 1600, y: 800),
      ObstacleSpawn(type: ObstacleType.rock, x: 350, y: 900),
      ObstacleSpawn(type: ObstacleType.rock, x: 1300, y: 300),
      ObstacleSpawn(type: ObstacleType.sign, x: 200, y: 500),
    ],
    collectibles: [
      CollectibleSpawn(type: CollectibleType.coin, x: 300, y: 600),
      CollectibleSpawn(type: CollectibleType.coin, x: 600, y: 900),
      CollectibleSpawn(type: CollectibleType.coin, x: 900, y: 700),
      CollectibleSpawn(type: CollectibleType.coin, x: 1200, y: 500),
      CollectibleSpawn(type: CollectibleType.coin, x: 1500, y: 1000),
      CollectibleSpawn(type: CollectibleType.gem, x: 1750, y: 600),
      CollectibleSpawn(type: CollectibleType.potion, x: 450, y: 1100),
      CollectibleSpawn(type: CollectibleType.potion, x: 1350, y: 1200),
    ],
  );
}
