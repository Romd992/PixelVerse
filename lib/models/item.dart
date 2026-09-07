/// Item type categories
enum ItemCategory { tool, resource, seed, crop, food, material, misc }

/// Defines a single item type in the game.
class ItemDef {
  final int id;
  final String name;
  final ItemCategory category;
  final int maxStack;
  final int sellPrice;
  final bool placeable;
  final String? placeObjectType;

  const ItemDef({
    required this.id,
    required this.name,
    required this.category,
    this.maxStack = 99,
    this.sellPrice = 0,
    this.placeable = false,
    this.placeObjectType,
  });

  bool get isTool => category == ItemCategory.tool;
  bool get isSeed => category == ItemCategory.seed;
  bool get isFood => category == ItemCategory.food;
}

/// Central catalog of all item definitions, indexed by items.png sprite index.
class Items {
  static const List<ItemDef> catalog = [
    ItemDef(id: 0, name: '斧头', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 1, name: '镐子', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 2, name: '剑', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 3, name: '锄头', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 4, name: '水壶', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 5, name: '鱼竿', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 6, name: '木材', category: ItemCategory.resource, sellPrice: 2),
    ItemDef(id: 7, name: '石头', category: ItemCategory.resource, sellPrice: 3),
    ItemDef(id: 8, name: '铁矿', category: ItemCategory.resource, sellPrice: 8),
    ItemDef(id: 9, name: '金矿', category: ItemCategory.resource, sellPrice: 20),
    ItemDef(id: 10, name: '煤炭', category: ItemCategory.resource, sellPrice: 5),
    ItemDef(id: 11, name: '小麦种子', category: ItemCategory.seed, sellPrice: 2),
    ItemDef(id: 12, name: '胡萝卜种子', category: ItemCategory.seed, sellPrice: 3),
    ItemDef(id: 13, name: '土豆种子', category: ItemCategory.seed, sellPrice: 3),
    ItemDef(id: 14, name: '小麦', category: ItemCategory.crop, sellPrice: 10),
    ItemDef(id: 15, name: '胡萝卜', category: ItemCategory.crop, sellPrice: 12),
    ItemDef(id: 16, name: '土豆', category: ItemCategory.crop, sellPrice: 12),
    ItemDef(id: 17, name: '浆果', category: ItemCategory.food, sellPrice: 5),
    ItemDef(id: 18, name: '面包', category: ItemCategory.food, sellPrice: 15),
    ItemDef(id: 19, name: '苹果', category: ItemCategory.food, sellPrice: 8),
    ItemDef(id: 20, name: '鱼', category: ItemCategory.food, sellPrice: 18),
    ItemDef(id: 21, name: '金币', category: ItemCategory.misc, maxStack: 999),
    ItemDef(id: 22, name: '铁锭', category: ItemCategory.material, sellPrice: 25),
    ItemDef(id: 23, name: '金锭', category: ItemCategory.material, sellPrice: 60),
    ItemDef(id: 24, name: '木板', category: ItemCategory.material, sellPrice: 5, placeable: true, placeObjectType: 'plank_floor'),
    ItemDef(id: 25, name: '砖块', category: ItemCategory.material, sellPrice: 8),
    ItemDef(id: 26, name: '玻璃', category: ItemCategory.material, sellPrice: 10),
    ItemDef(id: 27, name: '火把', category: ItemCategory.misc, sellPrice: 4, placeable: true, placeObjectType: 'torch'),
    ItemDef(id: 28, name: '花', category: ItemCategory.misc, sellPrice: 6),
    ItemDef(id: 29, name: '箱子', category: ItemCategory.misc, sellPrice: 20, placeable: true, placeObjectType: 'chest'),
    ItemDef(id: 30, name: '工作台', category: ItemCategory.misc, sellPrice: 15, placeable: true, placeObjectType: 'workbench'),
    ItemDef(id: 31, name: '炉子', category: ItemCategory.misc, sellPrice: 25, placeable: true, placeObjectType: 'furnace'),
  ];

  static ItemDef getById(int id) => catalog[id];

  // Convenience constants for commonly referenced item IDs
  static const int axe = 0;
  static const int pickaxe = 1;
  static const int sword = 2;
  static const int hoe = 3;
  static const int wateringCan = 4;
  static const int wood = 6;
  static const int stone = 7;
  static const int ironOre = 8;
  static const int goldOre = 9;
  static const int coal = 10;
  static const int wheatSeeds = 11;
  static const int carrotSeeds = 12;
  static const int potatoSeeds = 13;
  static const int wheat = 14;
  static const int carrot = 15;
  static const int potato = 16;
  static const int berry = 17;
  static const int ironBar = 22;
  static const int goldBar = 23;
  static const int plank = 24;
  static const int torch = 27;
  static const int chest = 29;
  static const int workbench = 30;
  static const int furnace = 31;
}
