import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import 'pixel_ui.dart';

/// The heads-up display: health, energy, coins, time, hotbar.
class Hud extends StatelessWidget {
  final GameState gameState;
  final void Function(int index) onHotbarSelect;
  final VoidCallback onOpenInventory;
  final VoidCallback onPause;

  const Hud({
    super.key,
    required this.gameState,
    required this.onHotbarSelect,
    required this.onOpenInventory,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top-left: stats
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthBar(),
                const SizedBox(height: 4),
                _buildEnergyBar(),
                const SizedBox(height: 4),
                _buildCoinDisplay(),
              ],
            ),
          ),
          // Top-right: date/time + buttons
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDateTime(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconButton(Icons.backpack, onOpenInventory),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.pause, onPause),
                  ],
                ),
              ],
            ),
          ),
          // Bottom-center: hotbar
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(child: _buildHotbar()),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 20),
        const SizedBox(width: 4),
        Container(
          width: 100,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white30),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: gameState.health / gameState.maxHealth,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${gameState.health}/${gameState.maxHealth}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.bolt, color: Colors.yellow, size: 20),
        const SizedBox(width: 4),
        Container(
          width: 100,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white30),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: gameState.energy / gameState.maxEnergy,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${gameState.energy}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCoinDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          '${gameState.coins}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            gameState.timeString,
            style: PixelUi.outlinedText(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${gameState.seasonName} ${gameState.day}',
            style: PixelUi.outlinedText(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          Text(
            gameState.weatherName,
            style: TextStyle(
              color: gameState.weather == Weather.rainy
                  ? Colors.lightBlueAccent
                  : Colors.amber,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildHotbar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: PixelUi.panelDecoration(
        bgColor: const Color(0xFF2C1810).withOpacity(0.9),
        radius: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(8, (index) {
          final slot = gameState.inventory.slots[index];
          final isSelected = gameState.inventory.selectedHotbarIndex == index;
          return GestureDetector(
            onTap: () => onHotbarSelect(index),
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown.withOpacity(0.8) : Colors.black38,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: slot.isEmpty
                  ? Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        Center(
                          child: _buildItemIcon(slot.itemId),
                        ),
                        if (slot.count > 1)
                          Positioned(
                            right: 2,
                            bottom: 0,
                            child: Text(
                              '${slot.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemIcon(int itemId) {
    // Use emoji/colored container as fallback since we can't easily
    // render the items.png sprite sheet in a widget
    final def = Items.getById(itemId);
    IconData icon;
    Color color;
    switch (def.category) {
      case ItemCategory.tool:
        icon = Icons.build;
        color = Colors.grey;
        break;
      case ItemCategory.resource:
        icon = Icons.forest;
        color = Colors.brown;
        break;
      case ItemCategory.seed:
        icon = Icons.eco;
        color = Colors.green;
        break;
      case ItemCategory.crop:
        icon = Icons.grass;
        color = Colors.lightGreen;
        break;
      case ItemCategory.food:
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case ItemCategory.material:
        icon = Icons.inventory_2;
        color = Colors.amber;
        break;
      case ItemCategory.misc:
        icon = Icons.star;
        color = Colors.cyan;
        break;
    }
    return Icon(icon, color: color, size: 24);
  }
}
