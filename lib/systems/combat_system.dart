import '../models/game_state.dart';
import '../models/item.dart';

/// Result of an attack action.
class AttackResult {
  final bool hit;
  final int damage;
  final double knockbackX;
  final double knockbackY;

  const AttackResult({
    required this.hit,
    this.damage = 0,
    this.knockbackX = 0,
    this.knockbackY = 0,
  });
}

/// Handles combat: player attacks, enemy damage, death drops.
class CombatSystem {
  static const double attackRange = 48.0;
  static const double attackWidth = 40.0;
  static const int baseSwordDamage = 2;
  static const double knockbackForce = 120.0;

  /// Check if the player has a sword equipped.
  static bool hasSword(GameState state) {
    final selected = state.inventory.selectedSlot;
    return !selected.isEmpty && selected.itemId == Items.sword;
  }

  /// Calculate attack hitbox in front of the player.
  static ({double x, double y, double w, double h}) getAttackHitbox(
    double playerX,
    double playerY,
    String direction,
  ) {
    double hbX = playerX;
    double hbY = playerY;
    double hbW = attackWidth;
    double hbH = attackWidth;

    switch (direction) {
      case 'up':
        hbY -= attackRange;
        hbX -= attackWidth / 2;
        break;
      case 'down':
        hbY += attackRange - attackWidth;
        hbX -= attackWidth / 2;
        break;
      case 'left':
        hbX -= attackRange;
        hbY -= attackWidth / 2;
        break;
      case 'right':
        hbX += attackRange - attackWidth;
        hbY -= attackWidth / 2;
        break;
    }

    return (x: hbX, y: hbY, w: hbW, h: hbH);
  }

  /// Check if a point is inside the attack hitbox.
  static bool isInHitbox(
    double px,
    double py,
    double hbX,
    double hbY,
    double hbW,
    double hbH,
  ) {
    return px >= hbX && px <= hbX + hbW && py >= hbY && py <= hbY + hbH;
  }

  /// Get drops for an enemy type.
  static List<int> getDrops(String enemyType) {
    switch (enemyType) {
      case 'slime':
        return [21, 21]; // coins
      case 'bat':
        return [21, 21, 21];
      case 'skeleton':
        return [21, 21, 21, 10]; // coins + coal
      default:
        return [21];
    }
  }

  /// Apply damage to player, handle death.
  static bool damagePlayer(GameState state, int damage) {
    state.health -= damage;
    if (state.health <= 0) {
      state.health = 0;
      return true; // player died
    }
    return false;
  }

  /// Respawn player at home.
  static void respawnPlayer(GameState state) {
    state.health = state.maxHealth;
    state.energy = state.maxEnergy;
    state.playerX = 960;
    state.playerY = 960;
    state.scene = GameScene.farm;
    // Lose some coins as penalty
    state.coins = (state.coins * 0.5).floor();
  }
}
