import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import '../utils/wellness_calculator.dart';
import '../widgets/grove_card.dart';
import '../widgets/oak_tree.dart';

/// SCREEN 4 — DEPARTMENT GROVE. One tree per department member,
/// aggregate score, and a departmental leaderboard.
class GroveScreen extends StatelessWidget {
  const GroveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile!;
    final myScore = state.wellnessIndex;
    final deptScore = state.departmentScore;
    final standings = state.departmentStandings;
    final rank = state.departmentRank;

    // The user plus 4 anonymized colleagues, ordered by score for a
    // pleasing grove silhouette.
    final members = <GroveMember>[
      GroveMember(profile.firstName, myScore, state.ptwPoints),
      ...MockData.colleagues,
    ]..sort((a, b) => b.score.compareTo(a.score));

    return Stack(
      children: [
        // City of Rockford watermark, top-right (V2.0)
        Positioned(
          top: 6,
          right: 20,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset('assets/images/cor_logo_transparent.png',
                  height: 30),
            ),
          ),
        ),
        SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${profile.department} Grove', style: groveSerif(size: 22)),
          const SizedBox(height: 2),
          Text('${members.length} members growing together',
              style:
                  const TextStyle(color: GroveColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),

          // ---- the grove: one tree per member ----
          GroveCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDF3E4), Color(0xFFF8F4EA)],
            ),
            child: SizedBox(
              height: 190,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < members.length; i++)
                    Expanded(
                      child: _MemberTree(
                        member: members[i],
                        isUser: members[i].firstName == profile.firstName,
                        seed: 11 + i * 17,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- department aggregate ----
          GroveCard(
            child: Row(
              children: [
                Text('${deptScore.round()}',
                    style: groveSerif(size: 44, height: 1.0)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Department Wellness Index',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: GroveColors.forest)),
                      Text(
                        WellnessCalculator.stageFor(deptScore).name,
                        style: const TextStyle(
                            color: GroveColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? GroveColors.goldSoft
                        : GroveColors.greenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        rank == 1 ? Icons.emoji_events : Icons.leaderboard,
                        color:
                            rank == 1 ? GroveColors.gold : GroveColors.green,
                        size: 20,
                      ),
                      Text(
                        '#$rank of ${standings.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: GroveColors.forest),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- department leaderboard ----
          const SectionTitle('Department Leaderboard'),
          GroveCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < standings.length; i++)
                  _LeaderboardRow(
                    rank: i + 1,
                    dept: standings[i],
                    isMine: standings[i].name == profile.department,
                  ),
              ],
            ),
          ),
        ],
      ),
        ),
      ],
    );
  }
}

class _MemberTree extends StatelessWidget {
  final GroveMember member;
  final bool isUser;
  final int seed;
  const _MemberTree(
      {required this.member, required this.isUser, required this.seed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: OakTreeView(growth: member.score / 100, seed: seed),
        ),
        const SizedBox(height: 4),
        Text(
          isUser ? '${member.firstName} (You)' : member.firstName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
            color: isUser ? GroveColors.gold : GroveColors.forest,
          ),
        ),
        Text(
          '${member.score.round()}',
          style: const TextStyle(fontSize: 10, color: GroveColors.textMuted),
        ),
        // Path to Wellness progress (V2.0)
        Text(
          member.ptwPoints >= 6
              ? '★ discount earned'
              : 'PTW ${member.ptwPoints}/6',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: member.ptwPoints >= 6
                ? GroveColors.gold
                : GroveColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final DepartmentInfo dept;
  final bool isMine;
  const _LeaderboardRow(
      {required this.rank, required this.dept, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMine ? GroveColors.goldSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor:
                rank == 1 ? GroveColors.gold : GroveColors.greenSoft,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: rank == 1 ? GroveColors.forest : GroveColors.green,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: TextStyle(
                    fontWeight: isMine ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                    color: GroveColors.forest,
                  ),
                ),
                Text('${dept.members} members',
                    style: const TextStyle(
                        fontSize: 11, color: GroveColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${dept.score.round()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: GroveColors.forest)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dept.score / 100,
                    minHeight: 5,
                    backgroundColor: GroveColors.greenSoft,
                    valueColor:
                        const AlwaysStoppedAnimation(GroveColors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
