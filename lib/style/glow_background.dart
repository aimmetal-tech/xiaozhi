import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: const [
            _GlowBlob(
              alignment: Alignment(-0.8, -0.8),
              size: 250,
              color: Color(0xFF5B9BFF), // 蓝色光晕
            ),
            _GlowBlob(
              alignment: Alignment(0.9, -0.3),
              size: 220,
              color: Color(0xFFFF7AD1), // 粉色光晕
            ),
            _GlowBlob(
              alignment: Alignment(-0.2, 0.9),
              size: 280,
              color: Color(0xFF7CF9B3), // 绿色光晕
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;

  const _GlowBlob({
    required this.alignment,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.55),
                color.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
