import '../models/game_state.dart';
import '../models/item.dart';

/// Crop type definitions.
class CropType {
  final int seedItemId;
  final int harvestItemId;
  final int growthDays;
  final String name;

  const CropType({
    required this.seedItemId,
    required this.harvestItemId,
    required this.growthDays,
    required this.name,
  });
}

/// All crop types.
class CropTypes {
  static const CropType wheat = CropType(
    seedItemId: Items.wheatSeeds,
    harvestItemId: Items.wheat,
    growthDays: 4,
    name: 'Wheat',
  );
  static const CropType carrot = CropType(
    seedItemId: Items.carrotSeeds,
    harvestItemId: Items.carrot,
    growthDays: 3,
    name: 'Carrot',
  );
  static const CropType potato = CropType(
    seedItemId: Items.potatoSeeds,
    harvestItemId: Items.potato,
    growthDays: 5,
    name: 'Potato',
  );

  static const List<CropType> all = [wheat, carrot, potato];

  static CropType? fromSeedId(int seedId) {
    for (final c in all) {
      if (c.seedItemId == seedId) return c;
    }
    return null;
  }
}

/// Handles farming: tilling, planting, watering, growing, harvesting.
class FarmingSystem {
  static const double tileSize = 32.0;
  static const int grassTile = 0;
  static const int dirtTile = 1;
  static const int tilledTile = 5;
  static const int wetTilledTile = 6;

  static String _tileKey(int tx, int ty) => '$tx,$ty';

  /// Get the tile index at a position, considering modified tiles.
  static int getTileAt(GameState state, int tx, int ty, int baseTile) {
    return state.modifiedTiles[_tileKey(tx, ty)] ?? baseTile;
  }

  /// Till a grass/dirt tile into farmland.
  static bool tillTile(GameState state, double worldX, double worldY) {
    final selected = state.inventory.selectedSlot;
    if (selected.isEmpty || selected.itemId != Items.hoe) return false;
    if (state.energy < 3) return false;

    final tx = (worldX / tileSize).floor();
    final ty = (worldY / tileSize).floor();
    final key = _tileKey(tx, ty);
    final current = state.modifiedTiles[key] ?? grassTile;

    if (current != grassTile && current != dirtTile) return false;

    state.modifiedTiles[key] = tilledTile;
    state.energy -= 3;
    return true;
  }

  /// Plant a seed on tilled soil.
  static bool plantSeed(GameState state, double worldX, double worldY) {
    final selected = state.inventory.selectedSlot;
    if (selected.isEmpty) return false;
    final cropType = CropTypes.fromSeedId(selected.itemId);
    if (cropType == null) return false;

    final tx = (worldX / tileSize).floor();
    final ty = (worldY / tileSize).floor();
    final key = _tileKey(tx, ty);
    final current = state.modifiedTiles[key] ?? grassTile;

    if (current != tilledTile && current != wetTilledTile) return false;

    // Check if there's already a crop here
    for (final crop in state.crops) {
      if ((crop['tileX'] as num).toInt() == tx &&
          (crop['tileY'] as num).toInt() == ty) {
        return false;
      }
    }

    state.crops.add({
      'tileX': tx,
      'tileY': ty,
      'cropType': cropType.name,
      'growthStage': 0,
      'watered': false,
      'daysWatered': 0,
      'mature': false,
    });

    state.inventory.consumeSelected();
    return true;
  }

  /// Water a tilled tile with a crop.
  static bool waterTile(GameState state, double worldX, double worldY) {
    final selected = state.inventory.selectedSlot;
    if (selected.isEmpty || selected.itemId != Items.wateringCan) return false;

    final tx = (worldX / tileSize).floor();
    final ty = (worldY / tileSize).floor();
    final key = _tileKey(tx, ty);
    final current = state.modifiedTiles[key] ?? grassTile;

    if (current != tilledTile) return false;

    state.modifiedTiles[key] = wetTilledTile;

    // Mark crop as watered
    for (final crop in state.crops) {
      if ((crop['tileX'] as num).toInt() == tx &&
          (crop['tileY'] as num).toInt() == ty) {
        crop['watered'] = true;
        break;
      }
    }
    return true;
  }

  /// Harvest a mature crop.
  static bool harvestCrop(GameState state, double worldX, double worldY) {
    final tx = (worldX / tileSize).floor();
    final ty = (worldY / tileSize).floor();

    for (int i = 0; i < state.crops.length; i++) {
      final crop = state.crops[i];
      if ((crop['tileX'] as num).toInt() == tx &&
          (crop['tileY'] as num).toInt() == ty) {
        if (crop['mature'] == true) {
          final cropName = crop['cropType'] as String;
          final cropType = CropTypes.all.firstWhere(
            (c) => c.name == cropName,
            orElse: () => CropTypes.wheat,
          );
          state.inventory.addItem(cropType.harvestItemId, 1);
          state.crops.removeAt(i);
          // Reset tile to tilled
          state.modifiedTiles[_tileKey(tx, ty)] = tilledTile;
          return true;
        }
        return false;
      }
    }
    return false;
  }

  /// Advance all crops by one day (called on sleep).
  static void advanceDay(GameState state) {
    final rainy = state.weather == Weather.rainy;

    for (final crop in state.crops) {
      bool wasWatered = crop['watered'] == true || rainy;
      if (wasWatered) {
        crop['daysWatered'] = (crop['daysWatered'] as num).toInt() + 1;
      }
      crop['watered'] = false;

      final cropName = crop['cropType'] as String;
      final cropType = CropTypes.all.firstWhere(
        (c) => c.name == cropName,
        orElse: () => CropTypes.wheat,
      );

      final daysWatered = crop['daysWatered'] as int;
      final stage = (daysWatered / cropType.growthDays * 4).floor();
      crop['growthStage'] = stage > 4 ? 4 : stage;
      crop['mature'] = daysWatered >= cropType.growthDays;
    }

    // Dry out wet tilled tiles
    final keysToReset = <String>[];
    state.modifiedTiles.forEach((key, value) {
      if (value == wetTilledTile) keysToReset.add(key);
    });
    for (final key in keysToReset) {
      state.modifiedTiles[key] = tilledTile;
    }
  }
}
