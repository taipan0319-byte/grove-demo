import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../models/path_to_wellness.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/grove_card.dart';
import '../widgets/oak_tree.dart';

/// What the log sheet hands back when the user confirms.
class _PendingLog {
  final ActivityType type;
  final int quantity;
  final String? variant;
  const _PendingLog(this.type, this.quantity, this.variant);
}

/// SCREEN 3 — LOG ACTIVITY. Five domain tabs plus the City of Rockford
/// Path to Wellness tab (V2.0).
class LogActivityScreen extends StatelessWidget {
  final VoidCallback onSeeTree;
  const LogActivityScreen({super.key, required this.onSeeTree});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: WellnessDomain.values.length + 1,
      child: Column(
        children: [
          Material(
            color: GroveColors.cream,
            child: TabBar(
              isScrollable: true,
              labelColor: GroveColors.forest,
              unselectedLabelColor: GroveColors.textMuted,
              indicatorColor: GroveColors.gold,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                ...WellnessDomain.values
                    .map((d) => Tab(text: domainInfo[d]!.shortLabel)),
                const Tab(text: 'Path to Wellness'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ...WellnessDomain.values
                    .map((d) => _DomainTab(domain: d, onSeeTree: onSeeTree)),
                _PtwTab(onSeeTree: onSeeTree),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainTab extends StatelessWidget {
  final WellnessDomain domain;
  final VoidCallback onSeeTree;
  const _DomainTab({required this.domain, required this.onSeeTree});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final info = domainInfo[domain]!;
    final today = state.todayPoints(domain);
    final types = ActivityCatalog.forDomain(domain);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        // Domain header: weight in the index + today's capped progress.
        GroveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: info.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info.icon, color: info.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info.label, style: groveSerif(size: 18)),
                        Text(
                          '${(info.weight * 100).round()}% of your Wellness Index',
                          style: const TextStyle(
                              color: GroveColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (today / info.dailyCap).clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: GroveColors.greenSoft,
                  valueColor: AlwaysStoppedAnimation(info.color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$today / ${info.dailyCap} points today (daily cap prevents gaming)',
                style:
                    const TextStyle(color: GroveColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...types.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(type: t, onSeeTree: onSeeTree),
            )),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityType type;
  final VoidCallback onSeeTree;
  const _ActivityTile({required this.type, required this.onSeeTree});

  String get _pointsLabel {
    if (type.hasQuantity) return '+${type.pointsPerUnit} / ${type.unitLabel}';
    return '+${type.pointsPerUnit} pts';
  }

  @override
  Widget build(BuildContext context) {
    final info = domainInfo[type.domain]!;
    return GroveCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _openLogSheet(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(type.icon, color: info.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: GroveColors.forest)),
                Text(type.subtitle,
                    style: const TextStyle(
                        color: GroveColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: GroveColors.goldSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _pointsLabel,
              style: const TextStyle(
                  color: GroveColors.forest,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLogSheet(BuildContext context) async {
    final pending = await showModalBottomSheet<_PendingLog>(
      context: context,
      backgroundColor: GroveColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _LogSheet(type: type),
    );
    if (pending == null || !context.mounted) return;

    final result = context.read<AppState>().logActivity(
          pending.type,
          quantity: pending.quantity,
          variant: pending.variant,
        );

    if (result.stageCrossed) {
      await showGrowthCelebration(context, result, onSeeTree);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+${result.pointsEarned} pts logged · Wellness Index ${result.newIndex.toStringAsFixed(1)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

}

/// Stage-crossing celebration: replays the tree growing from the old
/// index to the new one, right here in a dialog. Shared by the domain
/// tabs and the Path to Wellness tab.
Future<void> showGrowthCelebration(
    BuildContext context, LogResult result, VoidCallback onSeeTree) {
  return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: GroveColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 210,
                width: 210,
                child: OakTreeView(
                  growth: result.newIndex / 100,
                  animateFrom: result.oldIndex / 100,
                  duration: const Duration(milliseconds: 2200),
                  seed: 7,
                ),
              ),
              const SizedBox(height: 12),
              Text('Your tree grew!', style: groveSerif(size: 24)),
              const SizedBox(height: 6),
              Text(
                "You've reached ${result.newStageName}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: GroveColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GroveColors.forest,
                        side: const BorderSide(color: GroveColors.green),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Keep Logging'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onSeeTree();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GroveColors.gold,
                        foregroundColor: GroveColors.forest,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('See My Tree'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
}

/// PATH TO WELLNESS TAB (V2.0) — City of Rockford program activities in
/// Groups A/B/C. One tap credits Grove Wellness Index AND Path to
/// Wellness points simultaneously.
class _PtwTab extends StatelessWidget {
  final VoidCallback onSeeTree;
  const _PtwTab({required this.onSeeTree});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pts = state.ptwPoints;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        GroveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GroveColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.savings,
                        color: GroveColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Path to Wellness', style: groveSerif(size: 18)),
                        const Text(
                          'City of Rockford premium discount program',
                          style: TextStyle(
                              color: GroveColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (pts / PtwCatalog.discountThreshold)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  minHeight: 8,
                  backgroundColor: GroveColors.greenSoft,
                  valueColor: const AlwaysStoppedAnimation(GroveColors.gold),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.ptwDiscountEarned
                    ? 'Premium discount earned — \$${PtwCatalog.discountValue} estimated savings!'
                    : '$pts of ${PtwCatalog.discountThreshold} points earned · one tap credits Grove and Path to Wellness together',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: state.ptwDiscountEarned
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: state.ptwDiscountEarned
                      ? GroveColors.green
                      : GroveColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        for (final g in PtwGroup.values) ...[
          const SizedBox(height: 14),
          SectionTitle(PtwCatalog.groupLabel(g)),
          ...PtwCatalog.forGroup(g).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PtwTile(activity: a, onSeeTree: onSeeTree),
              )),
        ],
      ],
    );
  }
}

class _PtwTile extends StatelessWidget {
  final PtwActivity activity;
  final VoidCallback onSeeTree;
  const _PtwTile({required this.activity, required this.onSeeTree});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.ptwCompleted(activity);
    final credited = state.ptwCredited(activity);

    return GroveCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _log(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: done
                  ? GroveColors.green.withValues(alpha: 0.12)
                  : GroveColors.goldSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(done ? Icons.check_circle : activity.icon,
                color: done ? GroveColors.green : GroveColors.bark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: GroveColors.forest)),
                Text(
                  done
                      ? 'Completed this plan year ✓'
                      : activity.maxTimes > 1
                          ? 'Credited $credited of ${activity.maxTimes} · +${activity.grovePoints} Grove pts per tap'
                          : 'Also credits +${activity.grovePoints} Grove pts',
                  style: TextStyle(
                      color: done ? GroveColors.green : GroveColors.textMuted,
                      fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: done ? GroveColors.greenSoft : GroveColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${activity.points} pt${activity.points == 1 ? '' : 's'}',
              style: TextStyle(
                  color: done ? GroveColors.textMuted : GroveColors.forest,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _log(BuildContext context) {
    final state = context.read<AppState>();
    if (state.ptwCompleted(activity)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Already credited for this plan year — nice work!')));
      return;
    }
    final discountBefore = state.ptwDiscountEarned;
    final result = state.logPtwActivity(activity);

    if (!discountBefore && state.ptwDiscountEarned) {
      // Crossing the 6-point threshold outranks the tree celebration.
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: GroveColors.cream,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) =>
                      Transform.scale(scale: t, child: child),
                  child: const Icon(Icons.savings,
                      color: GroveColors.gold, size: 72),
                ),
                const SizedBox(height: 14),
                Text('Premium Discount Earned!', style: groveSerif(size: 22)),
                const SizedBox(height: 8),
                const Text(
                  'You reached 6 Path to Wellness points — an estimated \$500 in annual premium savings.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: GroveColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: GroveColors.gold,
                        foregroundColor: GroveColors.forest),
                    child: const Text('Wonderful'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (result.stageCrossed) {
      showGrowthCelebration(context, result, onSeeTree);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '+${activity.points} Path to Wellness pt${activity.points == 1 ? '' : 's'} · +${result.pointsEarned} Grove pts'),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

/// Bottom sheet: pick variant (if any), set quantity (if any), confirm.
class _LogSheet extends StatefulWidget {
  final ActivityType type;
  const _LogSheet({required this.type});

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  late int _qty;
  String? _variant;

  @override
  void initState() {
    super.initState();
    _qty = widget.type.defaultQty;
    _variant = widget.type.variants?.first;
  }

  int get _points => widget.type.pointsPerUnit * _qty;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final info = domainInfo[type.domain]!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type.icon, color: info.color, size: 26),
                const SizedBox(width: 10),
                Expanded(child: Text(type.name, style: groveSerif(size: 22))),
              ],
            ),
            const SizedBox(height: 4),
            Text(type.subtitle,
                style: const TextStyle(
                    color: GroveColors.textMuted, fontSize: 13)),

            // ---- variant picker (workout type, screening type, meal) ----
            if (type.variants != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: type.variants!
                    .map((v) => ChoiceChip(
                          label: Text(v),
                          selected: _variant == v,
                          selectedColor: GroveColors.green,
                          backgroundColor: GroveColors.greenSoft,
                          labelStyle: TextStyle(
                            color: _variant == v
                                ? GroveColors.cream
                                : GroveColors.forest,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          onSelected: (_) => setState(() => _variant = v),
                        ))
                    .toList(),
              ),
            ],

            // ---- quantity stepper ----
            if (type.hasQuantity) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _qty > type.minQty
                        ? () => setState(() => _qty = (_qty - type.step)
                            .clamp(type.minQty, type.maxQty)
                            .toInt())
                        : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 34),
                    color: GroveColors.green,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 130),
                    alignment: Alignment.center,
                    child: Text(
                      '$_qty ${type.unitLabel}',
                      style: groveSerif(size: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _qty < type.maxQty
                        ? () => setState(() => _qty = (_qty + type.step)
                            .clamp(type.minQty, type.maxQty)
                            .toInt())
                        : null,
                    icon: const Icon(Icons.add_circle_outline, size: 34),
                    color: GroveColors.green,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                    context, _PendingLog(type, _qty, _variant)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroveColors.forest,
                  foregroundColor: GroveColors.cream,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Log +$_points pts'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
