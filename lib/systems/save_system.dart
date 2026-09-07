import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

/// Handles saving and loading game progress using shared_preferences.
class SaveSystem {
  static const String _saveKey = 'pixelverse_save_v1';
  static const String _hasSaveKey = 'pixelverse_has_save';

  /// Save the entire game state.
  static Future<bool> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, dynamic>{
        'health': state.health,
        'maxHealth': state.maxHealth,
        'energy': state.energy,
        'maxEnergy': state.maxEnergy,
        'coins': state.coins,
        'playerX': state.playerX,
        'playerY': state.playerY,
        'day': state.day,
        'season': state.season.index,
        'year': state.year,
        'timeOfDay': state.timeOfDay,
        'weather': state.weather.index,
        'scene': state.scene.index,
        'inventory': state.inventory.toJson(),
        'selectedHotbar': state.inventory.selectedHotbarIndex,
        'placedObjects': state.placedObjects,
        'crops': state.crops,
        'modifiedTiles': state.modifiedTiles,
        'destroyedObjects': state.destroyedObjects.toList(),
        'npcDialogueIndex': state.npcDialogueIndex,
      };
      await prefs.setString(_saveKey, jsonEncode(data));
      await prefs.setBool(_hasSaveKey, true);
      state.hasSave = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load a saved game into the provided state. Returns true if successful.
  static Future<bool> loadGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_saveKey);
      if (raw == null) return false;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      state.health = (data['health'] as num?)?.toInt() ?? 10;
      state.maxHealth = (data['maxHealth'] as num?)?.toInt() ?? 10;
      state.energy = (data['energy'] as num?)?.toInt() ?? 100;
      state.maxEnergy = (data['maxEnergy'] as num?)?.toInt() ?? 100;
      state.coins = (data['coins'] as num?)?.toInt() ?? 50;
      state.playerX = (data['playerX'] as num?)?.toDouble() ?? 960;
      state.playerY = (data['playerY'] as num?)?.toDouble() ?? 960;
      state.day = (data['day'] as num?)?.toInt() ?? 1;
      state.season = Season.values[(data['season'] as num?)?.toInt() ?? 0];
      state.year = (data['year'] as num?)?.toInt() ?? 1;
      state.timeOfDay = (data['timeOfDay'] as num?)?.toDouble() ?? 6.0;
      state.weather = Weather.values[(data['weather'] as num?)?.toInt() ?? 0];
      state.scene = GameScene.values[(data['scene'] as num?)?.toInt() ?? 0];

      state.inventory.slots.forEach((s) => s.clear());
      final invData = data['inventory'] as List<dynamic>?;
      if (invData != null) state.inventory.loadFromJson(invData);
      state.inventory.selectedHotbarIndex =
          (data['selectedHotbar'] as num?)?.toInt() ?? 0;

      state.placedObjects.clear();
      final placed = data['placedObjects'] as List<dynamic>?;
      if (placed != null) {
        for (final p in placed) {
          state.placedObjects.add(Map<String, dynamic>.from(p as Map));
        }
      }

      state.crops.clear();
      final crops = data['crops'] as List<dynamic>?;
      if (crops != null) {
        for (final c in crops) {
          state.crops.add(Map<String, dynamic>.from(c as Map));
        }
      }

      state.modifiedTiles.clear();
      final modTiles = data['modifiedTiles'] as Map<String, dynamic>?;
      if (modTiles != null) {
        modTiles.forEach((k, v) {
          state.modifiedTiles[k] = (v as num).toInt();
        });
      }

      state.destroyedObjects.clear();
      final destroyed = data['destroyedObjects'] as List<dynamic>?;
      if (destroyed != null) {
        for (final d in destroyed) {
          state.destroyedObjects.add(d as String);
        }
      }

      state.npcDialogueIndex.clear();
      final npcIdx = data['npcDialogueIndex'] as Map<String, dynamic>?;
      if (npcIdx != null) {
        npcIdx.forEach((k, v) {
          state.npcDialogueIndex[k] = (v as num).toInt();
        });
      }

      state.hasSave = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if a save file exists.
  static Future<bool> hasSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSaveKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Delete the save file.
  static Future<void> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
      await prefs.setBool(_hasSaveKey, false);
    } catch (e) {
      // ignore
    }
  }
}
