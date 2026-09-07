import 'package:flutter/material.dart';
import '../game/game_world.dart';
import '../models/weapon.dart';
import '../models/skill.dart';
import 'virtual_joystick.dart';
import 'skill_button.dart';

/// 触屏控件总成
///
/// 左下角：虚拟摇杆（移动）
/// 右下角：攻击按钮 + 武器切换按钮 + 3个技能按钮（Q/W/E）
/// 所有按钮均 >= 44pt，各自独立 GestureDetector 支持多点触控。
class TouchControls extends StatelessWidget {
  final GameWorld world;

  const TouchControls({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---- 左下角：虚拟摇杆 ----
        Positioned(
          left: 16,
          bottom: 20,
          child: VirtualJoystick(
            size: 120,
            onDirectionChanged: (dx, dy) {
              world.setJoystickInput(dx, dy);
            },
          ),
        ),

        // ---- 右下角：技能按钮行（在攻击按钮上方） ----
        Positioned(
          right: 16,
          bottom: 110,
          child: Row(
            children: [
              SkillButton(
                skill: SkillType.dash,
                remainingCooldown: world.player.dashSkill.remainingCooldown,
                onTap: () => world.castSkill(SkillType.dash),
              ),
              const SizedBox(width: 8),
              SkillButton(
                skill: SkillType.whirlwind,
                remainingCooldown: world.player.whirlwindSkill.remainingCooldown,
                onTap: () => world.castSkill(SkillType.whirlwind),
              ),
              const SizedBox(width: 8),
              SkillButton(
                skill: SkillType.heal,
                remainingCooldown: world.player.healSkill.remainingCooldown,
                onTap: () => world.castSkill(SkillType.heal),
              ),
            ],
          ),
        ),

        // ---- 右下角：武器切换 + 攻击按钮 ----
        Positioned(
          right: 16,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 武器切换按钮
              _buildWeaponButton(),
              const SizedBox(width: 12),
              // 攻击按钮
              _buildAttackButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// 武器切换按钮（显示当前武器，点击切换到下一把）
  Widget _buildWeaponButton() {
    final p = world.player;
    final owned = p.ownedWeapons;
    final currentIndex = owned.indexOf(p.currentWeapon);

    // 当前武器图标：弓/法杖用素材，剑用文字
    Widget icon;
    if (p.currentWeapon == WeaponType.bow) {
      icon = Image.asset('assets/images/bow.png',
          width: 28, height: 28, filterQuality: FilterQuality.low);
    } else if (p.currentWeapon == WeaponType.staff) {
      icon = Image.asset('assets/images/staff.png',
          width: 28, height: 28, filterQuality: FilterQuality.low);
    } else {
      icon = const Text('剑',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
    }

    return GestureDetector(
      onTap: owned.length > 1
          ? () {
              final next = owned[(currentIndex + 1) % owned.length];
              world.switchWeapon(next);
            }
          : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.75),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 4),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  /// 攻击按钮（大圆形）
  Widget _buildAttackButton() {
    return GestureDetector(
      onTap: () => world.requestAttack(),
      child: Container(
        width: 82,
        height: 82,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
