import 'package:flutter/material.dart';

/// Shared pixel-art style UI helpers.
class PixelUi {
  /// Standard pixel border color.
  static const Color borderColor = Color(0xFF3E2723);
  static const Color borderLight = Color(0xFF8D6E63);
  static const Color bgDark = Color(0xFF2C1810);
  static const Color bgPanel = Color(0xFF3E2723);

  /// BoxDecoration with pixel-style border.
  static BoxDecoration panelDecoration({
    Color? bgColor,
    Color? border,
    double radius = 8,
    double borderWidth = 3,
  }) {
    return BoxDecoration(
      color: bgColor ?? bgPanel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border ?? borderLight,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// TextStyle with black outline for readability on any background.
  static TextStyle outlinedText({
    double fontSize = 14,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    Color outlineColor = Colors.black,
    double outlineWidth = 2,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      shadows: [
        Shadow(
          color: outlineColor,
          offset: Offset(-outlineWidth, 0),
          blurRadius: 0,
        ),
        Shadow(
          color: outlineColor,
          offset: Offset(outlineWidth, 0),
          blurRadius: 0,
        ),
        Shadow(
          color: outlineColor,
          offset: Offset(0, -outlineWidth),
          blurRadius: 0,
        ),
        Shadow(
          color: outlineColor,
          offset: Offset(0, outlineWidth),
          blurRadius: 0,
        ),
        Shadow(
          color: outlineColor.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 1,
        ),
      ],
    );
  }

  /// A pixel-style button with press state.
  static Widget pixelButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color color = Colors.brown,
    double width = 200,
    double height = 50,
  }) {
    return _PixelButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      color: color,
      width: width,
      height: height,
    );
  }
}

class _PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;
  final double width;
  final double height;

  const _PixelButton({
    required this.label,
    required this.onPressed,
    this.icon,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  State<_PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<_PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 50),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _pressed
                ? widget.color.withOpacity(0.8)
                : widget.color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: _pressed ? 2 : 6,
                offset: Offset(0, _pressed ? 1 : 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: PixelUi.outlinedText(
                  fontSize: 16,
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
