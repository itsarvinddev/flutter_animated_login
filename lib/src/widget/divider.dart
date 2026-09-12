import 'package:flutter/material.dart';

/// The "OR" rule between the credential form and the social login buttons.
class DividerText extends StatelessWidget {
  /// Creates a labelled divider.
  const DividerText({super.key, this.child, this.label});

  /// Replaces the label entirely.
  final Widget? child;

  /// The label's text. Defaults to [FormMessages.orDivider].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      // The rule is decoration; the word is already read from the label.
      container: true,
      child: Row(
        children: [
          const Expanded(child: Divider(endIndent: 10)),
          child ??
              Text(
                label ?? 'OR',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          const Expanded(child: Divider(indent: 10)),
        ],
      ),
    );
  }
}
