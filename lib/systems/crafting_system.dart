import '../models/game_state.dart';
import '../models/item.dart';
import '../models/recipe.dart';

/// Result of a crafting action.
class CraftingResult {
  final bool success;
  final String? message;

  const CraftingResult({required this.success, this.message});
}

/// Handles crafting at workbench and smelting at furnace.
class CraftingSystem {
  /// Check if the player can craft a recipe (has materials + near station).
  static bool canCraft(Recipe recipe, GameState state) {
    for (final entry in recipe.ingredients.entries) {
      if (state.inventory.countOf(entry.key) < entry.value) return false;
    }
    return true;
  }

  /// Craft a recipe. Deducts materials and adds result.
  static CraftingResult craft(Recipe recipe, GameState state) {
    if (!canCraft(recipe, state)) {
      return const CraftingResult(success: false, message: 'Missing materials');
    }

    // Deduct ingredients
    for (final entry in recipe.ingredients.entries) {
      state.inventory.removeItem(entry.key, entry.value);
    }

    // Add result
    final overflow = state.inventory.addItem(
      recipe.resultItemId,
      recipe.resultCount,
    );

    if (overflow > 0) {
      // Inventory full - refund ingredients (simplified)
      for (final entry in recipe.ingredients.entries) {
        state.inventory.addItem(entry.key, entry.value);
      }
      state.inventory.removeItem(recipe.resultItemId, recipe.resultCount - overflow);
      return const CraftingResult(success: false, message: 'Inventory full');
    }

    return CraftingResult(success: true, message: 'Crafted ${recipe.name}');
  }

  /// Get all recipes available at a station, with craftability info.
  static List<Recipe> getRecipesForStation(String station) {
    return Recipes.forStation(station);
  }

  /// Smelt an ore at the furnace.
  static CraftingResult smelt(int oreItemId, GameState state) {
    Recipe? recipe;
    if (oreItemId == Items.ironOre) {
      recipe = Recipes.all.firstWhere((r) => r.id == 'iron_bar');
    } else if (oreItemId == Items.goldOre) {
      recipe = Recipes.all.firstWhere((r) => r.id == 'gold_bar');
    }
    if (recipe == null) {
      return const CraftingResult(success: false, message: 'Cannot smelt this');
    }
    return craft(recipe, state);
  }
}
