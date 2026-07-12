import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/grove_card.dart';
import '../widgets/symbol_sculpture.dart';

/// SCREEN — CITY OF ROCKFORD HEALTH DASHBOARD (V2.0).
/// Aggregate city-wide wellness for the Mayor / HR director view.
/// City-wide figures are mock demo data; department bars are live.
class CityDashboardScreen extends StatelessWidget {
  const CityDashboardScreen({super.key});

  // Mock city-wide demo figures
  static const _enrolled = 847;
  static const _totalEmployees = 2200;
  static const _cityIndex = 52;
  static const _discountPct = 34;
  static const _claimsSavings = 127000;
  static const _trend = [38.0, 41.0, 44.0, 46.0, 49.0, 52.0];
  static const _trendMonths = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
  static const _groveEngagement = 41;
  static const _industryBenchmark = 12;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final departments = state.departmentStandings;

    return Stack(
      children: [
        const SymbolSculptureBackground(),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- City of Rockford header ----
              Center(
                child: Image.asset('assets/images/cor_logo.jpg', height: 64),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text('Rockford Health Dashboard',
                    style: groveSerif(size: 24), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 2),
              const Center(
                child: Text(
                  'City-wide employee wellness · powered by Grove',
                  style: TextStyle(color: GroveColors.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 18),

              // ---- headline stats ----
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '$_enrolled',
                      label: 'employees participating\nof $_totalEmployees eligible',
                      icon: Icons.groups,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '$_cityIndex',
                      label: 'city-wide\nWellness Index',
                      icon: Icons.trending_up,
                      trailing: 'trending up',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: _StatCard(
                      value: '$_discountPct%',
                      label: 'earned Path to Wellness\npremium discount',
                      icon: Icons.savings,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '\$${(_claimsSavings / 1000).round()}K',
                      label: 'est. annual claims savings\nat current engagement',
                      icon: Icons.paid,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ---- 6-month wellness trend ----
              const SectionTitle('6-Month Wellness Trend'),
              GroveCard(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TrendLinePainter(values: _trend),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _trendMonths
                          .map((m) => Expanded(
                                child: Text(m,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: GroveColors.textMuted)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Wellness Index up 14 points since launch (38 → 52)',
                      style: TextStyle(
                          fontSize: 11,
                          color: GroveColors.green,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ---- department comparison (live data) ----
              const SectionTitle('Department Comparison'),
              GroveCard(
                child: SizedBox(
                  height: 170,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final d in departments)
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${d.score.round()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: GroveColors.forest)),
                                const SizedBox(height: 4),
                                Container(
                                  height: 110 * (d.score / 100).clamp(0.05, 1.0),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        GroveColors.forest,
                                        GroveColors.canopyLight,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(d.shortName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: GroveColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ---- Rockford vs national benchmark ----
              const SectionTitle('Rockford vs National Average'),
              const GroveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BenchmarkBar(
                        label: 'Rockford — Grove engagement',
                        pct: _groveEngagement,
                        color: GroveColors.green),
                    SizedBox(height: 12),
                    _BenchmarkBar(
                        label: 'Industry benchmark',
                        pct: _industryBenchmark,
                        color: GroveColors.textMuted),
                    SizedBox(height: 10),
                    Text(
                      'Grove engagement runs 3.4x the wellness-program industry average.',
                      style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: GroveColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final String? trailing;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return GroveCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: GroveColors.gold, size: 20),
              const Spacer(),
              if (trailing != null)
                Text(trailing!,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: GroveColors.green)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: groveSerif(size: 28, height: 1.0)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.25,
                  color: GroveColors.textMuted)),
        ],
      ),
    );
  }
}

/// Minimal line chart: gold data line with dots over a soft green fill.
class _TrendLinePainter extends CustomPainter {
  final List<double> values;
  const _TrendLinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const minV = 30.0;
    const maxV = 60.0;
    final dx = size.width / (values.length - 1);
    Offset pt(int i) => Offset(
          dx * i,
          size.height * (1 - (values[i] - minV) / (maxV - minV)),
        );

    // Soft fill under the line
    final fill = Path()..moveTo(0, size.height);
    for (var i = 0; i < values.length; i++) {
      fill.lineTo(pt(i).dx, pt(i).dy);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
        fill, Paint()..color = GroveColors.greenSoft.withValues(alpha: 0.6));

    // Gridline at start value for context
    final grid = Paint()
      ..color = GroveColors.greenSoft
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, pt(0).dy), Offset(size.width, pt(0).dy), grid);

    // Data line
    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = GroveColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pt(i), 4, Paint()..color = GroveColors.forest);
      canvas.drawCircle(pt(i), 2, Paint()..color = GroveColors.gold);
    }
  }

  @override
  bool shouldRepaint(_TrendLinePainter oldDelegate) =>
      oldDelegate.values != values;
}

class _BenchmarkBar extends StatelessWidget {
  final String label;
  final int pct;
  final Color color;
  const _BenchmarkBar(
      {required this.label, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GroveColors.forest)),
            ),
            Text('$pct%',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 10,
            backgroundColor: GroveColors.greenSoft,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
