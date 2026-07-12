import 'package:flutter/material.dart';

/// Abstract watermark evoking Rockford's "Symbol" sculpture — sweeping
/// curved forms in muted red at very low opacity. Pure Bezier curves,
/// no photography. Used as a background element on the Employer Forest
/// and City Health Dashboard screens.
class SymbolSculpturePainter extends CustomPainter {
  const SymbolSculpturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFFB0352C).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Large sweeping arc, upper right
    paint.strokeWidth = w * 0.055;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, h * 0.02)
        ..cubicTo(w * 0.95, h * 0.10, w * 1.02, h * 0.32, w * 0.80, h * 0.46),
      paint,
    );

    // Counter-curve crossing beneath it
    paint.strokeWidth = w * 0.04;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.98, h * 0.06)
        ..cubicTo(w * 0.72, h * 0.16, w * 0.66, h * 0.34, w * 0.92, h * 0.52),
      paint,
    );

    // Low horizontal sweep, lower left
    paint.strokeWidth = w * 0.05;
    canvas.drawPath(
      Path()
        ..moveTo(-w * 0.05, h * 0.78)
        ..cubicTo(w * 0.25, h * 0.64, w * 0.42, h * 0.92, w * 0.18, h * 1.02),
      paint,
    );

    // Small accent ring, mid left
    paint.strokeWidth = w * 0.022;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.12, h * 0.42), radius: w * 0.09),
      0.6,
      4.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(SymbolSculpturePainter oldDelegate) => false;
}

/// Convenience full-bleed background wrapper.
class SymbolSculptureBackground extends StatelessWidget {
  const SymbolSculptureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: SymbolSculpturePainter()),
      ),
    );
  }
}
