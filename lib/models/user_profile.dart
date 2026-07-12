/// The member's profile and baseline biometrics captured at onboarding.
class UserProfile {
  final String name;
  final String department;
  final String employer;
  final double heightInches;
  final double weightLbs;
  final int systolic;
  final int diastolic;
  final int restingHeartRate;
  final DateTime joinedAt;

  const UserProfile({
    required this.name,
    required this.department,
    required this.employer,
    required this.heightInches,
    required this.weightLbs,
    required this.systolic,
    required this.diastolic,
    required this.restingHeartRate,
    required this.joinedAt,
  });

  String get firstName => name.trim().split(' ').first;

  String get initials {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Standard BMI formula (imperial): 703 * lbs / inches^2
  double get baselineBmi => heightInches <= 0
      ? 0
      : (weightLbs * 703) / (heightInches * heightInches);

  Map<String, dynamic> toJson() => {
        'name': name,
        'department': department,
        'employer': employer,
        'heightInches': heightInches,
        'weightLbs': weightLbs,
        'systolic': systolic,
        'diastolic': diastolic,
        'restingHeartRate': restingHeartRate,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String,
        department: j['department'] as String,
        employer: j['employer'] as String,
        heightInches: (j['heightInches'] as num).toDouble(),
        weightLbs: (j['weightLbs'] as num).toDouble(),
        systolic: (j['systolic'] as num).toInt(),
        diastolic: (j['diastolic'] as num).toInt(),
        restingHeartRate: (j['restingHeartRate'] as num).toInt(),
        joinedAt: DateTime.parse(j['joinedAt'] as String),
      );
}
