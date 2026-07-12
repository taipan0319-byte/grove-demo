import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// One organic canopy "blob". Generated deterministically from a seed so
/// the tree never jitters between repaints or animation frames.
class _Lobe {
  final double angle;
  final double dist;
  final double radius;
  final int colorIdx;
  const _Lobe(this.angle, this.dist, this.radius, this.colorIdx);
}

/// Draws a single oak tree for any growth value in [0, 1].
///
/// growth 0.0-0.2  -> Seedling: thin sprout with a pair of leaves
/// growth 0.2-0.4  -> Sapling: slim trunk, small canopy forming
/// growth 0.4-0.6  -> Young Tree: first branches, fuller canopy
/// growth 0.6-0.8  -> Mature Tree: thick flared trunk, layered lobes
/// growth 0.8-1.0  -> Full Oak: broad crown with gold accent leaves
///
/// All parameters interpolate continuously so stage transitions animate
/// smoothly rather than swapping sprites.
class OakTreeRenderer {
  OakTreeRenderer._();

  static const _canopyColors = [
    GroveColors.canopyDark,
    GroveColors.canopyMid,
    GroveColors.canopyLight,
    GroveColors.canopyPale,
  ];

  static void paint(Canvas canvas, Size size, double growth, int seed,
      {double sway = 0}) {
    final g = growth.clamp(0.02, 1.0).toDouble();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final groundY = h * 0.95;

    // ---- cast ground shadow ----
    final shadowW = _lerp(w * 0.12, w * 0.62, g);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * 0.02, groundY),
        width: shadowW,
        height: math.max(6.0, shadowW * 0.16),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.10),
    );

    // ---- trunk: bezier sides, widens at the base with root flare ----
    final trunkRnd = math.Random(seed);
    final trunkH = h * _lerp(0.10, 0.50, g);
    final trunkW = math.max(1.5, w * _lerp(0.010, 0.072, g));
    final lean =
        (trunkRnd.nextDouble() - 0.5) * trunkW * 1.2 + sway * w * 0.008;
    final topY = groundY - trunkH;

    final trunk = Path()
      ..moveTo(cx - trunkW * 2.3, groundY) // left root flare
      ..quadraticBezierTo(cx - trunkW * 0.95, groundY - trunkH * 0.05,
          cx - trunkW * 0.62, groundY - trunkH * 0.22)
      ..quadraticBezierTo(cx - trunkW * 0.55 + lean * 0.4,
          groundY - trunkH * 0.60, cx - trunkW * 0.30 + lean, topY)
      ..lineTo(cx + trunkW * 0.30 + lean, topY)
      ..quadraticBezierTo(cx + trunkW * 0.55 + lean * 0.4,
          groundY - trunkH * 0.60, cx + trunkW * 0.62, groundY - trunkH * 0.22)
      ..quadraticBezierTo(cx + trunkW * 0.95, groundY - trunkH * 0.05,
          cx + trunkW * 2.3, groundY) // right root flare
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [GroveColors.barkDark, GroveColors.bark],
        ).createShader(
            Rect.fromLTRB(cx - trunkW * 2.3, topY, cx + trunkW * 2.3, groundY)),
    );

    // ---- branches: emerge one at a time as the tree matures ----
    // Branch shapes come from their own Random stream so adding a branch
    // never reshuffles the canopy.
    final branchRnd = math.Random(seed + 101);
    final branchSpecs = List.generate(
        5,
        (_) => [
              branchRnd.nextDouble(),
              branchRnd.nextDouble(),
              branchRnd.nextDouble()
            ]);
    final branchCount = (((g - 0.30) / 0.70) * 6).clamp(0.0, 5.0).floor();
    final branchPaint = Paint()
      ..color = GroveColors.bark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < branchCount; i++) {
      final spec = branchSpecs[i];
      final side = i.isEven ? 1.0 : -1.0;
      final t = 0.55 + spec[0] * 0.32; // attach height along trunk
      final sx = cx + lean * t;
      final sy = groundY - trunkH * t;
      final len = trunkH * (0.24 + spec[1] * 0.22);
      final ex = sx + side * len;
      final ey = sy - len * (0.45 + spec[2] * 0.40);
      branchPaint.strokeWidth = math.max(1.2, trunkW * (0.40 - i * 0.05));
      canvas.drawPath(
        Path()
          ..moveTo(sx, sy)
          ..quadraticBezierTo(sx + side * len * 0.55, sy - len * 0.12, ex, ey),
        branchPaint,
      );
    }

    // ---- canopy: overlapping organic lobes in layered greens ----
    final lobeRnd = math.Random(seed + 202);
    final lobes = List.generate(
        14,
        (_) => _Lobe(
              lobeRnd.nextDouble() * math.pi * 2,
              lobeRnd.nextDouble() * 0.85,
              0.36 + lobeRnd.nextDouble() * 0.42,
              lobeRnd.nextInt(4),
            ));
    final canopyIn = ((g - 0.08) / 0.35).clamp(0.0, 1.0).toDouble();
    if (canopyIn > 0) {
      final scale = Curves.easeOut.transform(canopyIn);
      final canopyR = w * _lerp(0.06, 0.34, g) * scale;
      final canopyCx = cx + lean + sway * w * 0.012;
      final canopyCy = topY - canopyR * 0.30;

      // Solid base circle keeps the silhouette full behind the lobes.
      canvas.drawCircle(Offset(canopyCx, canopyCy), canopyR,
          Paint()..color = GroveColors.canopyMid);

      // More lobes become visible as the tree grows; darker lobes render
      // first so lighter greens read as sunlit outer foliage.
      final visible = (5 + g * 9).round().clamp(0, 14).toInt();
      final drawList = lobes.take(visible).toList()
        ..sort((a, b) => a.colorIdx.compareTo(b.colorIdx));
      for (final l in drawList) {
        final off = Offset(
          canopyCx + math.cos(l.angle) * l.dist * canopyR,
          canopyCy + math.sin(l.angle) * l.dist * canopyR * 0.72,
        );
        canvas.drawCircle(
            off, canopyR * l.radius, Paint()..color = _canopyColors[l.colorIdx]);
      }

      // Sunlit highlight, upper-left.
      canvas.drawCircle(
        Offset(canopyCx - canopyR * 0.38, canopyCy - canopyR * 0.42),
        canopyR * 0.30,
        Paint()..color = GroveColors.canopyPale.withValues(alpha: 0.85),
      );

      // Gold accent leaves once the tree reaches Full Oak.
      if (g > 0.82) {
        final goldT = ((g - 0.82) / 0.18).clamp(0.0, 1.0).toDouble();
        final goldRnd = math.Random(seed + 303);
        final goldPaint =
            Paint()..color = GroveColors.gold.withValues(alpha: 0.9 * goldT);
        for (var i = 0; i < 7; i++) {
          final ang = goldRnd.nextDouble() * math.pi * 2;
          final dist = 0.55 + goldRnd.nextDouble() * 0.5;
          canvas.drawCircle(
            Offset(
              canopyCx + math.cos(ang) * dist * canopyR,
              canopyCy + math.sin(ang) * dist * canopyR * 0.72,
            ),
            canopyR * (0.035 + goldRnd.nextDouble() * 0.03),
            goldPaint,
          );
        }
      }
    }

    // ---- seedling leaves: a young sprout's first pair, fading out as the
    // canopy takes over ----
    if (g < 0.30) {
      final opacity = ((0.30 - g) / 0.30).clamp(0.0, 1.0).toDouble();
      final leafPaint =
          Paint()..color = GroveColors.canopyLight.withValues(alpha: opacity);
      final leafLen = math.max(6.0, w * 0.055) * (1.15 - g);
      for (final side in const [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(cx + lean, topY + trunkH * 0.05);
        canvas.rotate(side * 0.8);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(0, -leafLen * 0.6),
              width: leafLen * 0.55,
              height: leafLen * 1.3),
          leafPaint,
        );
        canvas.restore();
      }
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class OakTreePainter extends CustomPainter {
  final double growth;
  final int seed;
  final double sway;
  const OakTreePainter(
      {required this.growth, required this.seed, this.sway = 0});

  @override
  void paint(Canvas canvas, Size size) =>
      OakTreeRenderer.paint(canvas, size, growth, seed, sway: sway);

  @override
  bool shouldRepaint(OakTreePainter oldDelegate) =>
      oldDelegate.growth != growth ||
      oldDelegate.seed != seed ||
      oldDelegate.sway != sway;
}

/// Animated oak tree widget.
///
/// Growth changes tween smoothly (AnimationController under the hood via
/// TweenAnimationBuilder). Pass [animateFrom] to replay growth from an
/// earlier value — used for stage-crossing celebrations. [sway] adds a
/// gentle breeze so the hero tree feels alive.
class OakTreeView extends StatefulWidget {
  final double growth;
  final int seed;
  final double? animateFrom;
  final Duration duration;
  final bool sway;

  const OakTreeView({
    super.key,
    required this.growth,
    this.seed = 7,
    this.animateFrom,
    this.duration = const Duration(milliseconds: 1400),
    this.sway = false,
  });

  @override
  State<OakTreeView> createState() => _OakTreeViewState();
}

class _OakTreeViewState extends State<OakTreeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swayCtrl;
  late final Animation<double> _swayAnim;

  @override
  void initState() {
    super.initState();
    _swayCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _swayAnim = CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOut);
    if (widget.sway) _swayCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(
            begin: widget.animateFrom ?? widget.growth, end: widget.growth),
        duration: widget.duration,
        curve: Curves.easeInOutCubic,
        builder: (context, g, _) => AnimatedBuilder(
          animation: _swayCtrl,
          builder: (context, _) => CustomPaint(
            painter: OakTreePainter(
              growth: g,
              seed: widget.seed,
              sway: widget.sway ? (_swayAnim.value * 2 - 1) : 0,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// A department-sized cluster of trees for the Employer Forest view.
/// Fuller departments show more trees, and every tree's fullness tracks
/// the department's aggregate wellness score.
class TreeCluster extends StatelessWidget {
  final double growth;
  final int seed;
  const TreeCluster({super.key, required this.growth, this.seed = 1});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ClusterPainter(growth, seed),
        size: Size.infinite,
      ),
    );
  }
}

class _ClusterPainter extends CustomPainter {
  final double growth;
  final int seed;
  const _ClusterPainter(this.growth, this.seed);

  // [xFraction, scale] slots, ordered small-to-large so the big center
  // tree draws in front. Higher scores unlock the later (larger) slots.
  static const _slots = [
    [0.64, 0.42],
    [0.38, 0.46],
    [0.24, 0.60],
    [0.76, 0.66],
    [0.50, 1.00],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final count = (2 + growth * 3.2).floor().clamp(2, 5).toInt();
    final slots = _slots.sublist(_slots.length - count);
    var i = 0;
    for (final s in slots) {
      final dx = s[0];
      final scale = s[1];
      canvas.save();
      // Bottom-align each scaled tree on the shared ground line.
      canvas.translate(
          size.width * dx - size.width * scale / 2, size.height * (1 - scale));
      canvas.scale(scale);
      OakTreeRenderer.paint(
        canvas,
        size,
        (growth * (0.85 + 0.15 * scale)).clamp(0.05, 1.0).toDouble(),
        seed + i * 37,
      );
      canvas.restore();
      i++;
    }
  }

  @override
  bool shouldRepaint(_ClusterPainter oldDelegate) =>
      oldDelegate.growth != growth || oldDelegate.seed != seed;
}
