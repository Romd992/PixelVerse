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
    ItemDef(id: 0, name: 'Axe', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 1, name: 'Pickaxe', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 2, name: 'Sword', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 3, name: 'Hoe', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 4, name: 'Watering Can', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 5, name: 'Fishing Rod', category: ItemCategory.tool, maxStack: 1),
    ItemDef(id: 6, name: 'Wood', category: ItemCategory.resource, sellPrice: 2),
    ItemDef(id: 7, name: 'Stone', category: ItemCategory.resource, sellPrice: 3),
    ItemDef(id: 8, name: 'Iron Ore', category: ItemCategory.resource, sellPrice: 8),
    ItemDef(id: 9, name: 'Gold Ore', category: ItemCategory.resource, sellPrice: 20),
    ItemDef(id: 10, name: 'Coal', category: ItemCategory.resource, sellPrice: 5),
    ItemDef(id: 11, name: 'Wheat Seeds', category: ItemCategory.seed, sellPrice: 2),
    ItemDef(id: 12, name: 'Carrot Seeds', category: ItemCategory.seed, sellPrice: 3),
    ItemDef(id: 13, name: 'Potato Seeds', category: ItemCategory.seed, sellPrice: 3),
    ItemDef(id: 14, name: 'Wheat', category: ItemCategory.crop, sellPrice: 10),
    ItemDef(id: 15, name: 'Carrot', category: ItemCategory.crop, sellPrice: 12),
    ItemDef(id: 16, name: 'Potato', category: ItemCategory.crop, sellPrice: 12),
    ItemDef(id: 17, name: 'Berry', category: ItemCategory.food, sellPrice: 5),
    ItemDef(id: 18, name: 'Bread', category: ItemCategory.food, sellPrice: 15),
    ItemDef(id: 19, name: 'Apple', category: ItemCategory.food, sellPrice: 8),
    ItemDef(id: 20, name: 'Fish', category: ItemCategory.food, sellPrice: 18),
    ItemDef(id: 21, name: 'Coin', category: ItemCategory.misc, maxStack: 999),
    ItemDef(id: 22, name: 'Iron Bar', category: ItemCategory.material, sellPrice: 25),
    ItemDef(id: 23, name: 'Gold Bar', category: ItemCategory.material, sellPrice: 60),
    ItemDef(id: 24, name: 'Plank', category: ItemCategory.material, sellPrice: 5, placeable: true, placeObjectType: 'plank_floor'),
    ItemDef(id: 25, name: 'Brick', category: ItemCategory.material, sellPrice: 8),
    ItemDef(id: 26, name: 'Glass', category: ItemCategory.material, sellPrice: 10),
    ItemDef(id: 27, name: 'Torch', category: ItemCategory.misc, sellPrice: 4, placeable: true, placeObjectType: 'torch'),
    ItemDef(id: 28, name: 'Flower', category: ItemCategory.misc, sellPrice: 6),
    ItemDef(id: 29, name: 'Mushroom', category: ItemCategory.food, sellPrice: 7),
    ItemDef(id: 30, name: 'Egg', category: ItemCategory.food, sellPrice: 9),
    ItemDef(id: 31, name: 'Rope', category: ItemCategory.material, sellPrice: 6),
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
}
