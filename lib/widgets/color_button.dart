import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Color grid button for the Simon Says sequence.
///
/// [isHighlighted]: during sequence playback — shows gradient + SpinKitPulse.
/// [showCorrectFlash]: after correct user tap — shows gold glow feedback.
/// Both can be false (idle) or only one true at a time.
class ColorButton extends StatefulWidget {
  final Color color;
  final bool isHighlighted;
  final bool showCorrectFlash;
  final double size;
  final VoidCallback onTap;

  const ColorButton({
    required this.color,
    required this.isHighlighted,
    this.showCorrectFlash = false,
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
    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_isPressed),
        tween: Tween(
          begin: _isPressed ? 1.0 : 0.93,
          end: _isPressed ? 0.93 : 1.0,
        ),
        duration: Duration(milliseconds: _isPressed ? 80 : 180),
        curve: _isPressed ? Curves.easeIn : Curves.elasticOut,
        builder: (context, scale, child) {
          final baseColor = widget.isHighlighted
              ? widget.color.withValues(alpha: 0.7)
              : widget.color;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor,
                    Color.lerp(baseColor, Colors.black, 0.15)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: baseColor.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: _isPressed ? 0.10 : 0.25),
                    blurRadius: _isPressed ? 4 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  if (widget.isHighlighted)
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.6),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  if (widget.showCorrectFlash)
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                ],
              ),
              child: widget.isHighlighted
                  ? SpinKitPulse(color: widget.color, size: widget.size)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
