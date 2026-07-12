import 'package:flutter/material.dart';

import 'activity.dart';

/// The City of Rockford's existing "Path to Wellness" employee program:
/// earn 6 points in a plan year to receive a health insurance premium
/// discount. Grove tracks these points automatically alongside the
/// Wellness Index.
enum PtwGroup { a, b, c }

class PtwActivity {
  final String id; // used as the ActivityLog.typeId ('ptw_*')
  final String name;
  final PtwGroup group;

  /// Path to Wellness points (3 / 2 / 1 by group).
  final int points;

  /// Grove Wellness Index credit granted by the same tap.
  final int grovePoints;
  final WellnessDomain groveDomain;

  /// How many times this activity can be credited per plan year
  /// (1 for most; Health Club Participation allows up to 3 months).
  final int maxTimes;
  final IconData icon;

  const PtwActivity({
    required this.id,
    required this.name,
    required this.group,
    required this.points,
    required this.grovePoints,
    required this.groveDomain,
    this.maxTimes = 1,
    required this.icon,
  });
}

class PtwCatalog {
  PtwCatalog._();

  /// Points needed for the premium discount.
  static const int discountThreshold = 6;

  /// Estimated annual premium savings (demo figure).
  static const int discountValue = 500;

  static const List<PtwActivity> all = [
    // ---- Group A: 3 points each ----
    PtwActivity(
        id: 'ptw_wellness_fair',
        name: 'Wellness Fair Attendance',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 40,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.festival),
    PtwActivity(
        id: 'ptw_hra',
        name: 'Health Risk Assessment',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 60,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.assignment_turned_in),
    PtwActivity(
        id: 'ptw_glucose',
        name: 'Glucose Screening',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 60,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.bloodtype),
    PtwActivity(
        id: 'ptw_cholesterol',
        name: 'Cholesterol Screening',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 60,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.science),
    PtwActivity(
        id: 'ptw_bp',
        name: 'Blood Pressure Screening',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 60,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.favorite),
    PtwActivity(
        id: 'ptw_diabetes_ed',
        name: 'Diabetes Education Program',
        group: PtwGroup.a,
        points: 3,
        grovePoints: 50,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.school),
    // ---- Group B: 2 points each ----
    PtwActivity(
        id: 'ptw_smoking',
        name: 'Smoking Cessation Program',
        group: PtwGroup.b,
        points: 2,
        grovePoints: 50,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.smoke_free),
    PtwActivity(
        id: 'ptw_flu',
        name: 'Flu Shot',
        group: PtwGroup.b,
        points: 2,
        grovePoints: 75,
        groveDomain: WellnessDomain.preventive,
        icon: Icons.vaccines),
    PtwActivity(
        id: 'ptw_class',
        name: 'Wellness / Educational Class',
        group: PtwGroup.b,
        points: 2,
        grovePoints: 25,
        groveDomain: WellnessDomain.mental,
        icon: Icons.menu_book),
    // ---- Group C: 1 point each ----
    PtwActivity(
        id: 'ptw_fitness_event',
        name: 'City Endorsed Fitness Event / Walk / Run',
        group: PtwGroup.c,
        points: 1,
        grovePoints: 50,
        groveDomain: WellnessDomain.physical,
        icon: Icons.directions_run),
    PtwActivity(
        id: 'ptw_health_club',
        name: 'Health Club Participation (per month, up to 3)',
        group: PtwGroup.c,
        points: 1,
        grovePoints: 30,
        groveDomain: WellnessDomain.physical,
        maxTimes: 3,
        icon: Icons.fitness_center),
    PtwActivity(
        id: 'ptw_other',
        name: 'Other Approved Activity',
        group: PtwGroup.c,
        points: 1,
        grovePoints: 20,
        groveDomain: WellnessDomain.mental,
        icon: Icons.add_task),
  ];

  static List<PtwActivity> forGroup(PtwGroup g) =>
      all.where((a) => a.group == g).toList();

  static String groupLabel(PtwGroup g) {
    switch (g) {
      case PtwGroup.a:
        return 'Group A — 3 points each';
      case PtwGroup.b:
        return 'Group B — 2 points each';
      case PtwGroup.c:
        return 'Group C — 1 point each';
    }
  }
}
