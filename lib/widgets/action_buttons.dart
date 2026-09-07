import 'package:flutter/material.dart';
import 'pixel_ui.dart';

/// Action buttons: attack/gather and interact, with press states.
class ActionButtons extends StatefulWidget {
  final VoidCallback onAction;
  final VoidCallback onInteract;
  final String actionLabel;
  final String interactLabel;

  const ActionButtons({
    super.key,
    required this.onAction,
    required this.onInteract,
    this.actionLabel = 'Action',
    this.interactLabel = 'Interact',
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _actionPressed = false;
  bool _interactPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          icon: Icons.handshake,
          label: widget.interactLabel,
          color: Colors.blue,
          size: 56,
          pressed: _interactPressed,
          onTap: widget.onInteract,
          onPressedChange: (v) => setState(() => _interactPressed = v),
        ),
        const SizedBox(width: 16),
        _buildCircleButton(
          icon: Icons.gavel,
          label: widget.actionLabel,
          color: Colors.red,
          size: 64,
          pressed: _actionPressed,
          onTap: widget.onAction,
          onPressedChange: (v) => setState(() => _actionPressed = v),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required void Function(bool) onPressedChange,
    required bool pressed,
    double size = 56,
  }) {
    return Listener(
      onPointerDown: (_) {
        onPressedChange(true);
        onTap();
      },
      onPointerUp: (_) => onPressedChange(false),
      onPointerCancel: (_) => onPressedChange(false),
      child: AnimatedScale(
        scale: pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: pressed
                ? color.withOpacity(0.9)
                : color.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: pressed ? Colors.white : Colors.white54,
              width: pressed ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: pressed ? 2 : 6,
                offset: Offset(0, pressed ? 1 : 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: size * 0.38),
              Text(
                label,
                style: PixelUi.outlinedText(
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
