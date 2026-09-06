import 'dart:math';
import 'package:flutter/material.dart';

/// 虚拟摇杆（左下角触控控件）
///
/// 输出归一化方向向量 (dx, dy)，范围 -1 ~ 1。
/// 支持手指拖动，松手自动回中。
class VirtualJoystick extends StatefulWidget {
  /// 方向变化回调
  final void Function(double dx, double dy) onDirectionChanged;

  /// 摇杆底盘直径
  final double size;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 120,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  /// 摇杆旋钮相对中心的偏移
  double _knobX = 0;
  double _knobY = 0;

  /// 是否正在触控
  bool _active = false;

  /// 旋钮最大活动半径
  double get _maxRadius => widget.size * 0.35;

  /// 根据触控位置更新旋钮，并输出归一化方向
  void _updateKnob(Offset localPosition) {
    final center = widget.size / 2;
    var dx = localPosition.dx - center;
    var dy = localPosition.dy - center;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > _maxRadius) {
      dx = dx / dist * _maxRadius;
      dy = dy / dist * _maxRadius;
    }
    setState(() {
      _knobX = dx;
      _knobY = dy;
    });
    widget.onDirectionChanged(dx / _maxRadius, dy / _maxRadius);
  }

  /// 松手回中
  void _reset() {
    setState(() {
      _knobX = 0;
      _knobY = 0;
      _active = false;
    });
    widget.onDirectionChanged(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _active = true;
        _updateKnob(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateKnob(details.localPosition);
      },
      onPanEnd: (_) => _reset(),
      onPanCancel: () => _reset(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: Offset(_knobX, _knobY),
            child: Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              decoration: BoxDecoration(
                color: _active ? Colors.white70 : Colors.white54,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
