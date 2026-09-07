import 'item.dart';

/// A single crafting recipe.
class Recipe {
  final String id;
  final String name;
  final int resultItemId;
  final int resultCount;
  final Map<int, int> ingredients; // itemId -> count
  final String station; // 'workbench', 'furnace', 'hand'

  const Recipe({
    required this.id,
    required this.name,
    required this.resultItemId,
    required this.ingredients,
    this.resultCount = 1,
    this.station = 'workbench',
  });
}

/// All crafting and smelting recipes.
class Recipes {
  static const List<Recipe> all = [
    // Workbench recipes
    Recipe(
      id: 'plank',
      name: 'Plank',
      resultItemId: Items.plank,
      resultCount: 4,
      ingredients: {Items.wood: 1},
      station: 'workbench',
    ),
    Recipe(
      id: 'stone_axe',
      name: 'Stone Axe',
      resultItemId: Items.axe,
      ingredients: {Items.wood: 2, Items.stone: 3},
      station: 'workbench',
    ),
    Recipe(
      id: 'stone_pick',
      name: 'Stone Pickaxe',
      resultItemId: Items.pickaxe,
      ingredients: {Items.wood: 2, Items.stone: 3},
      station: 'workbench',
    ),
    Recipe(
      id: 'stone_sword',
      name: 'Stone Sword',
      resultItemId: Items.sword,
      ingredients: {Items.wood: 1, Items.stone: 2},
      station: 'workbench',
    ),
    Recipe(
      id: 'torch',
      name: 'Torch',
      resultItemId: Items.torch,
      resultCount: 4,
      ingredients: {Items.wood: 1, Items.coal: 1},
      station: 'workbench',
    ),
    Recipe(
      id: 'chest_item',
      name: 'Chest',
      resultItemId: 24, // placeholder, chest handled as placed object
      ingredients: {Items.plank: 8},
      station: 'workbench',
    ),
    Recipe(
      id: 'furnace_item',
      name: 'Furnace',
      resultItemId: 24, // placeholder
      ingredients: {Items.stone: 8},
      station: 'workbench',
    ),
    Recipe(
      id: 'workbench_item',
      name: 'Workbench',
      resultItemId: 24, // placeholder
      ingredients: {Items.plank: 4},
      station: 'hand',
    ),
    // Furnace smelting recipes
    Recipe(
      id: 'iron_bar',
      name: 'Iron Bar',
      resultItemId: Items.ironBar,
      ingredients: {Items.ironOre: 1, Items.coal: 1},
      station: 'furnace',
    ),
    Recipe(
      id: 'gold_bar',
      name: 'Gold Bar',
      resultItemId: Items.goldBar,
      ingredients: {Items.goldOre: 1, Items.coal: 2},
      station: 'furnace',
    ),
    Recipe(
      id: 'brick',
      name: 'Brick',
      resultItemId: 25,
      ingredients: {Items.stone: 2, Items.coal: 1},
      station: 'furnace',
    ),
  ];

  /// Get recipes available at a specific station.
  static List<Recipe> forStation(String station) {
    return all.where((r) => r.station == station).toList();
  }

  /// Check if a recipe can be crafted with the given inventory.
  static bool canCraft(Recipe recipe, Map<int, int> available) {
    for (final entry in recipe.ingredients.entries) {
      if ((available[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }
}
