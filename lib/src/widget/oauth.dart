import 'package:flutter/material.dart';

import '../../flutter_animated_login.dart';
import '../utils/extension.dart';
import '../utils/loading_state.dart';
import 'button.dart';
import 'divider.dart';

/// The social login buttons, the terms text and the screen footer.
class OAuthWidget extends StatelessWidget {
  /// Creates the social login block.
  const OAuthWidget({
    super.key,
    required this.messages,
    required this.controller,
    this.providers,
    this.termsAndConditions,
    this.footerWidget,
    this.layout = ProviderLayout.iconWrap,
    this.spacing = 12,
  });

  /// The providers to offer.
  final List<LoginProvider>? providers;

  /// Terms text shown under the buttons.
  final Widget? termsAndConditions;

  /// Rendered last.
  final Widget? footerWidget;

  /// Every user-facing string.
  final FormMessages messages;

  /// Used to open the signup screen when a provider asks for more details.
  final FlutterAnimatedLoginController controller;

  /// How the buttons are arranged.
  final ProviderLayout layout;

  /// Space between buttons.
  final double spacing;

  Future<void> _run(BuildContext context, LoginProvider provider) async {
    final result = await provider.callback.call();
    if (!context.mounted) return;
    if (!provider.shouldSuppress(result)) {
      context.error(messages.errorTitle, description: result);
      return;
    }
    // Only ask for extra details once the provider actually signed the user in.
    final needsSignUp = await provider.providerNeedsSignUpCallback?.call();
    if (needsSignUp ?? false) controller.goTo(LoginStep.signup);
  }

  String _semanticsFor(LoginProvider provider) {
    if (provider.semanticLabel != null) return provider.semanticLabel!;
    final label = provider.label;
    if (label is Text && label.data.isNotEmptyOrNull) {
      return label.data!;
    }
    return messages.signIn;
  }

  @override
  Widget build(BuildContext context) {
    final list = providers;
    final hasProviders = list.isNotEmptyOrNull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasProviders) ...[
          const SizedBox(height: 18),
          DividerText(label: messages.orDivider),
          const SizedBox(height: 12),
          _buildProviders(context, list!),
        ],
        termsAndConditions.orShrink,
        footerWidget.orShrink,
      ],
    );
  }

  Widget _buildProviders(BuildContext context, List<LoginProvider> list) {
    return switch (layout) {
      ProviderLayout.fullWidthStacked => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            _FullWidthProviderButton(
              provider: list[i],
              semanticLabel: _semanticsFor(list[i]),
              onPressed: () => _run(context, list[i]),
            ),
          ],
        ],
      ),
      // A bare Row overflowed with four providers on a phone, and with three
      // at 2x text scale. Wrap costs nothing and cannot overflow.
      ProviderLayout.iconWrap => Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final provider in list)
            _IconProviderButton(
              provider: provider,
              semanticLabel: _semanticsFor(provider),
              onPressed: () => _run(context, provider),
            ),
        ],
      ),
      ProviderLayout.iconRow => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Flexible(
              child: _IconProviderButton(
                provider: list[i],
                semanticLabel: _semanticsFor(list[i]),
                onPressed: () => _run(context, list[i]),
              ),
            ),
          ],
        ],
      ),
    };
  }
}

class _IconProviderButton extends StatelessWidget {
  const _IconProviderButton({
    required this.provider,
    required this.semanticLabel,
    required this.onPressed,
  });

  final LoginProvider provider;
  final String semanticLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    if (provider.button != null) return provider.button!;

    final loginTheme = AnimatedLoginTheme.of(context);
    final icon =
        provider.iconWidget ??
        Icon(provider.icon, color: provider.foregroundColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: semanticLabel,
          child: ExcludeSemantics(
            child: SizedBox(
              // 48x48 is the smallest comfortable touch target on every
              // platform; the old circular buttons floated inside oversized
              // boxes and were smaller than that.
              width: 48,
              height: 48,
              child: AutoLoadingButton(
                transitionDuration: provider.transitionDuration,
                onPressed: onPressed,
                style:
                    provider.style ??
                    loginTheme.providerButtonStyle ??
                    FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.square(48),
                      backgroundColor: provider.backgroundColor,
                      foregroundColor: provider.foregroundColor,
                    ),
                loadingColor: provider.loadingColor,
                loading: provider.loading,
                child: icon,
              ),
            ),
          ),
        ),
        if (provider.label != null) ...[
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
            child: ExcludeSemantics(child: provider.label!),
          ),
        ],
      ],
    );
  }
}

class _FullWidthProviderButton extends StatelessWidget {
  const _FullWidthProviderButton({
    required this.provider,
    required this.semanticLabel,
    required this.onPressed,
  });

  final LoginProvider provider;
  final String semanticLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    if (provider.button != null) return provider.button!;

    final loginTheme = AnimatedLoginTheme.of(context);
    final icon =
        provider.iconWidget ??
        Icon(provider.icon, color: provider.foregroundColor);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: ActionButtonBox(
          child: AutoLoadingButton(
            transitionDuration: provider.transitionDuration,
            onPressed: onPressed,
            style:
                provider.style ??
                loginTheme.providerButtonStyle ??
                FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: provider.backgroundColor,
                  foregroundColor: provider.foregroundColor,
                ),
            loadingColor: provider.loadingColor,
            loading: provider.loading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (provider.label != null) ...[
                  const SizedBox(width: 12),
                  Flexible(child: provider.label!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The consent checkbox that can gate the primary button.
class ConsentCheckbox extends StatelessWidget {
  /// Creates the consent checkbox.
  const ConsentCheckbox({
    super.key,
    required this.config,
    required this.controller,
  });

  /// How the checkbox behaves.
  final ConsentConfig config;

  /// Holds whether the box is ticked.
  final FlutterAnimatedLoginController controller;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: controller.acceptedTerms,
      onChanged: (value) {
        controller.setAcceptedTerms(value ?? false);
        config.onChanged?.call(value ?? false);
      },
      title: config.label,
      controlAffinity: config.controlAffinity,
      contentPadding: config.contentPadding,
      dense: true,
    );
  }
}
