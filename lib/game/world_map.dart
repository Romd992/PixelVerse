import 'package:flutter/painting.dart';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../components/world_object.dart';
import '../models/game_state.dart';

/// Tile indices in tileset.png
class TileIndices {
  static const int grass = 0;
  static const int dirt = 1;
  static const int stone = 2;
  static const int sand = 3;
  static const int water = 4;
  static const int tilled = 5;
  static const int wetTilled = 6;
  static const int stonePath = 7;
  static const int woodFloor = 8;
  static const int stoneBrick = 9;
  static const int caveFloor = 10;
  static const int lava = 11;
  static const int snow = 12;
  static const int flower = 13;
}

/// The world map: tile grid, static objects, collision.
class WorldMap extends PositionComponent {
  static const int mapWidth = 60;
  static const int mapHeight = 60;
  static const double tileSize = 32.0;
  static const double tileTextureSize = 16.0;

  final GameState gameState;
  final List<List<int>> _tiles =
      List.generate(mapHeight, (_) => List.filled(mapWidth, TileIndices.grass));

  // Tile sprites extracted from tileset
  final List<Sprite?> _tileSprites = List.filled(32, null);

  // Static world objects
  final List<WorldObject> worldObjects = [];

  // Mine-specific data
  bool isMine = false;

  final Random _rand = Random(42); // fixed seed for consistent world

  WorldMap({required this.gameState, this.isMine = false})
      : super(size: Vector2(mapWidth * tileSize, mapHeight * tileSize));

  /// Load tile sprites from the tileset image.
  void loadTiles(SpriteSheet tilesetSheet) {
    for (int i = 0; i < 32; i++) {
      _tileSprites[i] = tilesetSheet.getSprite(i ~/ 8, i % 8);
    }
  }

  /// Generate the farm map.
  void generateFarmMap() {
    // Base: all grass
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        _tiles[y][x] = TileIndices.grass;
      }
    }

    // Water pond in top-right area
    for (int y = 5; y < 12; y++) {
      for (int x = 45; x < 55; x++) {
        final dx = x - 50;
        final dy = y - 8;
        if (dx * dx + dy * dy < 20) {
          _tiles[y][x] = TileIndices.water;
        }
      }
    }

    // Sandy beach around pond
    for (int y = 4; y < 13; y++) {
      for (int x = 44; x < 56; x++) {
        if (_tiles[y][x] == TileIndices.grass) {
          final dx = x - 50;
          final dy = y - 8;
          if (dx * dx + dy * dy < 28) {
            _tiles[y][x] = TileIndices.sand;
          }
        }
      }
    }

    // Dirt path from house to shop to mine
    for (int x = 28; x < 45; x++) {
      _tiles[30][x] = TileIndices.dirt;
      _tiles[31][x] = TileIndices.dirt;
    }
    for (int y = 20; y < 30; y++) {
      _tiles[y][43] = TileIndices.dirt;
      _tiles[y][44] = TileIndices.dirt;
    }
    // Path to mine (left side)
    for (int x = 10; x < 28; x++) {
      _tiles[30][x] = TileIndices.dirt;
    }
    for (int y = 30; y < 40; y++) {
      _tiles[y][12] = TileIndices.dirt;
      _tiles[y][13] = TileIndices.dirt;
    }

    // Flower patches
    for (int i = 0; i < 40; i++) {
      final fx = _rand.nextInt(mapWidth - 4) + 2;
      final fy = _rand.nextInt(mapHeight - 4) + 2;
      if (_tiles[fy][fx] == TileIndices.grass) {
        _tiles[fy][fx] = TileIndices.flower;
      }
    }

    // Stone path near buildings
    for (int y = 28; y < 33; y++) {
      for (int x = 26; x < 30; x++) {
        if (_tiles[y][x] == TileIndices.grass ||
            _tiles[y][x] == TileIndices.dirt) {
          _tiles[y][x] = TileIndices.stonePath;
        }
      }
    }
  }

  /// Generate the mine map.
  void generateMineMap() {
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        _tiles[y][x] = TileIndices.caveFloor;
      }
    }

    // Lava pools
    for (int i = 0; i < 5; i++) {
      final cx = _rand.nextInt(mapWidth - 10) + 5;
      final cy = _rand.nextInt(mapHeight - 10) + 5;
      for (int y = cy - 2; y <= cy + 2; y++) {
        for (int x = cx - 2; x <= cx + 2; x++) {
          if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
            final dx = x - cx;
            final dy = y - cy;
            if (dx * dx + dy * dy < 5) {
              _tiles[y][x] = TileIndices.lava;
            }
          }
        }
      }
    }

    // Stone brick walls around edges
    for (int x = 0; x < mapWidth; x++) {
      _tiles[0][x] = TileIndices.stoneBrick;
      _tiles[mapHeight - 1][x] = TileIndices.stoneBrick;
    }
    for (int y = 0; y < mapHeight; y++) {
      _tiles[y][0] = TileIndices.stoneBrick;
      _tiles[y][mapWidth - 1] = TileIndices.stoneBrick;
    }
  }

  /// Get the tile index at world coordinates.
  int getTileAtWorld(double wx, double wy) {
    final tx = (wx / tileSize).floor();
    final ty = (wy / tileSize).floor();
    return getTile(tx, ty);
  }

  /// Get the tile index at tile coordinates.
  int getTile(int tx, int ty) {
    if (tx < 0 || tx >= mapWidth || ty < 0 || ty >= mapHeight) {
      return TileIndices.stoneBrick;
    }
    // Check modified tiles (tilled soil etc.)
    final key = '$tx,$ty';
    final modified = gameState.modifiedTiles[key];
    if (modified != null) return modified;
    return _tiles[ty][tx];
  }

  /// Check if a tile is solid (blocks movement).
  bool isTileSolid(int tx, int ty) {
    final tile = getTile(tx, ty);
    return tile == TileIndices.water ||
        tile == TileIndices.lava ||
        tile == TileIndices.stoneBrick;
  }

  /// Check if a world position is on a solid tile.
  bool isPositionSolid(double wx, double wy) {
    final tx = (wx / tileSize).floor();
    final ty = (wy / tileSize).floor();
    return isTileSolid(tx, ty);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render all tiles using code-drawn fallback colors (Flame 1.18 + Web CanvasKit sprite issue)
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        final tile = getTile(x, y);
        final dx = x * tileSize;
        final dy = y * tileSize;
        canvas.drawRect(
          Rect.fromLTWH(dx, dy, tileSize, tileSize),
          Paint()..color = _tileColorWithVariation(tile, x, y),
        );
      }
    }

    // Water animation: subtle shimmer overlay on water tiles
    if (!isMine) {
      final shimmer = (sin(_waterTimer * 2) + 1) / 2;
      final waterPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.08 + shimmer * 0.05);
      for (int y = 0; y < mapHeight; y++) {
        for (int x = 0; x < mapWidth; x++) {
          if (getTile(x, y) == TileIndices.water) {
            final dx = x * tileSize;
            final dy = y * tileSize + sin(_waterTimer + x * 0.5 + y * 0.3) * 2;
            canvas.drawRect(
              Rect.fromLTWH(dx + 4, dy + 8, tileSize - 8, 4),
              waterPaint,
            );
          }
        }
      }
    }
  }

  double _waterTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _waterTimer += dt;
  }

  Color _fallbackTileColor(int tile) {
    switch (tile) {
      case TileIndices.grass:
        return const Color(0xFF4CAF50);
      case TileIndices.dirt:
        return const Color(0xFF8B6914);
      case TileIndices.stone:
        return const Color(0xFF9E9E9E);
      case TileIndices.sand:
        return const Color(0xFFF4E4BC);
      case TileIndices.water:
        return const Color(0xFF2196F3);
      case TileIndices.tilled:
        return const Color(0xFF6D4C2A);
      case TileIndices.wetTilled:
        return const Color(0xFF4A3520);
      case TileIndices.stonePath:
        return const Color(0xFFBDBDBD);
      case TileIndices.woodFloor:
        return const Color(0xFFC4A35A);
      case TileIndices.stoneBrick:
        return const Color(0xFF616161);
      case TileIndices.caveFloor:
        return const Color(0xFF3E2723);
      case TileIndices.lava:
        return const Color(0xFFFF5722);
      case TileIndices.snow:
        return const Color(0xFFECEFF1);
      case TileIndices.flower:
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  /// Get tile color with subtle per-tile variation (grass/dirt/sand only).
  Color _tileColorWithVariation(int tile, int tx, int ty) {
    final base = _fallbackTileColor(tile);
    // Only vary natural tiles
    if (tile == TileIndices.grass || tile == TileIndices.flower) {
      // Deterministic pseudo-random based on tile coords
      final h = (tx * 73856093 ^ ty * 19349663) & 0xFFFF;
      final variation = (h % 30) - 15; // -15 to +15
      return _adjustBrightness(base, variation);
    }
    if (tile == TileIndices.dirt || tile == TileIndices.sand) {
      final h = (tx * 83492791 ^ ty * 2971215073) & 0xFFFF;
      final variation = (h % 20) - 10;
      return _adjustBrightness(base, variation);
    }
    return base;
  }

  /// Adjust color brightness by delta (-255 to +255).
  Color _adjustBrightness(Color c, int delta) {
    int clamp(int v) => v < 0 ? 0 : (v > 255 ? 255 : v);
    return Color.fromARGB(
      c.alpha,
      clamp(c.red + delta),
      clamp(c.green + delta),
      clamp(c.blue + delta),
    );
  }
}
