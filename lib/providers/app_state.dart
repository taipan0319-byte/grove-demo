import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/community.dart';
import '../models/path_to_wellness.dart';
import '../models/user_profile.dart';
import '../utils/mock_data.dart';
import '../utils/wellness_calculator.dart';

/// Outcome of logging an activity — used by the UI to decide whether to
/// show the stage-crossing tree growth celebration.
class LogResult {
  final double oldIndex;
  final double newIndex;
  final bool stageCrossed;
  final String? newStageName;
  final int pointsEarned;
  const LogResult({
    required this.oldIndex,
    required this.newIndex,
    required this.stageCrossed,
    required this.newStageName,
    required this.pointsEarned,
  });
}

/// Central app state (Provider ChangeNotifier). All data is persisted
/// locally as JSON in shared_preferences — no backend for the prototype.
class AppState extends ChangeNotifier {
  static const _storageKey = 'grove_state_v1';

  /// One-time welcome bonus so the marketplace is demo-able on day one.
  static const int welcomeBonus = 500;

  final SharedPreferences _prefs;
  AppState(this._prefs);

  UserProfile? profile;
  List<ActivityLog> logs = [];
  int redeemedPoints = 0;
  int redemptionCount = 0;
  bool notificationsEnabled = true;
  bool appleHealthConnected = false;
  bool googleFitConnected = false;

  /// Pending stage celebration for the home screen (not persisted).
  String? celebrateStageName;

  /// Growth value last rendered on the home screen, so the tree animates
  /// from where the user last saw it (not persisted).
  double? lastHomeGrowth;

  bool get onboarded => profile != null;

  // ---------- Wellness Index ----------

  double get wellnessIndex =>
      WellnessCalculator.wellnessIndex(logs, DateTime.now());

  double domainScore(WellnessDomain d) =>
      WellnessCalculator.domainScore(logs, d, DateTime.now());

  int todayPoints(WellnessDomain d) =>
      WellnessCalculator.dayPoints(logs, d, DateTime.now());

  int weekPoints(WellnessDomain d) =>
      WellnessCalculator.weekPoints(logs, d, DateTime.now());

  List<ActivityLog> get todayLogs {
    final now = DateTime.now();
    final list = logs
        .where((l) =>
            l.time.year == now.year &&
            l.time.month == now.month &&
            l.time.day == now.day)
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  // ---------- Marketplace points ----------

  int get lifetimePoints =>
      logs.fold(0, (sum, l) => sum + l.points) + welcomeBonus;

  int get pointBalance => lifetimePoints - redeemedPoints;

  // ---------- Weekly summary ----------

  int get pointsThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return logs
        .where((l) => l.time.isAfter(cutoff))
        .fold(0, (sum, l) => sum + l.points);
  }

  int get activitiesThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return logs.where((l) => l.time.isAfter(cutoff)).length;
  }

  WellnessDomain get strongestDomain {
    var best = WellnessDomain.physical;
    var bestScore = -1.0;
    for (final d in WellnessDomain.values) {
      final s = domainScore(d);
      if (s > bestScore) {
        bestScore = s;
        best = d;
      }
    }
    return best;
  }

  // ---------- Community aggregation ----------

  /// Department aggregate = average of the live user index + mock colleagues.
  double get departmentScore {
    var total = wellnessIndex;
    for (final c in MockData.colleagues) {
      total += c.score;
    }
    return total / (MockData.colleagues.length + 1);
  }

  String get _myDeptShortName {
    final name = profile?.department ?? 'My Department';
    return name.replaceAll('Department of ', '');
  }

  /// All departments (mock + the user's live one), sorted by score.
  List<DepartmentInfo> get departmentStandings {
    final mine = DepartmentInfo(
      name: profile?.department ?? 'My Department',
      shortName: _myDeptShortName,
      members: MockData.colleagues.length + 1,
      score: departmentScore,
    );
    final list = [...MockData.otherDepartments, mine]
      ..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  int get departmentRank =>
      departmentStandings
          .indexWhere((d) => d.name == (profile?.department ?? '')) +
      1;

  /// Employer index = average across its departments.
  double get employerScore {
    final depts = departmentStandings;
    return depts.fold(0.0, (sum, d) => sum + d.score) / depts.length;
  }

  List<EmployerInfo> get employerStandings {
    final mine = EmployerInfo(
      name: profile?.employer ?? 'My Employer',
      employees: 1240,
      score: employerScore,
    );
    final list = [...MockData.otherEmployers, mine]
      ..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  int get employerRank =>
      employerStandings.indexWhere((e) => e.name == (profile?.employer ?? '')) +
      1;

  // ---------- Path to Wellness (City of Rockford program) ----------
  // Points are derived from the activity log: each 'ptw_*' log credits its
  // activity once, up to that activity's maxTimes per plan year. A Grove
  // flu shot also counts toward the PTW flu shot — same needle, one credit.

  int _ptwTimesLogged(String ptwId) {
    var n = logs.where((l) => l.typeId == ptwId).length;
    if (ptwId == 'ptw_flu') {
      n += logs.where((l) => l.typeId == 'flu_shot').length;
    }
    return n;
  }

  /// Credited completions for one PTW activity (capped at its maxTimes).
  int ptwCredited(PtwActivity a) =>
      math.min(_ptwTimesLogged(a.id), a.maxTimes);

  bool ptwCompleted(PtwActivity a) => ptwCredited(a) >= a.maxTimes;

  bool ptwStarted(PtwActivity a) => ptwCredited(a) > 0;

  /// Path to Wellness points earned this plan year.
  int get ptwPoints => PtwCatalog.all
      .fold(0, (sum, a) => sum + ptwCredited(a) * a.points);

  bool get ptwDiscountEarned => ptwPoints >= PtwCatalog.discountThreshold;

  List<PtwActivity> get ptwCompletedActivities =>
      PtwCatalog.all.where(ptwStarted).toList();

  List<PtwActivity> get ptwRemainingActivities =>
      PtwCatalog.all.where((a) => !ptwCompleted(a)).toList();

  /// Logs a Path to Wellness activity: one tap credits BOTH the Grove
  /// Wellness Index (via a normal activity log) and PTW points (derived
  /// from that same log).
  LogResult logPtwActivity(PtwActivity a) {
    final type = ActivityType(
      id: a.id,
      domain: a.groveDomain,
      name: a.name,
      subtitle: 'Path to Wellness',
      pointsPerUnit: a.grovePoints,
      icon: a.icon,
    );
    return logActivity(type);
  }

  // ---------- Biometric "current" estimates ----------
  // Prototype heuristic: each verified milestone log nudges the displayed
  // current value away from baseline. Real product would use measured data.

  int _countLogs(String typeId) => logs.where((l) => l.typeId == typeId).length;

  double get currentWeightLbs =>
      (profile?.weightLbs ?? 0) - 1.5 * _countLogs('bmi_milestone');

  double get currentBmi {
    final p = profile;
    if (p == null || p.heightInches <= 0) return 0;
    return (currentWeightLbs * 703) / (p.heightInches * p.heightInches);
  }

  int get currentSystolic =>
      (profile?.systolic ?? 0) - 3 * _countLogs('bp_improvement');

  int get currentDiastolic =>
      (profile?.diastolic ?? 0) - 2 * _countLogs('bp_improvement');

  int get currentRestingHr =>
      (profile?.restingHeartRate ?? 0) -
      math.min(6, _countLogs('stress_session'));

  // ---------- Actions ----------

  /// Restores persisted state. Synchronous — prefs are already in memory.
  void load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final p = j['profile'];
      profile = p == null
          ? null
          : UserProfile.fromJson(p as Map<String, dynamic>);
      logs = (j['logs'] as List<dynamic>? ?? [])
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList();
      redeemedPoints = (j['redeemedPoints'] as num?)?.toInt() ?? 0;
      redemptionCount = (j['redemptionCount'] as num?)?.toInt() ?? 0;
      notificationsEnabled = j['notificationsEnabled'] as bool? ?? true;
      appleHealthConnected = j['appleHealthConnected'] as bool? ?? false;
      googleFitConnected = j['googleFitConnected'] as bool? ?? false;
    } catch (_) {
      // Corrupt/legacy state: start fresh rather than crash the prototype.
      profile = null;
      logs = [];
    }
  }

  Future<void> _save() async {
    await _prefs.setString(
      _storageKey,
      jsonEncode({
        'profile': profile?.toJson(),
        'logs': logs.map((l) => l.toJson()).toList(),
        'redeemedPoints': redeemedPoints,
        'redemptionCount': redemptionCount,
        'notificationsEnabled': notificationsEnabled,
        'appleHealthConnected': appleHealthConnected,
        'googleFitConnected': googleFitConnected,
      }),
    );
  }

  /// Completes onboarding and seeds a few days of sample activity so the
  /// grove feels alive immediately (see MockData.buildSeedLogs).
  Future<void> completeOnboarding(UserProfile p) async {
    profile = p;
    logs = MockData.buildSeedLogs(DateTime.now());
    redeemedPoints = 0;
    redemptionCount = 0;
    await _save();
    notifyListeners();
  }

  LogResult logActivity(ActivityType type, {int quantity = 1, String? variant}) {
    final now = DateTime.now();
    final oldIndex = wellnessIndex;
    final points = type.pointsPerUnit * quantity;
    final label = variant == null ? type.name : '${type.name} - $variant';
    logs.add(ActivityLog(
      id: now.microsecondsSinceEpoch.toString(),
      typeId: type.id,
      domain: type.domain,
      label: label,
      points: points,
      quantity: quantity,
      time: now,
    ));
    final newIndex = wellnessIndex;
    final crossed = WellnessCalculator.stageIndexFor(newIndex) >
        WellnessCalculator.stageIndexFor(oldIndex);
    String? newStageName;
    if (crossed) {
      newStageName = WellnessCalculator.stageFor(newIndex).name;
      celebrateStageName = newStageName;
    }
    _save();
    notifyListeners();
    return LogResult(
      oldIndex: oldIndex,
      newIndex: newIndex,
      stageCrossed: crossed,
      newStageName: newStageName,
      pointsEarned: points,
    );
  }

  /// Deducts points for a marketplace redemption. Returns false when the
  /// balance is insufficient.
  bool redeem(Offer offer) {
    if (pointBalance < offer.cost) return false;
    redeemedPoints += offer.cost;
    redemptionCount++;
    _save();
    notifyListeners();
    return true;
  }

  void setNotifications(bool v) {
    notificationsEnabled = v;
    _save();
    notifyListeners();
  }

  void setAppleHealth(bool v) {
    appleHealthConnected = v;
    _save();
    notifyListeners();
  }

  void setGoogleFit(bool v) {
    googleFitConnected = v;
    _save();
    notifyListeners();
  }

  /// Consumed by the home screen after showing the celebration banner.
  /// Silent (no notify) to avoid a rebuild loop mid-frame.
  void clearCelebration() {
    celebrateStageName = null;
  }

  /// Wipes all prototype data and returns to onboarding.
  Future<void> reset() async {
    await _prefs.remove(_storageKey);
    profile = null;
    logs = [];
    redeemedPoints = 0;
    redemptionCount = 0;
    notificationsEnabled = true;
    appleHealthConnected = false;
    googleFitConnected = false;
    celebrateStageName = null;
    lastHomeGrowth = null;
    notifyListeners();
  }
}
