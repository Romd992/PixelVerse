import 'package:flutter/material.dart';

/// Pause menu overlay.
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSave;
  final VoidCallback onTitle;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onSave,
    required this.onTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C1810),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8D6E63), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '游戏暂停',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuButton('继续游戏', Icons.play_arrow, onResume),
              const SizedBox(height: 12),
              _buildMenuButton('保存游戏', Icons.save, onSave),
              const SizedBox(height: 12),
              _buildMenuButton('返回主菜单', Icons.home, onTitle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
