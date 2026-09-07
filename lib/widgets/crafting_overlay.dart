import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../systems/crafting_system.dart';

/// Crafting overlay: shows recipes at workbench/furnace.
class CraftingOverlay extends StatefulWidget {
  final GameState gameState;
  final String station; // 'workbench' or 'furnace'
  final VoidCallback onClose;
  final VoidCallback onCrafted;

  const CraftingOverlay({
    super.key,
    required this.gameState,
    required this.station,
    required this.onClose,
    required this.onCrafted,
  });

  @override
  State<CraftingOverlay> createState() => _CraftingOverlayState();
}

class _CraftingOverlayState extends State<CraftingOverlay> {
  @override
  Widget build(BuildContext context) {
    final recipes = Recipes.forStation(widget.station);

    return Center(
      child: Container(
        width: 560,
        height: 480,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8D6E63), width: 3),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.station == 'furnace' ? '炉子' : '工作台',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final canCraft = CraftingSystem.canCraft(recipe, widget.gameState);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: canCraft
                          ? Colors.green.withOpacity(0.15)
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canCraft ? Colors.green : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Result icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: _buildItemIcon(recipe.resultItemId),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Recipe info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${recipe.name} x${recipe.resultCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                recipe.ingredients.entries
                                    .map((e) =>
                                        '${Items.getById(e.key).name} x${e.value}')
                                    .join('  +  '),
                                style: TextStyle(
                                  color: canCraft
                                      ? Colors.green.shade300
                                      : Colors.red.shade300,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Craft button
                        ElevatedButton(
                          onPressed: canCraft
                              ? () {
                                  final result = CraftingSystem.craft(
                                      recipe, widget.gameState);
                                  if (result.success) {
                                    widget.onCrafted();
                                    setState(() {});
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('制作'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
    return Icon(icon, color: color, size: 24);
  }
}
