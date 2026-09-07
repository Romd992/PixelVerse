import 'item.dart';

/// A single inventory slot holding an item and a stack count.
class InventorySlot {
  int itemId;
  int count;

  InventorySlot({this.itemId = -1, this.count = 0});

  bool get isEmpty => itemId < 0 || count <= 0;

  ItemDef? get itemDef => isEmpty ? null : Items.getById(itemId);

  void clear() {
    itemId = -1;
    count = 0;
  }

  Map<String, dynamic> toJson() => {'id': itemId, 'c': count};

  factory InventorySlot.fromJson(Map<String, dynamic> json) {
    return InventorySlot(
      itemId: (json['id'] as num?)?.toInt() ?? -1,
      count: (json['c'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Manages the player's inventory: hotbar (8 slots) + backpack (32 slots).
class Inventory {
  static const int hotbarSize = 8;
  static const int backpackSize = 32;
  static const int totalSize = hotbarSize + backpackSize;

  final List<InventorySlot> slots =
      List.generate(totalSize, (_) => InventorySlot());

  int selectedHotbarIndex = 0;

  InventorySlot get selectedSlot => slots[selectedHotbarIndex];

  /// Add an item to the inventory. Returns the amount that could NOT be added.
  int addItem(int itemId, int count) {
    if (count <= 0 || itemId < 0) return count;
    final def = Items.getById(itemId);
    int remaining = count;

    // First, try to stack with existing slots
    for (int i = 0; i < totalSize && remaining > 0; i++) {
      final slot = slots[i];
      if (!slot.isEmpty && slot.itemId == itemId) {
        final space = def.maxStack - slot.count;
        if (space > 0) {
          final add = space < remaining ? space : remaining;
          slot.count += add;
          remaining -= add;
        }
      }
    }

    // Then, fill empty slots
    for (int i = 0; i < totalSize && remaining > 0; i++) {
      final slot = slots[i];
      if (slot.isEmpty) {
        final add = def.maxStack < remaining ? def.maxStack : remaining;
        slot.itemId = itemId;
        slot.count = add;
        remaining -= add;
      }
    }

    return remaining;
  }

  /// Remove items from the inventory. Returns true if successful.
  bool removeItem(int itemId, int count) {
    if (countOf(itemId) < count) return false;
    int remaining = count;
    for (int i = 0; i < totalSize && remaining > 0; i++) {
      final slot = slots[i];
      if (!slot.isEmpty && slot.itemId == itemId) {
        final remove = slot.count < remaining ? slot.count : remaining;
        slot.count -= remove;
        remaining -= remove;
        if (slot.count <= 0) slot.clear();
      }
    }
    return true;
  }

  /// Total count of a specific item across all slots.
  int countOf(int itemId) {
    int total = 0;
    for (final slot in slots) {
      if (!slot.isEmpty && slot.itemId == itemId) total += slot.count;
    }
    return total;
  }

  /// Check if the inventory has at least [count] of [itemId].
  bool hasItem(int itemId, int count) => countOf(itemId) >= count;

  /// Swap two slots.
  void swapSlots(int a, int b) {
    if (a < 0 || a >= totalSize || b < 0 || b >= totalSize) return;
    final tempId = slots[a].itemId;
    final tempCount = slots[a].count;
    slots[a].itemId = slots[b].itemId;
    slots[a].count = slots[b].count;
    slots[b].itemId = tempId;
    slots[b].count = tempCount;
  }

  /// Consume one item from the selected hotbar slot.
  void consumeSelected() {
    final slot = selectedSlot;
    if (!slot.isEmpty) {
      slot.count--;
      if (slot.count <= 0) slot.clear();
    }
  }

  /// Give the player starting tools and resources.
  void giveStarterItems() {
    addItem(Items.axe, 1);
    addItem(Items.pickaxe, 1);
    addItem(Items.hoe, 1);
    addItem(Items.wateringCan, 1);
    addItem(Items.wood, 5);
    addItem(Items.wheatSeeds, 5);
    addItem(Items.carrotSeeds, 3);
    addItem(Items.potatoSeeds, 3);
  }

  List<Map<String, dynamic>> toJson() =>
      slots.map((s) => s.toJson()).toList();

  void loadFromJson(List<dynamic> json) {
    for (int i = 0; i < totalSize && i < json.length; i++) {
      slots[i] = InventorySlot.fromJson(
          Map<String, dynamic>.from(json[i] as Map));
    }
  }
}
