import 'package:flutter/material.dart';
import '../game/game_world.dart';

/// 商店界面（覆盖在游戏画面上，游戏暂停）
///
/// 可用金币购买药水、盾牌、疾风靴、攻击力提升。
class ShopScreen extends StatelessWidget {
  final GameWorld world;
  final VoidCallback onClose;

  const ShopScreen({
    super.key,
    required this.world,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.brown[850] ?? Colors.brown[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题 + 金币
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '商人的商店',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/coin.png',
                          width: 24, height: 24, filterQuality: FilterQuality.low),
                      const SizedBox(width: 6),
                      Text(
                        '${world.coinsCollected}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 商品列表
              _buildShopItem(
                icon: Image.asset('assets/images/potion.png',
                    width: 36, height: 36, filterQuality: FilterQuality.low),
                name: '药水',
                desc: '恢复 1 点生命值',
                price: 20,
                canAfford: world.coinsCollected >= 20,
                onBuy: () => world.buyPotion(),
              ),
              const SizedBox(height: 10),
              _buildShopItem(
                icon: Image.asset('assets/images/shield.png',
                    width: 36, height: 36, filterQuality: FilterQuality.low),
                name: '盾牌',
                desc: '受伤减半（本关有效）',
                price: 50,
                owned: world.player.hasShield,
                canAfford: world.coinsCollected >= 50,
                onBuy: () => world.buyShield(),
              ),
              const SizedBox(height: 10),
              _buildShopItem(
                icon: Image.asset('assets/images/boots.png',
                    width: 36, height: 36, filterQuality: FilterQuality.low),
                name: '疾风靴',
                desc: '移速 +30%（本关有效）',
                price: 80,
                owned: world.player.hasBoots,
                canAfford: world.coinsCollected >= 80,
                onBuy: () => world.buyBoots(),
              ),
              const SizedBox(height: 10),
              _buildShopItem(
                icon: const Icon(Icons.bolt, color: Colors.amber, size: 32),
                name: '攻击强化',
                desc: '攻击力永久 +5',
                price: 100,
                canAfford: world.coinsCollected >= 100,
                onBuy: () => world.buyAttack(),
              ),
              const SizedBox(height: 20),
              // 关闭按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.brown[900],
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('离开商店'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required Widget icon,
    required String name,
    required String desc,
    required int price,
    required bool canAfford,
    required VoidCallback onBuy,
    bool owned = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, height: 40, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(desc,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (owned)
            const Text('已拥有',
                style: TextStyle(color: Colors.greenAccent, fontSize: 13))
          else
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: canAfford ? Colors.amber : Colors.grey,
                foregroundColor: Colors.brown[900],
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/coin.png',
                      width: 16, height: 16, filterQuality: FilterQuality.low),
                  const SizedBox(width: 4),
                  Text('$price'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
