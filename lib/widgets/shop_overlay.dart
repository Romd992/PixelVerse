import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/inventory.dart';

/// A shop item entry.
class ShopItem {
  final int itemId;
  final int buyPrice;
  final int stock;

  const ShopItem({
    required this.itemId,
    required this.buyPrice,
    this.stock = 99,
  });
}

/// Shop overlay: buy items and sell inventory items.
class ShopOverlay extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onClose;
  final VoidCallback onTransaction;

  const ShopOverlay({
    super.key,
    required this.gameState,
    required this.onClose,
    required this.onTransaction,
  });

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  bool _buyMode = true;

  static const List<ShopItem> shopItems = [
    ShopItem(itemId: Items.wheatSeeds, buyPrice: 10),
    ShopItem(itemId: Items.carrotSeeds, buyPrice: 15),
    ShopItem(itemId: Items.potatoSeeds, buyPrice: 15),
    ShopItem(itemId: Items.axe, buyPrice: 50),
    ShopItem(itemId: Items.pickaxe, buyPrice: 50),
    ShopItem(itemId: Items.hoe, buyPrice: 30),
    ShopItem(itemId: Items.wateringCan, buyPrice: 30),
    ShopItem(itemId: Items.sword, buyPrice: 80),
    ShopItem(itemId: Items.coal, buyPrice: 8),
    ShopItem(itemId: Items.wood, buyPrice: 5),
    ShopItem(itemId: Items.stone, buyPrice: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A90D9), width: 3),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pierre's General Store",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.gameState.coins}g',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Buy/Sell toggle
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _buyMode = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _buyMode ? Colors.blue : Colors.grey[700],
                    ),
                    child: const Text('Buy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _buyMode = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_buyMode ? Colors.orange : Colors.grey[700],
                    ),
                    child: const Text('Sell'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Expanded(
              child: _buyMode ? _buildBuyList() : _buildSellList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyList() {
    return ListView.builder(
      itemCount: shopItems.length,
      itemBuilder: (context, index) {
        final item = shopItems[index];
        final def = Items.getById(item.itemId);
        final canAfford = widget.gameState.coins >= item.buyPrice;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _buildItemIcon(item.itemId),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  def.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Text(
                '${item.buyPrice}g',
                style: TextStyle(
                  color: canAfford ? Colors.amber : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        widget.gameState.coins -= item.buyPrice;
                        widget.gameState.inventory.addItem(item.itemId, 1);
                        widget.onTransaction();
                        setState(() {});
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                ),
                child: const Text('Buy'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSellList() {
    final sellable = <int>[];
    for (int i = 0; i < Inventory.totalSize; i++) {
      final slot = widget.gameState.inventory.slots[i];
      if (!slot.isEmpty && slot.itemDef!.sellPrice > 0) {
        sellable.add(i);
      }
    }

    if (sellable.isEmpty) {
      return const Center(
        child: Text(
          'No sellable items',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: sellable.length,
      itemBuilder: (context, index) {
        final slotIndex = sellable[index];
        final slot = widget.gameState.inventory.slots[slotIndex];
        final def = slot.itemDef!;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _buildItemIcon(slot.itemId),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${def.name} x${slot.count}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Text(
                '${def.sellPrice}g each',
                style: const TextStyle(
                    color: Colors.amber, fontSize: 12),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.gameState.coins += def.sellPrice;
                  widget.gameState.inventory.removeItem(slot.itemId, 1);
                  widget.onTransaction();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                ),
                child: const Text('Sell 1'),
              ),
            ],
          ),
        );
      },
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
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
