import 'inventory.dart';

/// Seasons in the game year.
enum Season { spring, summer, autumn, winter }

/// Weather types.
enum Weather { sunny, rainy }

/// Current scene/location the player is in.
enum GameScene { farm, mine }

/// Holds all mutable game state that needs to be saved/loaded.
class GameState {
  // Player stats
  int health = 10;
  int maxHealth = 10;
  int energy = 100;
  int maxEnergy = 100;
  int coins = 50;

  // Player position (in world pixels)
  double playerX = 960;
  double playerY = 960;

  // Time system
  int day = 1; // 1-28
  Season season = Season.spring;
  int year = 1;
  double timeOfDay = 6.0; // 6.0 = 6:00 AM, in hours
  Weather weather = Weather.sunny;

  // Current scene
  GameScene scene = GameScene.farm;

  // Inventory
  final Inventory inventory = Inventory();

  // Placed objects: list of {type, x, y}
  final List<Map<String, dynamic>> placedObjects = [];

  // Crops: list of {tileX, tileY, cropType, growthStage, watered, daysWatered}
  final List<Map<String, dynamic>> crops = [];

  // Modified tiles (tilled soil etc): "x,y" -> tileIndex
  final Map<String, int> modifiedTiles = {};

  // Destroyed world objects (trees, rocks) so they don't respawn same day
  final Set<String> destroyedObjects = {};

  // NPC dialogue progress
  final Map<String, int> npcDialogueIndex = {};

  bool hasSave = false;

  /// Reset to a fresh game state.
  void reset() {
    health = maxHealth;
    energy = maxEnergy;
    coins = 50;
    playerX = 960;
    playerY = 960;
    day = 1;
    season = Season.spring;
    year = 1;
    timeOfDay = 6.0;
    weather = Weather.sunny;
    scene = GameScene.farm;
    inventory.slots.forEach((s) => s.clear());
    inventory.selectedHotbarIndex = 0;
    inventory.giveStarterItems();
    placedObjects.clear();
    crops.clear();
    modifiedTiles.clear();
    destroyedObjects.clear();
    npcDialogueIndex.clear();
  }

  /// Get a display string for the current time.
  String get timeString {
    final hour = timeOfDay.floor();
    final minute = ((timeOfDay - hour) * 60).floor();
    final h = hour % 24;
    final period = h < 12 ? 'AM' : 'PM';
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get seasonName {
    switch (season) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.autumn:
        return 'Autumn';
      case Season.winter:
        return 'Winter';
    }
  }

  String get weatherName => weather == Weather.sunny ? 'Sunny' : 'Rainy';

  /// Darkness factor for night overlay (0 = full day, 1 = full night).
  double get darkness {
    if (timeOfDay >= 6 && timeOfDay < 18) {
      // Daytime - slight dimming at edges
      if (timeOfDay < 7) return (7 - timeOfDay) * 0.15;
      if (timeOfDay >= 17) return (timeOfDay - 17) * 0.15;
      return 0.0;
    }
    // Night
    if (timeOfDay >= 18 && timeOfDay < 20) {
      return 0.3 + (timeOfDay - 18) * 0.25;
    }
    if (timeOfDay >= 20 || timeOfDay < 5) return 0.75;
    if (timeOfDay >= 5 && timeOfDay < 6) return 0.75 - (timeOfDay - 5) * 0.6;
    return 0.75;
  }
}
