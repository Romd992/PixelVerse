import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that draws a unique pixel-art style icon for each item ID
/// using CustomPaint, ensuring every item looks distinct without relying
/// on external sprite sheets.
class ItemIcon extends StatelessWidget {
  final int itemId;
  final double size;

  const ItemIcon({
    super.key,
    required this.itemId,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ItemIconPainter(itemId: itemId),
    );
  }
}

class _ItemIconPainter extends CustomPainter {
  final int itemId;

  _ItemIconPainter({required this.itemId});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final scale = s / 32.0; // design at 32x32
    canvas.save();
    canvas.scale(scale);

    switch (itemId) {
      case 0:
        _drawAxe(canvas);
        break;
      case 1:
        _drawPickaxe(canvas);
        break;
      case 2:
        _drawSword(canvas);
        break;
      case 3:
        _drawHoe(canvas);
        break;
      case 4:
        _drawWateringCan(canvas);
        break;
      case 5:
        _drawFishingRod(canvas);
        break;
      case 6:
        _drawWood(canvas);
        break;
      case 7:
        _drawStone(canvas);
        break;
      case 8:
        _drawIronOre(canvas);
        break;
      case 9:
        _drawGoldOre(canvas);
        break;
      case 10:
        _drawCoal(canvas);
        break;
      case 11:
        _drawWheatSeeds(canvas);
        break;
      case 12:
        _drawCarrotSeeds(canvas);
        break;
      case 13:
        _drawPotatoSeeds(canvas);
        break;
      case 14:
        _drawWheat(canvas);
        break;
      case 15:
        _drawCarrot(canvas);
        break;
      case 16:
        _drawPotato(canvas);
        break;
      case 17:
        _drawBerry(canvas);
        break;
      case 18:
        _drawBread(canvas);
        break;
      case 19:
        _drawApple(canvas);
        break;
      case 20:
        _drawFish(canvas);
        break;
      case 21:
        _drawCoin(canvas);
        break;
      case 22:
        _drawIronBar(canvas);
        break;
      case 23:
        _drawGoldBar(canvas);
        break;
      case 24:
        _drawPlank(canvas);
        break;
      case 25:
        _drawBrick(canvas);
        break;
      case 26:
        _drawGlass(canvas);
        break;
      case 27:
        _drawTorch(canvas);
        break;
      case 28:
        _drawFlower(canvas);
        break;
      case 29:
        _drawChest(canvas);
        break;
      case 30:
        _drawWorkbench(canvas);
        break;
      case 31:
        _drawFurnace(canvas);
        break;
      default:
        _drawUnknown(canvas);
    }

    canvas.restore();
  }

  Paint _paint(Color color, {double strokeWidth = 1.5}) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth;
  }

  Paint _stroke(Color color, {double width = 1.5}) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  // === TOOLS ===

  void _drawAxe(Canvas canvas) {
    // Handle
    canvas.drawRect(const Rect.fromLTWH(14, 8, 4, 20), _paint(const Color(0xFF8B4513)));
    // Axe head (triangle)
    final path = Path()
      ..moveTo(6, 6)
      ..lineTo(22, 6)
      ..lineTo(18, 14)
      ..lineTo(10, 14)
      ..close();
    canvas.drawPath(path, _paint(const Color(0xFFB0B0B0)));
    canvas.drawPath(path, _stroke(const Color(0xFF606060)));
    // Blade edge highlight
    canvas.drawLine(const Offset(8, 7), const Offset(20, 7), _paint(const Color(0xFFE0E0E0), strokeWidth: 1));
  }

  void _drawPickaxe(Canvas canvas) {
    // Handle
    canvas.drawRect(const Rect.fromLTWH(14, 10, 4, 18), _paint(const Color(0xFF8B4513)));
    // Pick head (T shape)
    canvas.drawRect(const Rect.fromLTWH(4, 4, 24, 5), _paint(const Color(0xFFB0B0B0)));
    canvas.drawRect(const Rect.fromLTWH(4, 4, 24, 5), _stroke(const Color(0xFF606060)));
    // Pointed ends
    final leftPath = Path()
      ..moveTo(4, 4)
      ..lineTo(1, 9)
      ..lineTo(4, 9)
      ..close();
    canvas.drawPath(leftPath, _paint(const Color(0xFF909090)));
    final rightPath = Path()
      ..moveTo(28, 4)
      ..lineTo(31, 9)
      ..lineTo(28, 9)
      ..close();
    canvas.drawPath(rightPath, _paint(const Color(0xFF909090)));
  }

  void _drawSword(Canvas canvas) {
    // Blade
    canvas.drawRect(const Rect.fromLTWH(13, 2, 6, 18), _paint(const Color(0xFFC0C0C0)));
    canvas.drawRect(const Rect.fromLTWH(13, 2, 6, 18), _stroke(const Color(0xFF707070)));
    // Blade tip
    final tip = Path()
      ..moveTo(13, 2)
      ..lineTo(16, -1)
      ..lineTo(19, 2)
      ..close();
    canvas.drawPath(tip, _paint(const Color(0xFFD0D0D0)));
    // Guard (cross)
    canvas.drawRect(const Rect.fromLTWH(8, 19, 16, 3), _paint(const Color(0xFFFFD700)));
    // Handle
    canvas.drawRect(const Rect.fromLTWH(13, 22, 6, 7), _paint(const Color(0xFF8B4513)));
    // Pommel
    canvas.drawCircle(const Offset(16, 30), 2, _paint(const Color(0xFFFFD700)));
  }

  void _drawHoe(Canvas canvas) {
    // Handle (L shape)
    canvas.drawRect(const Rect.fromLTWH(14, 6, 4, 20), _paint(const Color(0xFF8B4513)));
    canvas.drawRect(const Rect.fromLTWH(14, 6, 10, 4), _paint(const Color(0xFF8B4513)));
    // Blade
    canvas.drawRect(const Rect.fromLTWH(22, 4, 6, 8), _paint(const Color(0xFFA0A0A0)));
    canvas.drawRect(const Rect.fromLTWH(22, 4, 6, 8), _stroke(const Color(0xFF606060)));
  }

  void _drawWateringCan(Canvas canvas) {
    // Body (trapezoid)
    final body = Path()
      ..moveTo(8, 12)
      ..lineTo(24, 12)
      ..lineTo(22, 28)
      ..lineTo(10, 28)
      ..close();
    canvas.drawPath(body, _paint(const Color(0xFF4A90D9)));
    canvas.drawPath(body, _stroke(const Color(0xFF2C5F8A)));
    // Spout
    canvas.drawRect(const Rect.fromLTWH(24, 14, 6, 4), _paint(const Color(0xFF808080)));
    // Handle (arc)
    final handle = Path()
      ..moveTo(8, 14)
      ..quadraticBezierTo(2, 18, 8, 24);
    canvas.drawPath(handle, _stroke(const Color(0xFF808080), width: 2));
    // Water drops
    canvas.drawCircle(const Offset(30, 19), 1.5, _paint(const Color(0xFF87CEEB)));
    canvas.drawCircle(const Offset(29, 22), 1, _paint(const Color(0xFF87CEEB)));
  }

  void _drawFishingRod(Canvas canvas) {
    // Rod (diagonal line)
    final rod = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(4, 28), const Offset(26, 6), rod);
    // Line
    final line = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(26, 6), const Offset(22, 24), line);
    // Hook
    final hook = Path()
      ..moveTo(22, 24)
      ..lineTo(22, 27)
      ..quadraticBezierTo(22, 29, 20, 29);
    canvas.drawPath(hook, _stroke(const Color(0xFFA0A0A0), width: 1.2));
    // Rod tip highlight
    canvas.drawCircle(const Offset(26, 6), 1.5, _paint(const Color(0xFFD2691E)));
  }

  // === RESOURCES ===

  void _drawWood(Canvas canvas) {
    // Log body
    canvas.drawRect(const Rect.fromLTWH(4, 10, 24, 14), _paint(const Color(0xFF8B5A2B)));
    canvas.drawRect(const Rect.fromLTWH(4, 10, 24, 14), _stroke(const Color(0xFF5C3A1A)));
    // End rings (left)
    canvas.drawCircle(const Offset(6, 17), 4, _paint(const Color(0xFFA0724A)));
    canvas.drawCircle(const Offset(6, 17), 2.5, _paint(const Color(0xFF8B5A2B)));
    canvas.drawCircle(const Offset(6, 17), 1, _paint(const Color(0xFF6B4220)));
    // Bark lines
    canvas.drawLine(const Offset(12, 12), const Offset(12, 22), _paint(const Color(0xFF6B4220), strokeWidth: 0.8));
    canvas.drawLine(const Offset(18, 12), const Offset(18, 22), _paint(const Color(0xFF6B4220), strokeWidth: 0.8));
    canvas.drawLine(const Offset(24, 12), const Offset(24, 22), _paint(const Color(0xFF6B4220), strokeWidth: 0.8));
  }

  void _drawStone(Canvas canvas) {
    // Irregular polygon
    final path = Path()
      ..moveTo(6, 18)
      ..lineTo(8, 10)
      ..lineTo(16, 6)
      ..lineTo(24, 8)
      ..lineTo(27, 16)
      ..lineTo(24, 24)
      ..lineTo(14, 27)
      ..lineTo(7, 23)
      ..close();
    canvas.drawPath(path, _paint(const Color(0xFF9E9E9E)));
    canvas.drawPath(path, _stroke(const Color(0xFF616161)));
    // Highlights
    canvas.drawCircle(const Offset(14, 12), 2, _paint(const Color(0xFFBDBDBD)));
    canvas.drawCircle(const Offset(20, 18), 1.5, _paint(const Color(0xFFBDBDBD)));
  }

  void _drawIronOre(Canvas canvas) {
    _drawStone(canvas);
    // Iron spots (brownish)
    canvas.drawCircle(const Offset(12, 14), 2.5, _paint(const Color(0xFFC4A484)));
    canvas.drawCircle(const Offset(20, 16), 2, _paint(const Color(0xFFC4A484)));
    canvas.drawCircle(const Offset(16, 22), 1.8, _paint(const Color(0xFFB8956E)));
  }

  void _drawGoldOre(Canvas canvas) {
    _drawStone(canvas);
    // Gold spots
    canvas.drawCircle(const Offset(12, 14), 2.5, _paint(const Color(0xFFFFD700)));
    canvas.drawCircle(const Offset(20, 16), 2, _paint(const Color(0xFFFFD700)));
    canvas.drawCircle(const Offset(16, 22), 1.8, _paint(const Color(0xFFFFC107)));
    // Sparkle
    canvas.drawCircle(const Offset(13, 13), 0.8, _paint(const Color(0xFFFFFFFF)));
  }

  void _drawCoal(Canvas canvas) {
    // Black chunk
    final path = Path()
      ..moveTo(8, 20)
      ..lineTo(10, 12)
      ..lineTo(18, 8)
      ..lineTo(25, 11)
      ..lineTo(26, 20)
      ..lineTo(20, 26)
      ..lineTo(10, 24)
      ..close();
    canvas.drawPath(path, _paint(const Color(0xFF2C2C2C)));
    canvas.drawPath(path, _stroke(const Color(0xFF1A1A1A)));
    // Highlight
    canvas.drawCircle(const Offset(16, 14), 2.5, _paint(const Color(0xFF4A4A4A)));
    canvas.drawCircle(const Offset(21, 18), 1.5, _paint(const Color(0xFF3A3A3A)));
  }

  // === SEEDS ===

  void _drawSeedBag(Canvas canvas, Color bagColor, Color accentColor) {
    // Bag body
    final path = Path()
      ..moveTo(8, 14)
      ..lineTo(24, 14)
      ..lineTo(22, 28)
      ..lineTo(10, 28)
      ..close();
    canvas.drawPath(path, _paint(bagColor));
    canvas.drawPath(path, _stroke(const Color(0xFF5C3A1A)));
    // Tie
    canvas.drawRect(const Rect.fromLTWH(12, 10, 8, 5), _paint(const Color(0xFF8B4513)));
    // Accent mark
    canvas.drawCircle(const Offset(16, 21), 3, _paint(accentColor));
  }

  void _drawWheatSeeds(Canvas canvas) {
    _drawSeedBag(canvas, const Color(0xFFD2B48C), const Color(0xFF8B7355));
    // Wheat symbol
    canvas.drawLine(const Offset(16, 17), const Offset(16, 25), _paint(const Color(0xFF6B5330), strokeWidth: 1));
  }

  void _drawCarrotSeeds(Canvas canvas) {
    _drawSeedBag(canvas, const Color(0xFFE8A060), const Color(0xFFD2691E));
  }

  void _drawPotatoSeeds(Canvas canvas) {
    _drawSeedBag(canvas, const Color(0xFFA0826D), const Color(0xFF6B4423));
  }

  // === CROPS ===

  void _drawWheat(Canvas canvas) {
    // Stalks
    for (int i = 0; i < 3; i++) {
      final x = 10.0 + i * 6;
      canvas.drawLine(Offset(x, 28), Offset(x, 10), _paint(const Color(0xFFDAA520), strokeWidth: 1.5));
      // Grains (ellipses)
      for (int j = 0; j < 3; j++) {
        canvas.drawOval(Rect.fromLTWH(x - 2, 10 + j * 4, 4, 3), _paint(const Color(0xFFF4C430)));
      }
    }
  }

  void _drawCarrot(Canvas canvas) {
    // Body (triangle)
    final path = Path()
      ..moveTo(10, 10)
      ..lineTo(22, 10)
      ..lineTo(16, 28)
      ..close();
    canvas.drawPath(path, _paint(const Color(0xFFFF7F00)));
    canvas.drawPath(path, _stroke(const Color(0xFFCC6600)));
    // Leaves
    canvas.drawLine(const Offset(13, 10), const Offset(11, 4), _paint(const Color(0xFF228B22), strokeWidth: 2));
    canvas.drawLine(const Offset(16, 10), const Offset(16, 2), _paint(const Color(0xFF228B22), strokeWidth: 2));
    canvas.drawLine(const Offset(19, 10), const Offset(21, 4), _paint(const Color(0xFF228B22), strokeWidth: 2));
    // Texture lines
    canvas.drawLine(const Offset(13, 15), const Offset(19, 15), _paint(const Color(0xFFCC6600), strokeWidth: 0.6));
    canvas.drawLine(const Offset(14, 20), const Offset(18, 20), _paint(const Color(0xFFCC6600), strokeWidth: 0.6));
  }

  void _drawPotato(Canvas canvas) {
    // Oval body
    canvas.drawOval(const Rect.fromLTWH(6, 10, 20, 16), _paint(const Color(0xFFC4A484)));
    canvas.drawOval(const Rect.fromLTWH(6, 10, 20, 16), _stroke(const Color(0xFF8B7355)));
    // Eyes (spots)
    canvas.drawCircle(const Offset(12, 15), 1.2, _paint(const Color(0xFF6B5330)));
    canvas.drawCircle(const Offset(19, 17), 1, _paint(const Color(0xFF6B5330)));
    canvas.drawCircle(const Offset(15, 21), 1.3, _paint(const Color(0xFF6B5330)));
    // Highlight
    canvas.drawOval(const Rect.fromLTWH(9, 12, 6, 4), _paint(const Color(0xFFD4B896)));
  }

  void _drawBerry(Canvas canvas) {
    // Two berries
    canvas.drawCircle(const Offset(12, 18), 6, _paint(const Color(0xFFDC143C)));
    canvas.drawCircle(const Offset(12, 18), 6, _stroke(const Color(0xFF8B0000)));
    canvas.drawCircle(const Offset(21, 20), 5, _paint(const Color(0xFFE02040)));
    canvas.drawCircle(const Offset(21, 20), 5, _stroke(const Color(0xFF8B0000)));
    // Leaves
    final leaf = Path()
      ..moveTo(14, 13)
      ..lineTo(12, 7)
      ..lineTo(17, 10)
      ..close();
    canvas.drawPath(leaf, _paint(const Color(0xFF228B22)));
    // Highlights
    canvas.drawCircle(const Offset(10, 16), 1.5, _paint(const Color(0xFFFF6B6B)));
    canvas.drawCircle(const Offset(19, 18), 1.2, _paint(const Color(0xFFFF6B6B)));
  }

  void _drawBread(Canvas canvas) {
    // Rounded trapezoid (loaf)
    final path = Path()
      ..moveTo(6, 16)
      ..quadraticBezierTo(6, 10, 10, 9)
      ..lineTo(22, 9)
      ..quadraticBezierTo(26, 10, 26, 16)
      ..lineTo(24, 26)
      ..lineTo(8, 26)
      ..close();
    canvas.drawPath(path, _paint(const Color(0xFFDEB887)));
    canvas.drawPath(path, _stroke(const Color(0xFFA0826D)));
    // Crust scores
    canvas.drawLine(const Offset(11, 12), const Offset(13, 16), _paint(const Color(0xFFA0826D), strokeWidth: 1));
    canvas.drawLine(const Offset(16, 11), const Offset(16, 16), _paint(const Color(0xFFA0826D), strokeWidth: 1));
    canvas.drawLine(const Offset(21, 12), const Offset(19, 16), _paint(const Color(0xFFA0826D), strokeWidth: 1));
  }

  void _drawApple(Canvas canvas) {
    // Body
    canvas.drawOval(const Rect.fromLTWH(6, 10, 20, 18), _paint(const Color(0xFFDC143C)));
    canvas.drawOval(const Rect.fromLTWH(6, 10, 20, 18), _stroke(const Color(0xFF8B0000)));
    // Stem
    canvas.drawRect(const Rect.fromLTWH(15, 5, 3, 7), _paint(const Color(0xFF8B4513)));
    // Leaf
    final leaf = Path()
      ..moveTo(18, 7)
      ..quadraticBezierTo(24, 3, 25, 8)
      ..quadraticBezierTo(22, 10, 18, 7);
    canvas.drawPath(leaf, _paint(const Color(0xFF228B22)));
    // Highlight
    canvas.drawOval(const Rect.fromLTWH(9, 13, 5, 7), _paint(const Color(0xFFFF6B6B)));
  }

  void _drawFish(Canvas canvas) {
    // Body (ellipse)
    canvas.drawOval(const Rect.fromLTWH(4, 12, 18, 10), _paint(const Color(0xFF4A90D9)));
    canvas.drawOval(const Rect.fromLTWH(4, 12, 18, 10), _stroke(const Color(0xFF2C5F8A)));
    // Tail (triangle)
    final tail = Path()
      ..moveTo(22, 17)
      ..lineTo(30, 10)
      ..lineTo(30, 24)
      ..close();
    canvas.drawPath(tail, _paint(const Color(0xFF3A7BC8)));
    canvas.drawPath(tail, _stroke(const Color(0xFF2C5F8A)));
    // Eye
    canvas.drawCircle(const Offset(9, 16), 2, _paint(const Color(0xFFFFFFFF)));
    canvas.drawCircle(const Offset(9, 16), 1, _paint(const Color(0xFF000000)));
    // Fin
    final fin = Path()
      ..moveTo(13, 12)
      ..lineTo(16, 7)
      ..lineTo(18, 12)
      ..close();
    canvas.drawPath(fin, _paint(const Color(0xFF3A7BC8)));
    // Scales
    canvas.drawArc(const Rect.fromLTWH(12, 14, 4, 6), 0, pi, false, _stroke(const Color(0xFF2C5F8A), width: 0.5));
  }

  void _drawCoin(Canvas canvas) {
    // Outer circle
    canvas.drawCircle(const Offset(16, 16), 11, _paint(const Color(0xFFFFD700)));
    canvas.drawCircle(const Offset(16, 16), 11, _stroke(const Color(0xFFB8860B), width: 2));
    // Inner circle
    canvas.drawCircle(const Offset(16, 16), 7.5, _paint(const Color(0xFFFFC107)));
    canvas.drawCircle(const Offset(16, 16), 7.5, _stroke(const Color(0xFFB8860B)));
    // Symbol
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '¥',
        style: TextStyle(
          color: Color(0xFFB8860B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(16 - textPainter.width / 2, 16 - textPainter.height / 2 - 1));
    // Shine
    canvas.drawCircle(const Offset(12, 12), 2, _paint(const Color(0xFFFFF8DC)));
  }

  // === MATERIALS ===

  void _drawIronBar(Canvas canvas) {
    // Rounded rectangle
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 12, 24, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, _paint(const Color(0xFFC0C0C0)));
    canvas.drawRRect(rrect, _stroke(const Color(0xFF808080)));
    // Highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 13, 20, 3),
        const Radius.circular(1.5),
      ),
      _paint(const Color(0xFFE0E0E0)),
    );
  }

  void _drawGoldBar(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 12, 24, 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, _paint(const Color(0xFFFFD700)));
    canvas.drawRRect(rrect, _stroke(const Color(0xFFB8860B)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 13, 20, 3),
        const Radius.circular(1.5),
      ),
      _paint(const Color(0xFFFFEC8B)),
    );
  }

  void _drawPlank(Canvas canvas) {
    // Wooden plank
    canvas.drawRect(const Rect.fromLTWH(3, 10, 26, 14), _paint(const Color(0xFFC4A484)));
    canvas.drawRect(const Rect.fromLTWH(3, 10, 26, 14), _stroke(const Color(0xFF8B7355)));
    // Wood grain lines
    canvas.drawLine(const Offset(5, 14), const Offset(27, 14), _paint(const Color(0xFFA0826D), strokeWidth: 0.8));
    canvas.drawLine(const Offset(5, 19), const Offset(27, 19), _paint(const Color(0xFFA0826D), strokeWidth: 0.8));
    // Knot
    canvas.drawCircle(const Offset(10, 16.5), 1.5, _paint(const Color(0xFF8B7355)));
  }

  void _drawBrick(Canvas canvas) {
    // Red brick
    canvas.drawRect(const Rect.fromLTWH(3, 10, 26, 14), _paint(const Color(0xFFB22222)));
    canvas.drawRect(const Rect.fromLTWH(3, 10, 26, 14), _stroke(const Color(0xFF8B0000)));
    // Mortar lines
    canvas.drawLine(const Offset(3, 17), const Offset(29, 17), _paint(const Color(0xFFD3D3D3), strokeWidth: 1.2));
    canvas.drawLine(const Offset(16, 10), const Offset(16, 17), _paint(const Color(0xFFD3D3D3), strokeWidth: 1.2));
    canvas.drawLine(const Offset(9, 17), const Offset(9, 24), _paint(const Color(0xFFD3D3D3), strokeWidth: 1.2));
    canvas.drawLine(const Offset(23, 17), const Offset(23, 24), _paint(const Color(0xFFD3D3D3), strokeWidth: 1.2));
  }

  void _drawGlass(Canvas canvas) {
    // Semi-transparent pane
    final paint = Paint()
      ..color = const Color(0x80ADD8E6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(5, 6, 22, 22), paint);
    canvas.drawRect(const Rect.fromLTWH(5, 6, 22, 22), _stroke(const Color(0xFF87CEEB), width: 1.5));
    // Highlight
    canvas.drawLine(const Offset(8, 9), const Offset(8, 25), _paint(const Color(0xFFFFFFFF), strokeWidth: 2));
    canvas.drawLine(const Offset(8, 9), const Offset(20, 9), _paint(const Color(0xFFFFFFFF), strokeWidth: 1.5));
  }

  // === MISC ===

  void _drawTorch(Canvas canvas) {
    // Handle
    canvas.drawRect(const Rect.fromLTWH(14, 14, 4, 16), _paint(const Color(0xFF8B4513)));
    // Wrapping
    canvas.drawRect(const Rect.fromLTWH(12, 12, 8, 4), _paint(const Color(0xFFA0522D)));
    // Flame (outer)
    final flameOuter = Path()
      ..moveTo(10, 12)
      ..quadraticBezierTo(10, 4, 16, 1)
      ..quadraticBezierTo(22, 4, 22, 12)
      ..close();
    canvas.drawPath(flameOuter, _paint(const Color(0xFFFF4500)));
    // Flame (inner)
    final flameInner = Path()
      ..moveTo(13, 11)
      ..quadraticBezierTo(13, 6, 16, 3)
      ..quadraticBezierTo(19, 6, 19, 11)
      ..close();
    canvas.drawPath(flameInner, _paint(const Color(0xFFFFD700)));
  }

  void _drawFlower(Canvas canvas) {
    // Stem
    canvas.drawLine(const Offset(16, 16), const Offset(16, 30), _paint(const Color(0xFF228B22), strokeWidth: 2));
    // Leaf
    final leaf = Path()
      ..moveTo(16, 22)
      ..quadraticBezierTo(10, 20, 8, 24)
      ..quadraticBezierTo(12, 26, 16, 24);
    canvas.drawPath(leaf, _paint(const Color(0xFF32CD32)));
    // Petals (5)
    final petalColors = [
      const Color(0xFFFF69B4),
      const Color(0xFFFFB6C1),
      const Color(0xFFFF69B4),
      const Color(0xFFFFB6C1),
      const Color(0xFFFF69B4),
    ];
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final px = 16 + cos(angle) * 6;
      final py = 12 + sin(angle) * 6;
      canvas.drawCircle(Offset(px, py), 4, _paint(petalColors[i]));
    }
    // Center
    canvas.drawCircle(const Offset(16, 12), 3.5, _paint(const Color(0xFFFFD700)));
  }

  void _drawChest(Canvas canvas) {
    // Body
    canvas.drawRect(const Rect.fromLTWH(4, 12, 24, 16), _paint(const Color(0xFF8B4513)));
    canvas.drawRect(const Rect.fromLTWH(4, 12, 24, 16), _stroke(const Color(0xFF5C3A1A)));
    // Lid
    canvas.drawRect(const Rect.fromLTWH(4, 8, 24, 6), _paint(const Color(0xFFA0522D)));
    canvas.drawRect(const Rect.fromLTWH(4, 8, 24, 6), _stroke(const Color(0xFF5C3A1A)));
    // Metal bands
    canvas.drawRect(const Rect.fromLTWH(4, 13, 24, 2), _paint(const Color(0xFF808080)));
    // Lock
    canvas.drawRect(const Rect.fromLTWH(14, 14, 4, 5), _paint(const Color(0xFFFFD700)));
    canvas.drawCircle(const Offset(16, 16), 1, _paint(const Color(0xFF8B4513)));
    // Wood grain
    canvas.drawLine(const Offset(8, 17), const Offset(8, 26), _paint(const Color(0xFF6B4220), strokeWidth: 0.6));
    canvas.drawLine(const Offset(24, 17), const Offset(24, 26), _paint(const Color(0xFF6B4220), strokeWidth: 0.6));
  }

  void _drawWorkbench(Canvas canvas) {
    // Top
    canvas.drawRect(const Rect.fromLTWH(2, 8, 28, 6), _paint(const Color(0xFFC4A484)));
    canvas.drawRect(const Rect.fromLTWH(2, 8, 28, 6), _stroke(const Color(0xFF8B7355)));
    // Legs
    canvas.drawRect(const Rect.fromLTWH(4, 14, 4, 14), _paint(const Color(0xFF8B4513)));
    canvas.drawRect(const Rect.fromLTWH(24, 14, 4, 14), _paint(const Color(0xFF8B4513)));
    // Tools on top
    canvas.drawRect(const Rect.fromLTWH(8, 4, 2, 6), _paint(const Color(0xFF808080))); // saw blade
    canvas.drawRect(const Rect.fromLTWH(7, 9, 4, 2), _paint(const Color(0xFF8B4513))); // saw handle
    canvas.drawRect(const Rect.fromLTWH(18, 5, 3, 7), _paint(const Color(0xFFA0A0A0))); // chisel
    // Vise
    canvas.drawRect(const Rect.fromLTWH(22, 6, 5, 4), _paint(const Color(0xFF606060)));
  }

  void _drawFurnace(Canvas canvas) {
    // Body
    canvas.drawRect(const Rect.fromLTWH(4, 6, 24, 24), _paint(const Color(0xFF696969)));
    canvas.drawRect(const Rect.fromLTWH(4, 6, 24, 24), _stroke(const Color(0xFF404040)));
    // Top opening
    canvas.drawRect(const Rect.fromLTWH(8, 4, 16, 4), _paint(const Color(0xFF404040)));
    // Fire opening
    canvas.drawRect(const Rect.fromLTWH(9, 14, 14, 10), _paint(const Color(0xFF2C2C2C)));
    // Fire inside
    final fire = Path()
      ..moveTo(11, 23)
      ..quadraticBezierTo(11, 17, 14, 16)
      ..quadraticBezierTo(13, 19, 16, 18)
      ..quadraticBezierTo(15, 21, 18, 20)
      ..quadraticBezierTo(20, 22, 21, 23)
      ..close();
    canvas.drawPath(fire, _paint(const Color(0xFFFF4500)));
    final fireInner = Path()
      ..moveTo(13, 23)
      ..quadraticBezierTo(13, 19, 16, 18)
      ..quadraticBezierTo(18, 20, 19, 23)
      ..close();
    canvas.drawPath(fireInner, _paint(const Color(0xFFFFD700)));
    // Stone bricks pattern
    canvas.drawLine(const Offset(4, 11), const Offset(28, 11), _paint(const Color(0xFF505050), strokeWidth: 0.8));
    canvas.drawLine(const Offset(16, 6), const Offset(16, 11), _paint(const Color(0xFF505050), strokeWidth: 0.8));
  }

  void _drawUnknown(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(4, 4, 24, 24), _paint(const Color(0xFF808080)));
    canvas.drawRect(const Rect.fromLTWH(4, 4, 24, 24), _stroke(const Color(0xFF404040)));
    final tp = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(16 - tp.width / 2, 16 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ItemIconPainter oldDelegate) {
    return oldDelegate.itemId != itemId;
  }
}
