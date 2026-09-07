import '../models/game_state.dart';
import '../models/item.dart';

/// Types of objects that can be placed by the player.
class BuildableTypes {
  static const String chest = 'chest';
  static const String workbench = 'workbench';
  static const String furnace = 'furnace';
  static const String torch = 'torch';
  static const String plankFloor = 'plank_floor';
}

/// Handles building placement and removal.
class BuildingSystem {
  static const double tileSize = 32.0;

  /// Check if the selected item is placeable.
  static bool hasPlaceableSelected(GameState state) {
    final slot = state.inventory.selectedSlot;
    if (slot.isEmpty) return false;
    final def = slot.itemDef;
    return def != null && def.placeable;
  }

  /// Get the object type name for the selected placeable item.
  static String? getSelectedObjectType(GameState state) {
    final slot = state.inventory.selectedSlot;
    if (slot.isEmpty) return null;
    return slot.itemDef?.placeObjectType;
  }

  /// Place an object at the given world position (in front of player).
  static bool placeObject(GameState state, double worldX, double worldY) {
    final objectType = getSelectedObjectType(state);
    if (objectType == null) return false;

    // Snap to tile grid
    final tileX = (worldX / tileSize).floor();
    final tileY = (worldY / tileSize).floor();

    // Check if position is already occupied
    for (final obj in state.placedObjects) {
      final ox = (obj['x'] as num).toDouble();
      final oy = (obj['y'] as num).toDouble();
      if ((ox / tileSize).floor() == tileX && (oy / tileSize).floor() == tileY) {
        return false;
      }
    }

    // Consume the item
    state.inventory.consumeSelected();

    // Add to placed objects
    state.placedObjects.add({
      'type': objectType,
      'x': (tileX * tileSize + tileSize / 2),
      'y': (tileY * tileSize + tileSize / 2),
    });

    return true;
  }

  /// Remove a placed object at the given position, returning the item.
  static bool removeObjectAt(GameState state, double worldX, double worldY) {
    final tileX = (worldX / tileSize).floor();
    final tileY = (worldY / tileSize).floor();

    for (int i = 0; i < state.placedObjects.length; i++) {
      final obj = state.placedObjects[i];
      final ox = (obj['x'] as num).toDouble();
      final oy = (obj['y'] as num).toDouble();
      if ((ox / tileSize).floor() == tileX && (oy / tileSize).floor() == tileY) {
        final type = obj['type'] as String;
        state.placedObjects.removeAt(i);

        // Return the item to inventory
        int? itemId;
        switch (type) {
          case BuildableTypes.chest:
            itemId = Items.chest;
            break;
          case BuildableTypes.workbench:
            itemId = Items.workbench;
            break;
          case BuildableTypes.furnace:
            itemId = Items.furnace;
            break;
          case BuildableTypes.torch:
            itemId = Items.torch;
            break;
          case BuildableTypes.plankFloor:
            itemId = Items.plank;
            break;
        }
        if (itemId != null) {
          state.inventory.addItem(itemId, 1);
        }
        return true;
      }
    }
    return false;
  }

  /// Check if there's a specific station type near the player.
  static bool isNearStation(GameState state, String stationType, double range) {
    for (final obj in state.placedObjects) {
      if (obj['type'] == stationType) {
        final ox = (obj['x'] as num).toDouble();
        final oy = (obj['y'] as num).toDouble();
        final dx = ox - state.playerX;
        final dy = oy - state.playerY;
        if (dx * dx + dy * dy < range * range) return true;
      }
    }
    return false;
  }
}
