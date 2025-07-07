// File: src/widgets/oauth/oauth_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/enums.dart';
import 'oauth_button.dart';

/// A row of OAuth provider buttons
class OAuthButtonRow extends ConsumerWidget {
  /// Custom providers list (if not using the ones from config)
  final List<AuthProvider>? providers;

  /// Callback when a provider is pressed
  final Future<void> Function(AuthProvider)? onProviderPressed;

  /// Spacing between buttons
  final double spacing;

  /// Button size
  final double buttonSize;

  /// Icon size
  final double iconSize;

  /// Loading state
  final bool isLoading;

  const OAuthButtonRow({
    super.key,
    this.providers,
    this.onProviderPressed,
    this.spacing = 16.0,
    this.buttonSize = 44.0,
    this.iconSize = 24.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For OAuth buttons, we'll pass the loading state directly as a prop
    // instead of trying to access the parent's provider
    // This avoids complex provider access patterns

    // Use provided providers or get from config
    final effectiveProviders = providers ??
        [
          AuthProvider.google,
          AuthProvider.apple,
          AuthProvider.facebook,
        ];

    if (effectiveProviders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: effectiveProviders.map((provider) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: OAuthButton(
            provider: provider,
            size: buttonSize,
            iconSize: iconSize,
            isLoading: isLoading,
            onPressed: () {
              if (onProviderPressed != null) {
                onProviderPressed!(provider);
              } else {
                // Since we no longer have direct access to the controller
                // we'll rely on callback to handle provider auth
                debugPrint("Provider auth pressed: $provider");
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
