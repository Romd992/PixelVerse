import 'package:flutter/material.dart';

/// 攻击按钮（右下角触控控件）
///
/// 点击触发玩家攻击。圆形红色按钮，带白色边框和阴影。
class AttackButton extends StatelessWidget {
  final VoidCallback onAttack;
  final double size;

  const AttackButton({
    super.key,
    required this.onAttack,
    this.size = 82,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAttack,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.75),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '攻击',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
