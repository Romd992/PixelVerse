import '../models/game_state.dart';
import '../models/item.dart';

/// Result of a gathering action.
class GatheringResult {
  final bool success;
  final List<int> droppedItemIds;
  final String? message;

  const GatheringResult({
    required this.success,
    this.droppedItemIds = const [],
    this.message,
  });
}

/// Handles gathering logic: chopping trees, mining rocks, picking berries.
class GatheringSystem {
  static const double interactRange = 64.0;

  /// Check if player can gather (has energy, correct tool).
  static bool canGather(GameState state, String objectType) {
    if (state.energy < 5) return false;
    final selected = state.inventory.selectedSlot;
    switch (objectType) {
      case 'tree':
        return !selected.isEmpty && selected.itemId == Items.axe;
      case 'rock':
        return !selected.isEmpty && selected.itemId == Items.pickaxe;
      case 'bush':
        return true; // bare hands
      default:
        return false;
    }
  }

  /// Perform gathering on an object. Returns dropped items.
  static GatheringResult gather(GameState state, String objectType) {
    if (!canGather(state, objectType)) {
      return const GatheringResult(success: false, message: '无法采集');
    }

    state.energy -= 5;
    if (state.energy < 0) state.energy = 0;

    switch (objectType) {
      case 'tree':
        return const GatheringResult(
          success: true,
          droppedItemIds: [Items.wood, Items.wood, Items.wood],
        );
      case 'rock':
        // Random chance for ores
        final rand = DateTime.now().millisecond;
        if (rand % 5 == 0) {
          return const GatheringResult(
            success: true,
            droppedItemIds: [Items.stone, Items.ironOre],
          );
        } else if (rand % 7 == 0) {
          return const GatheringResult(
            success: true,
            droppedItemIds: [Items.stone, Items.goldOre],
          );
        } else if (rand % 3 == 0) {
          return const GatheringResult(
            success: true,
            droppedItemIds: [Items.stone, Items.coal],
          );
        }
        return const GatheringResult(
          success: true,
          droppedItemIds: [Items.stone, Items.stone],
        );
      case 'bush':
        return const GatheringResult(
          success: true,
          droppedItemIds: [Items.berry, Items.berry],
        );
      default:
        return const GatheringResult(success: false);
    }
  }

  /// Mine-specific gathering in the mine (higher ore chance).
  static GatheringResult mineRock(GameState state) {
    if (state.energy < 5) {
      return const GatheringResult(success: false, message: '体力不足');
    }
    final selected = state.inventory.selectedSlot;
    if (selected.isEmpty || selected.itemId != Items.pickaxe) {
      return const GatheringResult(success: false, message: '需要镐子');
    }

    state.energy -= 5;
    final rand = DateTime.now().millisecond;
    if (rand % 3 == 0) {
      return const GatheringResult(
        success: true,
        droppedItemIds: [Items.stone, Items.ironOre],
      );
    } else if (rand % 5 == 0) {
      return const GatheringResult(
        success: true,
        droppedItemIds: [Items.stone, Items.goldOre],
      );
    } else if (rand % 2 == 0) {
      return const GatheringResult(
        success: true,
        droppedItemIds: [Items.stone, Items.coal],
      );
    }
    return const GatheringResult(
      success: true,
      droppedItemIds: [Items.stone],
    );
  }
}
