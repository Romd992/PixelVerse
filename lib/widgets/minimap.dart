import 'package:flutter/material.dart';
import '../game/game_world.dart';

/// 小地图（右上角半透明）
///
/// 显示玩家（白点）、敌人（红点）、传送门（绿点）、商人（黄点）、BOSS（紫点）。
class Minimap extends StatelessWidget {
  final GameWorld world;
  final double width;
  final double height;

  const Minimap({
    super.key,
    required this.world,
    this.width = 120,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: CustomPaint(
        painter: _MinimapPainter(world, width, height),
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  final GameWorld world;
  final double mapW;
  final double mapH;

  _MinimapPainter(this.world, this.mapW, this.mapH);

  @override
  void paint(Canvas canvas, Size size) {
    double sx(double wx) => (wx / world.worldWidth) * mapW;
    double sy(double wy) => (wy / world.worldHeight) * mapH;

    // 传送门（绿点）
    if (world.portal != null) {
      final p = world.portal!;
      _drawDot(canvas, sx(p.x + p.width / 2), sy(p.y + p.height / 2),
          4, Colors.greenAccent);
    }

    // 商人（黄点）
    if (world.merchant != null) {
      final m = world.merchant!;
      _drawDot(canvas, sx(m.x + m.width / 2), sy(m.y + m.height / 2),
          3.5, Colors.amber);
    }

    // 敌人（红点），BOSS（大紫点）
    for (final e in world.enemies) {
      if (e.isDead) continue;
      if (e.isBoss) {
        _drawDot(canvas, sx(e.x + e.width / 2), sy(e.y + e.height / 2),
            6, Colors.purpleAccent);
      } else {
        _drawDot(canvas, sx(e.x + e.width / 2), sy(e.y + e.height / 2),
            3, Colors.redAccent);
      }
    }

    // 玩家（白点）
    final p = world.player;
    _drawDot(canvas, sx(p.x + p.width / 2), sy(p.y + p.height / 2),
        4.5, Colors.white);
  }

  void _drawDot(Canvas canvas, double x, double y, double r, Color color) {
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) => true;
}
