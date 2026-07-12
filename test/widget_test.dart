import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grove/main.dart';
import 'package:grove/models/activity.dart';
import 'package:grove/providers/app_state.dart';
import 'package:grove/utils/mock_data.dart';
import 'package:grove/utils/wellness_calculator.dart';

void main() {
  test('wellness index weights sum to 1.0', () {
    final total = WellnessDomain.values
        .fold(0.0, (sum, d) => sum + domainInfo[d]!.weight);
    expect(total, closeTo(1.0, 0.0001));
  });

  test('seeded demo history lands in the Sapling band', () {
    final logs = MockData.buildSeedLogs(DateTime.now());
    final index = WellnessCalculator.wellnessIndex(logs, DateTime.now());
    expect(index, greaterThan(20));
    expect(index, lessThan(41));
  });

  test('daily cap prevents gaming a single domain', () {
    final now = DateTime.now();
    final spam = List.generate(
      50,
      (i) => ActivityLog(
        id: '$i',
        typeId: 'workout',
        domain: WellnessDomain.physical,
        label: 'Workout',
        points: 90,
        quantity: 90,
        time: now,
      ),
    );
    expect(WellnessCalculator.dayPoints(spam, WellnessDomain.physical, now),
        domainInfo[WellnessDomain.physical]!.dailyCap);
  });

  test('stage boundaries match the spec', () {
    expect(WellnessCalculator.stageFor(0).name, 'Seedling');
    expect(WellnessCalculator.stageFor(20).name, 'Seedling');
    expect(WellnessCalculator.stageFor(21).name, 'Sapling');
    expect(WellnessCalculator.stageFor(41).name, 'Young Tree');
    expect(WellnessCalculator.stageFor(61).name, 'Mature Tree');
    expect(WellnessCalculator.stageFor(81).name, 'Full Oak');
    expect(WellnessCalculator.stageFor(100).name, 'Full Oak');
  });

  testWidgets('app boots to onboarding when no profile exists',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs)..load();
    await tester.pumpWidget(GroveApp(appState: state));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('GROVE'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
