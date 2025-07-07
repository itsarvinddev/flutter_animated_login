// File: src/widgets/oauth/oauth_button.dart
import 'package:flutter/material.dart';

import '../../constants/defaults.dart';
import '../../constants/enums.dart';
import '../../theme/auth_theme_extension.dart';

/// A styled OAuth provider button
class OAuthButton extends StatelessWidget {
  /// Provider type
  final AuthProvider provider;

  /// Callback when pressed
  final VoidCallback onPressed;

  /// Loading state
  final bool isLoading;

  /// Button size
  final double size;

  /// Icon size
  final double iconSize;

  /// Custom icon
  final IconData? customIcon;

  /// Custom colors
  final Color? backgroundColor;
  final Color? iconColor;

  const OAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.size = Defaults.oauthButtonSize,
    this.iconSize = Defaults.oauthIconSize,
    this.customIcon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    // Get provider info
    final providerInfo = _getProviderInfo(provider);

    // Effective colors
    final effectiveBackgroundColor = backgroundColor ??
        authTheme.socialButtonColors[providerInfo.name] ??
        Colors.grey.shade200;

    final effectiveIconColor = iconColor ??
        authTheme.socialIconColors[providerInfo.name] ??
        Colors.black87;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: effectiveBackgroundColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize * 0.8,
                    height: iconSize * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(effectiveIconColor),
                    ),
                  )
                : Icon(
                    customIcon ?? providerInfo.icon,
                    color: effectiveIconColor,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );
  }

  /// Get provider display information
  ({String name, IconData icon}) _getProviderInfo(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.google:
        return (name: 'google', icon: Icons.g_mobiledata);
      case AuthProvider.apple:
        return (name: 'apple', icon: Icons.apple);
      case AuthProvider.facebook:
        return (name: 'facebook', icon: Icons.facebook);
      case AuthProvider.twitter:
        return (name: 'twitter', icon: Icons.flutter_dash);
      case AuthProvider.github:
        return (name: 'github', icon: Icons.code);
      case AuthProvider.microsoft:
        return (name: 'microsoft', icon: Icons.window);
      case AuthProvider.custom:
        return (name: 'custom', icon: Icons.account_circle);
    }
  }
}
