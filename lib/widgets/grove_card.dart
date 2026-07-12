import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Warm rounded card used across every screen — keeps the UI organic
/// rather than clinical.
class GroveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final BorderSide? border;
  final VoidCallback? onTap;

  const GroveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = GroveColors.card,
    this.gradient,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: border == null ? null : Border.fromBorderSide(border!),
        boxShadow: [
          BoxShadow(
            color: GroveColors.forest.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }
}

/// Serif section heading with optional trailing widget.
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(child: Text(text, style: groveSerif(size: 18))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
