import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import 'pixel_ui.dart';
import 'item_icon.dart';

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
        decoration: PixelUi.panelDecoration(
          bgColor: const Color(0xFF3E2723),
          radius: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '背包',
                  style: PixelUi.outlinedText(
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
              '快捷栏',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildSlotRow(0, 8),
            const SizedBox(height: 16),
            // Backpack
            const Text(
              '背包',
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
                      Center(child: ItemIcon(itemId: slot.itemId, size: 36)),
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
            '${_categoryName(def.category)} • 售价: ${def.sellPrice}金币',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _categoryName(ItemCategory cat) {
    switch (cat) {
      case ItemCategory.tool:
        return '工具';
      case ItemCategory.resource:
        return '资源';
      case ItemCategory.seed:
        return '种子';
      case ItemCategory.crop:
        return '作物';
      case ItemCategory.food:
        return '食物';
      case ItemCategory.material:
        return '材料';
      case ItemCategory.misc:
        return '其他';
    }
  }
}
