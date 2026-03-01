import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vibration/vibration.dart';

class ColorButton extends StatefulWidget {
  final Color color;
  final bool isHighlighted;
  final double size;
  final VoidCallback onTap;

  const ColorButton({
    required this.color,
    required this.isHighlighted,
    required this.size,
    required this.onTap,
    super.key,
  });

  @override
  State<ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  bool _isPressed = false;

  Future<void> _handleTap() async {
    setState(() => _isPressed = true);

    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 40, 20, 40]);
    } else if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 40);
    }

    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
        transform: _isPressed
            ? (Matrix4.identity()..scaleByDouble(0.93, 0.93, 1.0, 1.0))
            : Matrix4.identity(),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isHighlighted
              ? widget.color.withAlpha((0.5 * 255).toInt())
              : widget.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                  (_isPressed ? 0.10 : 0.25) * 255 ~/ 1),
              blurRadius: _isPressed ? 4 : 12,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: widget.isHighlighted
            ? SpinKitPulse(color: widget.color, size: widget.size)
            : null,
      ),
    );
  }
}
