import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../models/path_to_wellness.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/wellness_calculator.dart';
import '../widgets/grove_card.dart';
import '../widgets/oak_tree.dart';

/// SCREEN 2 — MY TREE. The hero screen: the member's living oak.
class HomeScreen extends StatelessWidget {
  final VoidCallback onLogActivity;
  const HomeScreen({super.key, required this.onLogActivity});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile!;
    final score = state.wellnessIndex;
    final stage = WellnessCalculator.stageFor(score);
    final next = WellnessCalculator.nextStage(score);
    final progress = WellnessCalculator.progressWithinStage(score);
    final celebration = state.celebrateStageName;

    // Animate the tree from wherever the user last saw it (or from a
    // seedling on a fresh launch), then remember today's value.
    final animateFrom = state.lastHomeGrowth ?? 0.03;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.lastHomeGrowth = score / 100;
      if (celebration != null) state.clearCelebration();
    });

    final todayLogs = state.todayLogs;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${_greeting()}, ${profile.firstName}',
              style: groveSerif(size: 24)),
          const SizedBox(height: 2),
          Text(
            '${profile.department} · ${profile.employer}',
            style: const TextStyle(color: GroveColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ---- hero: the living oak ----
          GroveCard(
            padding: EdgeInsets.zero,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDF3E4), Color(0xFFF8F4EA)],
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: OakTreeView(
                      growth: score / 100,
                      seed: 7,
                      animateFrom: animateFrom,
                      duration: const Duration(milliseconds: 1800),
                      sway: true,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: GroveColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stage.name,
                      style: const TextStyle(
                        color: GroveColors.forest,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- stage-crossing celebration banner ----
          if (celebration != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GroveCard(
                color: GroveColors.goldSoft,
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: GroveColors.gold, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Congratulations — your tree has grown into a $celebration!',
                        style: const TextStyle(
                          color: GroveColors.forest,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ---- Wellness Index + progress to next stage ----
          GroveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${score.round()}',
                        style: groveSerif(size: 54, height: 1.0)),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wellness Index',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: GroveColors.forest)),
                          Text('this week · ${stage.name}',
                              style: const TextStyle(
                                  color: GroveColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.eco, color: GroveColors.gold, size: 30),
                  ],
                ),
                const SizedBox(height: 14),
                if (next != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: GroveColors.greenSoft,
                      valueColor:
                          const AlwaysStoppedAnimation(GroveColors.gold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${math.max(1, (next.min - score).ceil())} points to ${next.name}',
                    style: const TextStyle(
                        color: GroveColors.textMuted, fontSize: 12),
                  ),
                ] else
                  const Text(
                    'You are a Full Oak — keep your grove thriving!',
                    style: TextStyle(
                        color: GroveColors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- Path to Wellness progress (City of Rockford program) ----
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
                        child: Text('Path to Wellness',
                            style: groveSerif(size: 17))),
                    Text(
                      '${state.ptwPoints} / ${PtwCatalog.discountThreshold} pts',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: GroveColors.forest),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (state.ptwPoints / PtwCatalog.discountThreshold)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                    minHeight: 10,
                    backgroundColor: GroveColors.greenSoft,
                    valueColor:
                        const AlwaysStoppedAnimation(GroveColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                if (state.ptwDiscountEarned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: GroveColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: GroveColors.green, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Premium Discount Earned — \$500 Savings',
                            style: TextStyle(
                                color: GroveColors.green,
                                fontWeight: FontWeight.w800,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Earn ${PtwCatalog.discountThreshold - state.ptwPoints} more points for your health insurance premium discount',
                    style: const TextStyle(
                        color: GroveColors.textMuted, fontSize: 12),
                  ),
                const SizedBox(height: 4),
                const Text(
                  'City of Rockford employee wellness program',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: GroveColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- today's activity summary ----
          const SectionTitle("Today's Activity"),
          GroveCard(
            child: Column(
              children: [
                Row(
                  children: WellnessDomain.values.map((d) {
                    final info = domainInfo[d]!;
                    return Expanded(
                      child: Column(
                        children: [
                          Icon(info.icon, color: info.color, size: 20),
                          const SizedBox(height: 4),
                          Text('${state.todayPoints(d)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: GroveColors.forest)),
                          Text(info.shortLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: GroveColors.textMuted)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                if (todayLogs.isEmpty)
                  const Text(
                    'Nothing logged yet today — your tree is thirsty!',
                    style:
                        TextStyle(color: GroveColors.textMuted, fontSize: 13),
                  )
                else
                  ...todayLogs.take(3).map(
                        (l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: GroveColors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(l.label,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Text('+${l.points} pts',
                                  style: const TextStyle(
                                      color: GroveColors.gold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ---- prominent Log Activity CTA ----
          ElevatedButton.icon(
            onPressed: onLogActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: GroveColors.gold,
              foregroundColor: GroveColors.forest,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text('Log Activity'),
          ),
        ],
      ),
    );
  }
}
