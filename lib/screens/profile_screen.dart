import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../models/path_to_wellness.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/grove_card.dart';

/// SCREEN 7 — PROFILE & SETTINGS. Biometric history, weekly summary,
/// mock wearable connections, notification preferences.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    if (profile == null) {
      // Reset mid-view: pop back and let the root rebuild into onboarding.
      return const SizedBox.shrink();
    }

    final joined =
        '${profile.joinedAt.month}/${profile.joinedAt.day}/${profile.joinedAt.year}';
    final heightFt = profile.heightInches ~/ 12;
    final heightIn = (profile.heightInches % 12).round();

    return Scaffold(
      appBar: AppBar(title: Text('Profile & Settings', style: groveSerif(size: 20))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- identity ----
            GroveCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: GroveColors.forest,
                    child: Text(profile.initials,
                        style: groveSerif(size: 20, color: GroveColors.cream)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: groveSerif(size: 20)),
                        Text('${profile.department} · ${profile.employer}',
                            style: const TextStyle(
                                color: GroveColors.textMuted, fontSize: 12)),
                        Text('Growing since $joined',
                            style: const TextStyle(
                                color: GroveColors.green,
                                fontSize: 11,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- weekly summary stats ----
            const SectionTitle('This Week'),
            GroveCard(
              child: Row(
                children: [
                  _Stat(
                      label: 'Wellness\nIndex',
                      value: '${state.wellnessIndex.round()}'),
                  _Stat(label: 'Points\nearned', value: '${state.pointsThisWeek}'),
                  _Stat(
                      label: 'Activities\nlogged',
                      value: '${state.activitiesThisWeek}'),
                  _Stat(
                      label: 'Strongest\ndomain',
                      value: domainInfo[state.strongestDomain]!.shortLabel,
                      small: true),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- Path to Wellness status (V2.0) ----
            const SectionTitle('Path to Wellness Status'),
            GroveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.savings,
                          color: GroveColors.gold, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${state.ptwPoints} of ${PtwCatalog.discountThreshold} points this plan year',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: GroveColors.forest),
                        ),
                      ),
                      Text(
                        state.ptwDiscountEarned
                            ? '\$${PtwCatalog.discountValue} earned'
                            : '\$${PtwCatalog.discountValue} available',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: state.ptwDiscountEarned
                                ? GroveColors.green
                                : GroveColors.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (state.ptwPoints / PtwCatalog.discountThreshold)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      minHeight: 8,
                      backgroundColor: GroveColors.greenSoft,
                      valueColor:
                          const AlwaysStoppedAnimation(GroveColors.gold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estimated premium discount: '
                    '${state.ptwDiscountEarned ? 'earned — \$${PtwCatalog.discountValue}/year' : '\$${PtwCatalog.discountValue}/year at ${PtwCatalog.discountThreshold} points'}',
                    style: const TextStyle(
                        fontSize: 11, color: GroveColors.textMuted),
                  ),
                  const Divider(height: 20),
                  if (state.ptwCompletedActivities.isNotEmpty) ...[
                    const Text('Completed',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: GroveColors.green)),
                    const SizedBox(height: 4),
                    ...state.ptwCompletedActivities.map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: GroveColors.green, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(a.name,
                                    style: const TextStyle(fontSize: 12))),
                            Text(
                                '+${state.ptwCredited(a) * a.points} pt${state.ptwCredited(a) * a.points == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: GroveColors.green)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Text('Still available',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: GroveColors.textMuted)),
                  const SizedBox(height: 4),
                  ...state.ptwRemainingActivities.map(
                    (a) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_unchecked,
                              color: GroveColors.textMuted, size: 15),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: GroveColors.textMuted))),
                          Text('+${a.points} pt${a.points == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: GroveColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- biometric history: baseline vs current ----
            const SectionTitle('Biometrics — Baseline vs Current'),
            GroveCard(
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                          child: Text('Baseline',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: GroveColors.textMuted))),
                      Expanded(
                          child: Text('Current',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: GroveColors.green))),
                    ],
                  ),
                  const Divider(height: 18),
                  _BioRow(
                      label: 'Height',
                      baseline: "$heightFt'$heightIn\"",
                      current: "$heightFt'$heightIn\""),
                  _BioRow(
                      label: 'Weight',
                      baseline: '${profile.weightLbs.round()} lb',
                      current: '${state.currentWeightLbs.round()} lb',
                      improved:
                          state.currentWeightLbs < profile.weightLbs),
                  _BioRow(
                      label: 'BMI',
                      baseline: profile.baselineBmi.toStringAsFixed(1),
                      current: state.currentBmi.toStringAsFixed(1),
                      improved: state.currentBmi < profile.baselineBmi),
                  _BioRow(
                      label: 'Blood Pressure',
                      baseline: '${profile.systolic}/${profile.diastolic}',
                      current:
                          '${state.currentSystolic}/${state.currentDiastolic}',
                      improved:
                          state.currentSystolic < profile.systolic),
                  _BioRow(
                      label: 'Resting HR',
                      baseline: '${profile.restingHeartRate} bpm',
                      current: '${state.currentRestingHr} bpm',
                      improved:
                          state.currentRestingHr < profile.restingHeartRate),
                  const SizedBox(height: 8),
                  const Text(
                    'Current values are prototype estimates that improve as you log verified biometric milestones.',
                    style: TextStyle(
                        fontSize: 10,
                        color: GroveColors.textMuted,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- wearable connections (mock — UI only) ----
            const SectionTitle('Connections'),
            GroveCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    value: state.appleHealthConnected,
                    onChanged: (v) {
                      state.setAppleHealth(v);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(v
                              ? 'Apple Health connected (mock) — steps will sync automatically'
                              : 'Apple Health disconnected')));
                    },
                    activeThumbColor: GroveColors.green,
                    secondary:
                        const Icon(Icons.favorite, color: GroveColors.forest),
                    title: const Text('Apple Health',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Mock connection — UI only',
                        style: TextStyle(fontSize: 11)),
                  ),
                  SwitchListTile(
                    value: state.googleFitConnected,
                    onChanged: (v) {
                      state.setGoogleFit(v);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(v
                              ? 'Google Fit connected (mock) — steps will sync automatically'
                              : 'Google Fit disconnected')));
                    },
                    activeThumbColor: GroveColors.green,
                    secondary: const Icon(Icons.directions_run,
                        color: GroveColors.forest),
                    title: const Text('Google Fit',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Mock connection — UI only',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- preferences ----
            const SectionTitle('Preferences'),
            GroveCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SwitchListTile(
                value: state.notificationsEnabled,
                onChanged: state.setNotifications,
                activeThumbColor: GroveColors.green,
                secondary: const Icon(Icons.notifications_outlined,
                    color: GroveColors.forest),
                title: const Text('Daily reminders',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Nudge me to water my tree',
                    style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(height: 18),

            // ---- What's New (V2.0) ----
            const SectionTitle("What's New — Version 2.0"),
            const GroveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WhatsNewItem('Path to Wellness integration — earn your '
                      'City of Rockford premium discount right from Grove'),
                  _WhatsNewItem('New Rockford Health Dashboard tab with '
                      'city-wide wellness trends and claims savings'),
                  _WhatsNewItem('City of Rockford branding throughout the app'),
                  _WhatsNewItem('Updated department groves: Public Works, '
                      'Police, Administration, and Fire'),
                  _WhatsNewItem('One-tap logging credits Grove points and '
                      'Path to Wellness points together'),
                  SizedBox(height: 6),
                  Center(
                    child: Text('Grove v2.0.0',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: GroveColors.textMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- demo reset ----
            OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA23B2E),
                side: const BorderSide(color: Color(0xFFA23B2E)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.restart_alt, size: 20),
              label: const Text('Reset prototype data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GroveColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset all data?', style: groveSerif(size: 20)),
        content: const Text(
            'This clears your profile, activity history, and points, and returns to onboarding. Useful between demos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: GroveColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA23B2E),
                  foregroundColor: Colors.white),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Grab the provider before popping — the context unmounts on pop.
    final state = context.read<AppState>();
    Navigator.of(context).pop();
    await state.reset();
  }
}

class _WhatsNewItem extends StatelessWidget {
  final String text;
  const _WhatsNewItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco, color: GroveColors.gold, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12.5, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool small;
  const _Stat({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: groveSerif(size: small ? 15 : 24)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 10, color: GroveColors.textMuted)),
        ],
      ),
    );
  }
}

class _BioRow extends StatelessWidget {
  final String label;
  final String baseline;
  final String current;
  final bool improved;
  const _BioRow({
    required this.label,
    required this.baseline,
    required this.current,
    this.improved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: GroveColors.forest)),
          ),
          Expanded(
            child: Text(baseline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: GroveColors.textMuted)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(current,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: improved
                            ? GroveColors.green
                            : GroveColors.forest)),
                if (improved)
                  const Icon(Icons.arrow_downward,
                      size: 12, color: GroveColors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
