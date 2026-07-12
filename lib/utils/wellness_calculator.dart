import 'dart:math' as math;

import '../models/activity.dart';

/// A tree growth stage band on the 0-100 Wellness Index scale.
class StageInfo {
  final String name;
  final int min;
  final int max;
  const StageInfo(this.name, this.min, this.max);
}

/// Implements the Grove Wellness Index:
///
///   Index = (Physical x 0.35) + (Nutrition x 0.25) + (Preventive x 0.20)
///         + (Biometric x 0.15) + (Mental x 0.05)
///
/// Each domain is scored 0-100 by comparing points earned over the current
/// week against that domain's weekly target. "Current week" is a rolling
/// 7-day window (design decision: keeps the score meaningful on Mondays and
/// makes demos deterministic). Points are capped per-day per-domain to
/// prevent gaming.
class WellnessCalculator {
  WellnessCalculator._();

  static const List<StageInfo> stages = [
    StageInfo('Seedling', 0, 20),
    StageInfo('Sapling', 21, 40),
    StageInfo('Young Tree', 41, 60),
    StageInfo('Mature Tree', 61, 80),
    StageInfo('Full Oak', 81, 100),
  ];

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Points earned in [domain] on [day], capped at the domain's daily cap.
  static int dayPoints(
      List<ActivityLog> logs, WellnessDomain domain, DateTime day) {
    var total = 0;
    for (final l in logs) {
      if (l.domain == domain && _sameDay(l.time, day)) total += l.points;
    }
    return math.min(total, domainInfo[domain]!.dailyCap);
  }

  /// Sum of daily-capped points over the rolling 7-day window ending [now].
  static int weekPoints(
      List<ActivityLog> logs, WellnessDomain domain, DateTime now) {
    var total = 0;
    for (var i = 0; i < 7; i++) {
      total += dayPoints(logs, domain, now.subtract(Duration(days: i)));
    }
    return total;
  }

  /// Domain score, 0-100, normalized against the domain's weekly target.
  static double domainScore(
      List<ActivityLog> logs, WellnessDomain domain, DateTime now) {
    final target = domainInfo[domain]!.weeklyTarget;
    return (weekPoints(logs, domain, now) / target * 100)
        .clamp(0.0, 100.0)
        .toDouble();
  }

  /// The composite Wellness Index, 0-100.
  static double wellnessIndex(List<ActivityLog> logs, DateTime now) {
    var index = 0.0;
    for (final d in WellnessDomain.values) {
      index += domainScore(logs, d, now) * domainInfo[d]!.weight;
    }
    return index.clamp(0.0, 100.0).toDouble();
  }

  static int stageIndexFor(double score) {
    final s = score.round();
    for (var i = stages.length - 1; i >= 0; i--) {
      if (s >= stages[i].min) return i;
    }
    return 0;
  }

  static StageInfo stageFor(double score) => stages[stageIndexFor(score)];

  /// The next stage up, or null when the tree is already a Full Oak.
  static StageInfo? nextStage(double score) {
    final i = stageIndexFor(score);
    return i < stages.length - 1 ? stages[i + 1] : null;
  }

  /// Progress (0-1) through the current stage band, for the home progress bar.
  static double progressWithinStage(double score) {
    final i = stageIndexFor(score);
    if (i >= stages.length - 1) {
      final band = 100 - stages[i].min;
      return ((score - stages[i].min) / band).clamp(0.0, 1.0).toDouble();
    }
    final lower = stages[i].min;
    final upper = stages[i + 1].min;
    return ((score - lower) / (upper - lower)).clamp(0.0, 1.0).toDouble();
  }
}
