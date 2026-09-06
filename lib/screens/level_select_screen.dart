import 'package:flutter/material.dart';
import '../models/save_manager.dart';
import '../models/level_config.dart';

/// 关卡选择界面
///
/// 显示3个关卡，已解锁的可点击进入，未解锁的显示锁图标。
class LevelSelectScreen extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(int levelIndex) onSelectLevel;

  const LevelSelectScreen({
    super.key,
    required this.onBack,
    required this.onSelectLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.png',
            fit: BoxFit.cover, filterQuality: FilterQuality.low),
        Container(color: Colors.black.withOpacity(0.55)),
        SafeArea(
          child: Column(
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBack,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '选择关卡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 关卡卡片
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: LevelConfig.levels.length,
                  itemBuilder: (context, index) {
                    final level = LevelConfig.levels[index];
                    final unlocked = SaveManager.isLevelUnlocked(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _LevelCard(
                        index: index,
                        name: level.name,
                        objective: level.objectiveText,
                        unlocked: unlocked,
                        onTap: unlocked ? () => onSelectLevel(index) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int index;
  final String name;
  final String objective;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.index,
    required this.name,
    required this.objective,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? Colors.brown[800] : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: unlocked ? Colors.amber : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: unlocked
                    ? Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: unlocked ? Colors.amber : Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    objective,
                    style: TextStyle(
                      color: unlocked ? Colors.white70 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.chevron_right, color: Colors.amber, size: 28),
          ],
        ),
      ),
    );
  }
}
