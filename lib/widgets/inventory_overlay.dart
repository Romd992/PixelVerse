import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';

/// Full inventory/backpack overlay (4 rows x 8 cols = 32 slots).
class InventoryOverlay extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onClose;
  final void Function(int index) onSelectSlot;

  const InventoryOverlay({
    super.key,
    required this.gameState,
    required this.onClose,
    required this.onSelectSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3E2723),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8D6E63), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hotbar row
            const Text(
              'Hotbar',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildSlotRow(0, 8),
            const SizedBox(height: 16),
            // Backpack
            const Text(
              'Backpack',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildSlotRow(8, 16),
            const SizedBox(height: 6),
            _buildSlotRow(16, 24),
            const SizedBox(height: 6),
            _buildSlotRow(24, 32),
            const SizedBox(height: 16),
            // Selected item info
            _buildSelectedInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotRow(int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final index = start + i;
        final slot = gameState.inventory.slots[index];
        final isSelected = gameState.inventory.selectedHotbarIndex == index;
        return GestureDetector(
          onTap: () => onSelectSlot(index),
          child: Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.black38,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: slot.isEmpty
                ? null
                : Stack(
                    children: [
                      Center(child: _buildItemIcon(slot.itemId)),
                      if (slot.count > 1)
                        Positioned(
                          right: 3,
                          bottom: 1,
                          child: Text(
                            '${slot.count}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectedInfo() {
    final slot = gameState.inventory.selectedSlot;
    if (slot.isEmpty) {
      return const SizedBox.shrink();
    }
    final def = slot.itemDef!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            def.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${def.category.name} • Sell: ${def.sellPrice}g',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildItemIcon(int itemId) {
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
    return Icon(icon, color: color, size: 28);
  }
}
