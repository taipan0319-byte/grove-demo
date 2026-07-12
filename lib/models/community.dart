import 'package:flutter/material.dart';

/// A department colleague shown in the Grove view (first name only —
/// individual health data stays anonymized at the community level).
class GroveMember {
  final String firstName;
  final double score;

  /// Path to Wellness points earned this plan year.
  final int ptwPoints;
  const GroveMember(this.firstName, this.score, [this.ptwPoints = 0]);
}

/// A department within an employer, for grove/forest aggregation.
class DepartmentInfo {
  final String name;
  final String shortName;
  final int members;
  final double score;
  const DepartmentInfo({
    required this.name,
    required this.shortName,
    required this.members,
    required this.score,
  });
}

/// An employer in the regional civic ecosystem.
class EmployerInfo {
  final String name;
  final int employees;
  final double score;
  const EmployerInfo({
    required this.name,
    required this.employees,
    required this.score,
  });
}

/// A marketplace incentive offer from a local merchant.
class Offer {
  final String id;
  final String merchant;
  final String description;
  final String category;
  final int cost;
  final IconData icon;
  const Offer({
    required this.id,
    required this.merchant,
    required this.description,
    required this.category,
    required this.cost,
    required this.icon,
  });
}
