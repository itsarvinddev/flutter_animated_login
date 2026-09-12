import 'package:flutter/material.dart';

import '../utils/form_messages.dart';
import '../utils/password_policy.dart';

/// A bar and a word summarising how strong the typed password is.
class PasswordStrengthMeter extends StatelessWidget {
  /// Creates a strength meter.
  const PasswordStrengthMeter({
    super.key,
    required this.strength,
    required this.messages,
  });

  /// How strong the password is.
  final PasswordStrength strength;

  /// Supplies the label for [strength].
  final FormMessages messages;

  Color _color(ColorScheme scheme) => switch (strength) {
        PasswordStrength.empty => scheme.surfaceContainerHighest,
        PasswordStrength.weak => scheme.error,
        PasswordStrength.fair => scheme.tertiary,
        PasswordStrength.good => scheme.secondary,
        PasswordStrength.strong => scheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(theme.colorScheme);
    final label = strength.label(messages);

    return Semantics(
      liveRegion: true,
      label: label.isEmpty ? null : label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                tween: Tween<double>(begin: 0, end: strength.score),
                builder: (context, value, _) => ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A live tick-list of the rules a password has yet to satisfy.
class PasswordRequirementList extends StatelessWidget {
  /// Creates a requirement checklist.
  const PasswordRequirementList({
    super.key,
    required this.unmet,
    required this.satisfiedCount,
  });

  /// The rules still broken, already localized.
  final List<String> unmet;

  /// How many rules are already satisfied, for the summary a screen reader
  /// reads out.
  final int satisfiedCount;

  @override
  Widget build(BuildContext context) {
    if (unmet.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final requirement in unmet)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requirement,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
