import 'package:flutter/material.dart';

/// The five wellness domains that compose the Wellness Index.
enum WellnessDomain { physical, nutrition, preventive, biometric, mental }

/// Static metadata for each domain: display label, index weight,
/// anti-gaming daily point cap, and the weekly target used to
/// normalize the domain to a 0-100 score.
class DomainInfo {
  final String label;
  final String shortLabel;
  final double weight;
  final int dailyCap;
  final int weeklyTarget;
  final IconData icon;
  final Color color;

  const DomainInfo({
    required this.label,
    required this.shortLabel,
    required this.weight,
    required this.dailyCap,
    required this.weeklyTarget,
    required this.icon,
    required this.color,
  });
}

const Map<WellnessDomain, DomainInfo> domainInfo = {
  WellnessDomain.physical: DomainInfo(
    label: 'Physical Activity',
    shortLabel: 'Physical',
    weight: 0.35,
    dailyCap: 100,
    weeklyTarget: 400,
    icon: Icons.directions_run,
    color: Color(0xFF2C5F2D),
  ),
  WellnessDomain.nutrition: DomainInfo(
    label: 'Nutrition',
    shortLabel: 'Nutrition',
    weight: 0.25,
    dailyCap: 80,
    weeklyTarget: 300,
    icon: Icons.restaurant,
    color: Color(0xFF4A7C3F),
  ),
  WellnessDomain.preventive: DomainInfo(
    label: 'Preventive Care',
    shortLabel: 'Preventive',
    weight: 0.20,
    dailyCap: 100,
    weeklyTarget: 150,
    icon: Icons.health_and_safety,
    color: Color(0xFF1A3C1F),
  ),
  WellnessDomain.biometric: DomainInfo(
    label: 'Biometric Milestones',
    shortLabel: 'Biometrics',
    weight: 0.15,
    dailyCap: 100,
    weeklyTarget: 150,
    icon: Icons.monitor_heart,
    color: Color(0xFF6B4226),
  ),
  WellnessDomain.mental: DomainInfo(
    label: 'Mental Wellness',
    shortLabel: 'Mental',
    weight: 0.05,
    dailyCap: 50,
    weeklyTarget: 120,
    icon: Icons.self_improvement,
    color: Color(0xFFD4A017),
  ),
};

/// A loggable activity type. If [hasQuantity], the log sheet shows a
/// quantity stepper (minutes, servings, etc.); otherwise one tap = one log.
class ActivityType {
  final String id;
  final WellnessDomain domain;
  final String name;
  final String subtitle;
  final int pointsPerUnit;
  final String unitLabel;
  final bool hasQuantity;
  final int defaultQty;
  final int minQty;
  final int maxQty;
  final int step;
  final List<String>? variants; // e.g. workout types, screening types
  final IconData icon;

  const ActivityType({
    required this.id,
    required this.domain,
    required this.name,
    required this.subtitle,
    required this.pointsPerUnit,
    this.unitLabel = '',
    this.hasQuantity = false,
    this.defaultQty = 1,
    this.minQty = 1,
    this.maxQty = 1,
    this.step = 1,
    this.variants,
    required this.icon,
  });
}

/// The full activity catalog, organized by domain.
class ActivityCatalog {
  ActivityCatalog._();

  static const List<ActivityType> all = [
    // ---- Physical Activity (35%) ----
    ActivityType(
      id: 'steps',
      domain: WellnessDomain.physical,
      name: 'Steps',
      subtitle: 'Manual entry, or synced from a wearable',
      pointsPerUnit: 1,
      unitLabel: 'x 1,000 steps',
      hasQuantity: true,
      defaultQty: 6,
      minQty: 1,
      maxQty: 25,
      icon: Icons.directions_walk,
    ),
    ActivityType(
      id: 'workout',
      domain: WellnessDomain.physical,
      name: 'Workout',
      subtitle: 'Any structured exercise session',
      pointsPerUnit: 1,
      unitLabel: 'min',
      hasQuantity: true,
      defaultQty: 30,
      minQty: 5,
      maxQty: 90,
      step: 5,
      variants: ['Walking', 'Running', 'Cycling', 'Strength', 'Swimming', 'Yoga'],
      icon: Icons.fitness_center,
    ),
    ActivityType(
      id: 'active_minutes',
      domain: WellnessDomain.physical,
      name: 'Active Minutes',
      subtitle: 'Yard work, stairs, walking meetings',
      pointsPerUnit: 1,
      unitLabel: 'min',
      hasQuantity: true,
      defaultQty: 20,
      minQty: 5,
      maxQty: 60,
      step: 5,
      icon: Icons.bolt,
    ),
    // ---- Nutrition (25%) ----
    ActivityType(
      id: 'healthy_meal',
      domain: WellnessDomain.nutrition,
      name: 'Healthy Meal',
      subtitle: 'A balanced, whole-food meal',
      pointsPerUnit: 15,
      variants: ['Breakfast', 'Lunch', 'Dinner'],
      icon: Icons.restaurant,
    ),
    ActivityType(
      id: 'fruit_veg',
      domain: WellnessDomain.nutrition,
      name: 'Fruit & Veggie Servings',
      subtitle: '5 points per serving',
      pointsPerUnit: 5,
      unitLabel: 'servings',
      hasQuantity: true,
      defaultQty: 3,
      minQty: 1,
      maxQty: 10,
      icon: Icons.eco,
    ),
    ActivityType(
      id: 'water',
      domain: WellnessDomain.nutrition,
      name: 'Water Intake',
      subtitle: '2 points per glass',
      pointsPerUnit: 2,
      unitLabel: 'glasses',
      hasQuantity: true,
      defaultQty: 4,
      minQty: 1,
      maxQty: 12,
      icon: Icons.water_drop,
    ),
    // ---- Preventive Care (20%) ----
    ActivityType(
      id: 'annual_physical',
      domain: WellnessDomain.preventive,
      name: 'Annual Physical',
      subtitle: 'Completed your yearly checkup',
      pointsPerUnit: 100,
      icon: Icons.medical_services,
    ),
    ActivityType(
      id: 'flu_shot',
      domain: WellnessDomain.preventive,
      name: 'Flu Shot',
      subtitle: 'Seasonal vaccination',
      pointsPerUnit: 75,
      icon: Icons.vaccines,
    ),
    ActivityType(
      id: 'screening',
      domain: WellnessDomain.preventive,
      name: 'Preventive Screening',
      subtitle: 'Completed a recommended screening',
      pointsPerUnit: 60,
      variants: [
        'Cholesterol Panel',
        'Blood Pressure Check',
        'Cancer Screening',
        'Dental Exam',
        'Vision Exam',
      ],
      icon: Icons.content_paste_search,
    ),
    ActivityType(
      id: 'med_adherence',
      domain: WellnessDomain.preventive,
      name: 'Medication Adherence',
      subtitle: 'Took all prescribed meds today',
      pointsPerUnit: 20,
      icon: Icons.medication,
    ),
    // ---- Biometric Milestones (15%) ----
    ActivityType(
      id: 'bmi_milestone',
      domain: WellnessDomain.biometric,
      name: 'BMI Reduction',
      subtitle: 'Verified improvement from baseline',
      pointsPerUnit: 80,
      icon: Icons.trending_down,
    ),
    ActivityType(
      id: 'bp_improvement',
      domain: WellnessDomain.biometric,
      name: 'Blood Pressure Improvement',
      subtitle: 'Verified improvement from baseline',
      pointsPerUnit: 80,
      icon: Icons.favorite,
    ),
    ActivityType(
      id: 'a1c_improvement',
      domain: WellnessDomain.biometric,
      name: 'HbA1c Improvement',
      subtitle: 'Verified improvement from baseline',
      pointsPerUnit: 80,
      icon: Icons.bloodtype,
    ),
    ActivityType(
      id: 'cholesterol_improvement',
      domain: WellnessDomain.biometric,
      name: 'Cholesterol Improvement',
      subtitle: 'Verified improvement from baseline',
      pointsPerUnit: 80,
      icon: Icons.science,
    ),
    // ---- Mental Wellness (5%) ----
    ActivityType(
      id: 'stress_session',
      domain: WellnessDomain.mental,
      name: 'Stress Management Session',
      subtitle: 'Counseling, breathing, or a walk outside',
      pointsPerUnit: 25,
      icon: Icons.self_improvement,
    ),
    ActivityType(
      id: 'sleep_quality',
      domain: WellnessDomain.mental,
      name: 'Sleep Quality',
      subtitle: 'Rate last night, 1-5 stars',
      pointsPerUnit: 8,
      unitLabel: 'stars',
      hasQuantity: true,
      defaultQty: 4,
      minQty: 1,
      maxQty: 5,
      icon: Icons.bedtime,
    ),
    ActivityType(
      id: 'mindfulness',
      domain: WellnessDomain.mental,
      name: 'Mindfulness',
      subtitle: 'Meditation or focused breathing',
      pointsPerUnit: 2,
      unitLabel: 'min',
      hasQuantity: true,
      defaultQty: 10,
      minQty: 5,
      maxQty: 30,
      step: 5,
      icon: Icons.spa,
    ),
  ];

  static List<ActivityType> forDomain(WellnessDomain d) =>
      all.where((t) => t.domain == d).toList();

  static ActivityType? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// A single logged activity, persisted locally.
class ActivityLog {
  final String id;
  final String typeId;
  final WellnessDomain domain;
  final String label;
  final int points;
  final int quantity;
  final DateTime time;

  const ActivityLog({
    required this.id,
    required this.typeId,
    required this.domain,
    required this.label,
    required this.points,
    required this.quantity,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeId': typeId,
        'domain': domain.name,
        'label': label,
        'points': points,
        'quantity': quantity,
        'time': time.toIso8601String(),
      };

  factory ActivityLog.fromJson(Map<String, dynamic> j) => ActivityLog(
        id: j['id'] as String,
        typeId: j['typeId'] as String,
        domain: WellnessDomain.values.byName(j['domain'] as String),
        label: j['label'] as String,
        points: (j['points'] as num).toInt(),
        quantity: (j['quantity'] as num).toInt(),
        time: DateTime.parse(j['time'] as String),
      );
}
