import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/community.dart';

/// Mock community data for the prototype. Scores are fixed (rather than
/// re-randomized each launch) so demos are repeatable; they were chosen to
/// spread colleagues across all five tree growth stages.
class MockData {
  MockData._();

  /// Alex's four Public Works colleagues (first names only — anonymized).
  /// Path to Wellness completion varies for the demo: one fully complete
  /// (6+ pts), two in progress (2-4 pts), one not started.
  static const List<GroveMember> colleagues = [
    GroveMember('Maria', 72, 7),
    GroveMember('DeShawn', 58, 3),
    GroveMember('Priya', 44, 2),
    GroveMember('Tom', 27, 0),
  ];

  /// The other City of Rockford departments competing with Public Works.
  static const List<DepartmentInfo> otherDepartments = [
    DepartmentInfo(
        name: 'Police Department',
        shortName: 'Police',
        members: 41,
        score: 63.4),
    DepartmentInfo(
        name: 'Fire Department', shortName: 'Fire', members: 28, score: 57.1),
    DepartmentInfo(
        name: 'Administration', shortName: 'Admin', members: 19, score: 44.8),
  ];

  /// Other regional employers in the civic ecosystem.
  static const List<EmployerInfo> otherEmployers = [
    EmployerInfo(name: 'Mercyhealth Rockford', employees: 3400, score: 66.8),
    EmployerInfo(name: 'Rockford Public Schools', employees: 2100, score: 61.2),
  ];

  /// Rockford-area incentive marketplace offers.
  static const List<Offer> offers = [
    Offer(
      id: 'stockholm_inn',
      merchant: 'Stockholm Inn',
      description: 'Free breakfast entree (up to \$12)',
      category: 'Restaurant',
      cost: 400,
      icon: Icons.restaurant,
    ),
    Offer(
      id: 'rockford_roasting',
      merchant: 'Rockford Roasting Co.',
      description: '\$5 coffee credit',
      category: 'Cafe',
      cost: 250,
      icon: Icons.local_cafe,
    ),
    Offer(
      id: 'forest_city_fitness',
      merchant: 'Forest City Fitness',
      description: 'One month gym membership',
      category: 'Fitness',
      cost: 800,
      icon: Icons.fitness_center,
    ),
    Offer(
      id: 'rock_river_grocery',
      merchant: 'Rock River Grocery',
      description: '\$10 fresh produce credit',
      category: 'Grocery',
      cost: 350,
      icon: Icons.shopping_basket,
    ),
    Offer(
      id: 'anderson_gardens',
      merchant: 'Anderson Japanese Gardens',
      description: 'Two admission passes',
      category: 'Recreation',
      cost: 300,
      icon: Icons.park,
    ),
    Offer(
      id: 'sinnissippi_cycle',
      merchant: 'Sinnissippi Cycle',
      description: '15% off a bike tune-up',
      category: 'Fitness',
      cost: 200,
      icon: Icons.pedal_bike,
    ),
    Offer(
      id: 'state_street_smoothies',
      merchant: 'State Street Smoothies',
      description: 'Free 16oz smoothie',
      category: 'Cafe',
      cost: 150,
      icon: Icons.local_drink,
    ),
    Offer(
      id: 'city_market',
      merchant: 'Rockford City Market',
      description: '\$5 farmers market voucher',
      category: 'Grocery',
      cost: 150,
      icon: Icons.storefront,
    ),
  ];

  /// Seeds three days of realistic activity history at onboarding so the
  /// grove feels alive and the demo tree starts as a mid-Sapling (~28).
  /// A flu shot plus one workout logged live will visibly cross the tree
  /// into Young Tree — tuned for the investor/mayor demo.
  static List<ActivityLog> buildSeedLogs(DateTime now) {
    ActivityLog seed(int daysAgo, int hour, String typeId,
        WellnessDomain domain, String label, int points, int qty) {
      final day = now.subtract(Duration(days: daysAgo));
      final time = DateTime(day.year, day.month, day.day, hour);
      return ActivityLog(
        id: 'seed_${daysAgo}_${typeId}_$hour',
        typeId: typeId,
        domain: domain,
        label: label,
        points: points,
        quantity: qty,
        time: time,
      );
    }

    return [
      // Three days ago
      seed(3, 7, 'workout', WellnessDomain.physical, 'Workout - Cycling', 40, 40),
      seed(3, 12, 'fruit_veg', WellnessDomain.nutrition,
          'Fruit & Veggie Servings', 20, 4),
      seed(3, 18, 'water', WellnessDomain.nutrition, 'Water Intake', 12, 6),
      seed(3, 21, 'mindfulness', WellnessDomain.mental, 'Mindfulness', 20, 10),
      // Two days ago
      seed(2, 9, 'steps', WellnessDomain.physical, 'Steps', 9, 9),
      seed(2, 17, 'active_minutes', WellnessDomain.physical, 'Active Minutes',
          45, 45),
      seed(2, 12, 'healthy_meal', WellnessDomain.nutrition,
          'Healthy Meal - Lunch', 15, 1),
      seed(2, 19, 'fruit_veg', WellnessDomain.nutrition,
          'Fruit & Veggie Servings', 15, 3),
      seed(2, 8, 'med_adherence', WellnessDomain.preventive,
          'Medication Adherence', 20, 1),
      seed(2, 22, 'sleep_quality', WellnessDomain.mental, 'Sleep Quality', 32, 4),
      // Yesterday
      seed(1, 6, 'workout', WellnessDomain.physical, 'Workout - Walking', 35, 35),
      seed(1, 15, 'steps', WellnessDomain.physical, 'Steps', 7, 7),
      seed(1, 13, 'healthy_meal', WellnessDomain.nutrition,
          'Healthy Meal - Lunch', 15, 1),
      seed(1, 16, 'water', WellnessDomain.nutrition, 'Water Intake', 10, 5),
      seed(1, 8, 'med_adherence', WellnessDomain.preventive,
          'Medication Adherence', 20, 1),
      seed(1, 20, 'stress_session', WellnessDomain.mental,
          'Stress Management Session', 25, 1),
    ];
  }
}
