import 'package:flutter/material.dart';

/// Action buttons: attack/gather and interact.
class ActionButtons extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Interact button (left)
        _buildCircleButton(
          icon: Icons.handshake,
          label: interactLabel,
          color: Colors.blue,
          onTap: onInteract,
        ),
        const SizedBox(width: 16),
        // Action/attack button (right, larger)
        _buildCircleButton(
          icon: Icons.gavel,
          label: actionLabel,
          color: Colors.red,
          size: 64,
          onTap: onAction,
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return Listener(
      onPointerDown: (_) => onTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size * 0.4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
