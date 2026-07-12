import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/wellness_calculator.dart';
import '../widgets/grove_card.dart';
import '../widgets/oak_tree.dart';
import '../widgets/symbol_sculpture.dart';

/// SCREEN 5 — EMPLOYER FOREST. One tree cluster per department; cluster
/// size and fullness reflect that department's aggregate wellness score.
class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile!;
    final departments = state.departmentStandings;
    final employerScore = state.employerScore;
    final employers = state.employerStandings;
    final rank = state.employerRank;

    return Stack(
      children: [
        // Abstract Symbol-sculpture watermark (V2.0)
        const SymbolSculptureBackground(),
        SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${profile.employer} Forest', style: groveSerif(size: 22)),
          const SizedBox(height: 2),
          Text('${departments.length} department groves',
              style:
                  const TextStyle(color: GroveColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),

          // ---- the forest: one cluster per department ----
          GroveCard(
            padding: const EdgeInsets.fromLTRB(6, 18, 6, 12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9F1DE), Color(0xFFF8F4EA)],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < departments.length; i++)
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: TreeCluster(
                                  growth: departments[i].score / 100,
                                  seed: 5 + i * 31,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                departments[i].shortName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: departments[i].name ==
                                          profile.department
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: departments[i].name ==
                                          profile.department
                                      ? GroveColors.gold
                                      : GroveColors.forest,
                                ),
                              ),
                              Text(
                                '${departments[i].score.round()}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: GroveColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // ground strip beneath the forest
                Container(
                  height: 5,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(colors: [
                      GroveColors.greenSoft,
                      Color(0xFFCBDABB),
                      GroveColors.greenSoft,
                    ]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- City of Rockford partnership mark (V2.0) ----
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/cor_logo_transparent.png',
                  height: 38),
              const SizedBox(width: 12),
              const Text(
                'Powered by Grove',
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: GroveColors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---- overall employer index ----
          GroveCard(
            child: Row(
              children: [
                Text('${employerScore.round()}',
                    style: groveSerif(size: 44, height: 1.0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Employer Wellness Index',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: GroveColors.forest)),
                      Text(
                        WellnessCalculator.stageFor(employerScore).name,
                        style: const TextStyle(
                            color: GroveColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.forest, color: GroveColors.green, size: 34),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- regional civic ecosystem ranking ----
          const SectionTitle('Rockford Regional Ecosystem'),
          GroveCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < employers.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: employers[i].name == profile.employer
                          ? GroveColors.goldSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: i == 0
                              ? GroveColors.gold
                              : GroveColors.greenSoft,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: i == 0
                                  ? GroveColors.forest
                                  : GroveColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employers[i].name,
                                style: TextStyle(
                                  fontWeight:
                                      employers[i].name == profile.employer
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                  fontSize: 13,
                                  color: GroveColors.forest,
                                ),
                              ),
                              Text(
                                '${employers[i].employees} employees',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: GroveColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${employers[i].score.round()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: GroveColors.forest),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rank == 1
                ? '${profile.employer} leads the region — the civic ecosystem is thriving.'
                : '${profile.employer} is #$rank in the region. Every activity logged helps close the gap.',
            style: const TextStyle(
                color: GroveColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
        ),
      ],
    );
  }
}
