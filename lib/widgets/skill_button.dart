import 'package:flutter/material.dart';
import '../models/skill.dart';

/// 技能按钮（带冷却遮罩和倒计时）
///
/// 尺寸固定 52x52，满足 iOS 44pt 最小点击区域。
class SkillButton extends StatelessWidget {
  final SkillType skill;
  final double remainingCooldown;
  final VoidCallback onTap;

  const SkillButton({
    super.key,
    required this.skill,
    required this.remainingCooldown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = SkillInfo.of(skill);
    final maxCd = info.cooldown;
    final ratio = maxCd > 0 ? (remainingCooldown / maxCd).clamp(0.0, 1.0) : 0.0;
    final ready = remainingCooldown <= 0;

    return GestureDetector(
      onTap: ready ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: ready
              ? Colors.deepPurple.withOpacity(0.75)
              : Colors.grey.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: ready ? Colors.purpleAccent : Colors.white30,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 冷却遮罩（从上往下填充）
            if (!ready)
              ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: ratio,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            // 图标文字
            Text(
              info.iconText,
              style: TextStyle(
                color: ready ? Colors.white : Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 快捷键标签（左上角小字）
            Positioned(
              top: 2,
              left: 6,
              child: Text(
                info.keyLabel,
                style: TextStyle(
                  color: ready ? Colors.amber : Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 冷却倒计时数字
            if (!ready)
              Text(
                remainingCooldown.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
