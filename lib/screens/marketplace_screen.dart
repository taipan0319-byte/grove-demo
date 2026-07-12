import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import '../widgets/grove_card.dart';

/// SCREEN 6 — MARKETPLACE. Local merchant offers redeemable with points
/// (the 8-15% revenue-share stream in the business model).
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final balance = state.pointBalance;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- point balance ----
          GroveCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GroveColors.forest, GroveColors.green],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GroveColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco,
                      color: GroveColors.gold, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$balance points',
                          style: groveSerif(
                              size: 28, color: GroveColors.cream)),
                      const Text(
                        'Earned by growing your tree',
                        style: TextStyle(
                            color: Color(0xFFCBDABB), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (state.redemptionCount > 0)
                  Column(
                    children: [
                      Text('${state.redemptionCount}',
                          style: groveSerif(
                              size: 20, color: GroveColors.gold)),
                      const Text('redeemed',
                          style: TextStyle(
                              color: Color(0xFFCBDABB), fontSize: 10)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const SectionTitle('Rockford Local Offers'),
          ...MockData.offers.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OfferCard(offer: o, balance: balance),
              )),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final int balance;
  const _OfferCard({required this.offer, required this.balance});

  bool get _affordable => balance >= offer.cost;

  @override
  Widget build(BuildContext context) {
    return GroveCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: GroveColors.goldSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(offer.icon, color: GroveColors.bark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.merchant, style: groveSerif(size: 16)),
                const SizedBox(height: 2),
                Text(offer.description,
                    style: const TextStyle(
                        fontSize: 12, color: GroveColors.textMuted)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GroveColors.greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(offer.category,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: GroveColors.green)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('${offer.cost} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color:
                        _affordable ? GroveColors.forest : GroveColors.textMuted,
                  )),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => _redeem(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _affordable ? GroveColors.gold : GroveColors.greenSoft,
                  foregroundColor:
                      _affordable ? GroveColors.forest : GroveColors.textMuted,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800),
                ),
                child: const Text('Redeem'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _redeem(BuildContext context) async {
    final state = context.read<AppState>();
    if (!_affordable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Not enough points — you need ${offer.cost - balance} more. Keep growing!')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GroveColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Redeem at ${offer.merchant}?', style: groveSerif(size: 20)),
        content: Text(
            '${offer.description}\n\nThis will deduct ${offer.cost} points from your balance.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: GroveColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: GroveColors.gold,
                  foregroundColor: GroveColors.forest),
              child: const Text('Redeem')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = state.redeem(offer);
    if (!ok || !context.mounted) return;

    // Success animation: gold check springs in.
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: GroveColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                child: const Icon(Icons.check_circle,
                    color: GroveColors.gold, size: 84),
              ),
              const SizedBox(height: 14),
              Text('Redeemed!', style: groveSerif(size: 26)),
              const SizedBox(height: 6),
              Text(
                '${offer.description}\nShow this screen at ${offer.merchant}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: GroveColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text('Remaining balance: ${state.pointBalance} pts',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: GroveColors.forest)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
