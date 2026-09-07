import 'package:flutter/material.dart';
import '../models/save_manager.dart';

/// 设置界面
///
/// 音量控制（占位滑块）、存档数据展示。
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = SaveManager.volume;
  }

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: widget.onBack,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '设置',
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // 音量
                    _buildSectionCard(
                      title: '音量',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.volume_up, color: Colors.white70),
                              Expanded(
                                child: Slider(
                                  value: _volume,
                                  activeColor: Colors.amber,
                                  inactiveColor: Colors.white24,
                                  onChanged: (v) {
                                    setState(() => _volume = v);
                                    SaveManager.volume = v;
                                  },
                                ),
                              ),
                              Text(
                                '${(_volume * 100).round()}%',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const Text(
                            '（音效系统预留，当前为占位设置）',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 存档数据
                    _buildSectionCard(
                      title: '存档数据',
                      child: Column(
                        children: [
                          _buildStatRow('最高分', '${SaveManager.highScore}'),
                          const Divider(color: Colors.white12),
                          _buildStatRow(
                              '已解锁关卡', '${SaveManager.unlockedLevels} / 3'),
                          const Divider(color: Colors.white12),
                          _buildStatRow('总击杀数', '${SaveManager.totalKills}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 操作说明（触屏）
                    _buildSectionCard(
                      title: '操作说明',
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• 拖动摇杆移动角色',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 6),
                          Text('• 点击攻击按钮进行攻击',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 6),
                          Text('• Q冲刺 / W旋风斩 / E治疗术',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 6),
                          Text('• 点击武器按钮切换武器',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          SizedBox(height: 6),
                          Text('• 靠近商人可打开商店',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
