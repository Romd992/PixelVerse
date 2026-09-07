import 'package:flutter/material.dart';
import 'package:flame/components.dart';

/// A virtual joystick for touch controls.
class VirtualJoystick extends StatefulWidget {
  final void Function(Vector2 direction) onDirectionChanged;
  final VoidCallback onIdle;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    required this.onIdle,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  static const double joystickSize = 120;
  static const double knobSize = 50;
  static const double maxRadius = (joystickSize - knobSize) / 2;

  Offset _knobOffset = Offset.zero;
  bool _isDragging = false;
  int? _activePointerId;

  void _updateKnob(Offset localPosition) {
    final center = Offset(joystickSize / 2, joystickSize / 2);
    final diff = localPosition - center;
    final dist = diff.distance;

    if (dist > maxRadius) {
      final ratio = maxRadius / dist;
      _knobOffset = Offset(diff.dx * ratio, diff.dy * ratio);
    } else {
      _knobOffset = diff;
    }

    // Send normalized direction
    if (dist > 5) {
      final normalized = Vector2(
        _knobOffset.dx / maxRadius,
        _knobOffset.dy / maxRadius,
      );
      widget.onDirectionChanged(normalized);
    }
  }

  void _resetKnob() {
    _knobOffset = Offset.zero;
    _isDragging = false;
    _activePointerId = null;
    widget.onIdle();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (_activePointerId == null) {
          _activePointerId = event.pointer;
          _isDragging = true;
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final local = renderBox.globalToLocal(event.position);
            _updateKnob(local);
          }
          setState(() {});
        }
      },
      onPointerMove: (event) {
        if (event.pointer == _activePointerId && _isDragging) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final local = renderBox.globalToLocal(event.position);
            _updateKnob(local);
          }
          setState(() {});
        }
      },
      onPointerUp: (event) {
        if (event.pointer == _activePointerId) {
          _resetKnob();
          setState(() {});
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _activePointerId) {
          _resetKnob();
          setState(() {});
        }
      },
      child: Container(
        width: joystickSize,
        height: joystickSize,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 2),
        ),
        child: Stack(
          children: [
            // Direction indicators
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(Icons.keyboard_arrow_up,
                    color: Colors.white30, size: 16),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(Icons.keyboard_arrow_down,
                    color: Colors.white30, size: 16),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 8,
              child: Center(
                child: Icon(Icons.keyboard_arrow_left,
                    color: Colors.white30, size: 16),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 8,
              child: Center(
                child: Icon(Icons.keyboard_arrow_right,
                    color: Colors.white30, size: 16),
              ),
            ),
            // Knob
            Center(
              child: Transform.translate(
                offset: _knobOffset,
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
