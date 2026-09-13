import 'dart:async';

import 'package:flutter/material.dart';

import '../flutter_animated_login.dart';
import 'controller.dart';
import 'utils/extension.dart';
import 'utils/loading_state.dart';
import 'widget/button.dart';
import 'widget/oauth.dart';

/// The screen that asks for the one-time code.
class FlutterAnimatedVerify extends StatefulWidget {
  /// Creates the verify screen.
  const FlutterAnimatedVerify({
    super.key,
    required this.config,
    required this.formMessages,
    required this.controller,
    this.onVerify,
    this.onResendOtp,
    this.footerWidget,
    this.termsAndConditions,
    this.providers,
    this.providerLayout = ProviderLayout.iconWrap,
    this.providerSpacing = 12,
    this.pageConfig = const PageConfig(),
  });

  /// Runs your one-time-code check.
  final VerifyCallback? onVerify;

  /// Sends another code.
  final ResendOtpCallback? onResendOtp;

  /// Everything about this screen.
  final VerifyConfig config;

  /// Rendered last.
  final Widget? footerWidget;

  /// Terms text shown under the social buttons.
  final Widget? termsAndConditions;

  /// The social sign-in options.
  final List<LoginProvider>? providers;

  /// How the social buttons are arranged.
  final ProviderLayout providerLayout;

  /// Space between social buttons.
  final double providerSpacing;

  /// Every user-facing string.
  final FormMessages formMessages;

  /// Owns the flow's state, including who the code was sent to.
  final FlutterAnimatedLoginController controller;

  /// Everything about the page this screen is drawn on.
  final PageConfig pageConfig;

  @override
  State<FlutterAnimatedVerify> createState() => _FlutterAnimatedVerifyState();
}

class _FlutterAnimatedVerifyState extends State<FlutterAnimatedVerify> {
  final ScreenErrorSnackBar _errors = ScreenErrorSnackBar();
  Timer? _cooldownTimer;
  Duration _remaining = Duration.zero;
  bool _submitting = false;

  VerifyConfig get config => widget.config;
  OtpTextFiledConfig get textConfig => config.textFiledConfig;
  FormMessages get messages => widget.formMessages;
  FlutterAnimatedLoginController get controller => widget.controller;

  /// The code's length, honoured everywhere. Before 1.0.0 the literal 6 was
  /// hardcoded in initState while the field itself honoured this value, so a
  /// 4-digit code never auto-submitted and an 8-digit one was truncated.
  int get _length => textConfig.length ?? 6;

  /// Who the code is for, as the callbacks receive it: the identifier in
  /// E.164 or as typed. [FlutterAnimatedLoginController.showOtp]'s `sentTo`
  /// is a display label, so it is used only when nothing was entered — a code
  /// sent out of band, say. Before, a label such as "+1 201-555-0123" reached
  /// onVerify as LoginData.name instead of "+12015550123".
  String get _name {
    final identifier = controller.identifier;
    return identifier.isNotEmpty ? identifier : controller.otpSentTo;
  }

  /// What the subtitle shows.
  String get _sentToLabel => controller.otpSentTo;

  bool get _cooldownActive => _remaining > Duration.zero;

  bool get _resendExhausted =>
      config.maxResendAttempts > 0 &&
      controller.resendAttempts >= config.maxResendAttempts;

  @override
  void initState() {
    super.initState();
    if (config.startCooldownOnOpen) _startCooldown();

    final text = controller.otpController.text;
    if (text.length > _length) {
      controller.otpController.text = text.substring(0, _length);
    }
    if (controller.otpController.text.length == _length &&
        config.autoSubmitOnFill) {
      // After the first frame, so the host can react to a pre-filled code.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onCompleted(controller.otpController.text);
      });
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    if (config.resendCooldown <= Duration.zero) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    setState(() => _remaining = config.resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
        config.onCooldownFinished?.call();
      } else {
        setState(() => _remaining = next);
      }
    });
  }

  Future<void> _onCompleted(String value) async {
    if (_submitting) return;
    _submitting = true;
    final data = LoginData(
      name: _name,
      secret: value,
      method: LoginMethod.otp,
      phoneNumber: controller.isPhone ? controller.phoneNumber : null,
      acceptedTerms: controller.acceptedTerms,
    );
    textConfig.onCompleted?.call(data);

    try {
      final result = await widget.onVerify?.call(data);
      // The host very often navigates away inside onVerify; touching the
      // controller or the context afterwards used to throw.
      if (!mounted) return;
      if (result.isNotEmptyOrNull) {
        _errors.show(context, messages.errorTitle, description: result);
        controller.clearOtp();
      } else {
        _errors.dismiss(context);
        resetUnlessNavigatedAway(context, controller.reset);
      }
    } finally {
      _submitting = false;
    }
  }

  Future<void> _resend() async {
    final result = await widget.onResendOtp?.call(
      LoginData(
        name: _name,
        method: LoginMethod.otp,
        phoneNumber: controller.isPhone ? controller.phoneNumber : null,
        acceptedTerms: controller.acceptedTerms,
      ),
    );
    if (!mounted) return;
    if (result.isNotEmptyOrNull) {
      _errors.show(context, messages.errorTitle, description: result);
      return;
    }
    controller.recordResend();
    controller.clearOtp();
    _startCooldown();
  }

  PinTheme _defaultPinTheme(BuildContext context) {
    final theme = Theme.of(context);
    final loginTheme = AnimatedLoginTheme.of(context);
    if (loginTheme.defaultPinTheme != null) return loginTheme.defaultPinTheme!;
    // Scales with the user's text size; the old fixed 56x60 cells clipped
    // their digits at large text scales.
    final scale = MediaQuery.textScalerOf(context).scale(20) / 20;
    return PinTheme(
      width: 56 * scale.clamp(1.0, 1.6),
      height: 60 * scale.clamp(1.0, 1.6),
      textStyle: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AnimatedLoginScope.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loginTheme = AnimatedLoginTheme.of(context);
    final defaultPinTheme = _defaultPinTheme(context);
    final isEmail = _sentToLabel.isEmail || _name.isEmail;

    return PageWidget(
      config: widget.pageConfig,
      builder:
          (context, constraints) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              config.header ??
                  config.titleWidget ??
                  TitleWidget(
                    title:
                        config.title ??
                        (isEmail
                            ? messages.otpSentToEmail
                            : messages.otpSentToPhone),
                    titleStyle:
                        AnimatedLoginTheme.of(context).titleStyle ??
                        textTheme.titleLarge,
                    // Isolated left-to-right: in an RTL layout "+971501234567" otherwise
                    // drew its "+" after the digits.
                    subtitle: config.subtitle ?? '\u2066$_sentToLabel\u2069',
                    subtitleStyle:
                        AnimatedLoginTheme.of(context).subtitleStyle ??
                        textTheme.titleMedium,
                    titleGap: const SizedBox(height: 6),
                    actionLabel: messages.edit,
                    onTap: () => controller.goTo(LoginStep.login),
                    child: config.logo,
                  ),
              Semantics(
                textField: true,
                label: textConfig.semanticLabel ?? messages.otpFieldLabel,
                child: Pinput(
                  length: _length,
                  controller: controller.otpController,
                  pinAnimationType: textConfig.pinAnimationType,
                  smsRetriever: textConfig.smsRetriever,
                  autofillHints:
                      textConfig.autofillHints ??
                      const <String>[AutofillHints.oneTimeCode],
                  focusedPinTheme:
                      textConfig.focusedPinTheme ??
                      loginTheme.focusedPinTheme ??
                      defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration?.copyWith(
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                      ),
                  submittedPinTheme:
                      textConfig.submittedPinTheme ??
                      loginTheme.submittedPinTheme,
                  errorPinTheme:
                      textConfig.errorPinTheme ??
                      loginTheme.errorPinTheme ??
                      defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.error),
                        ),
                      ),
                  defaultPinTheme:
                      textConfig.defaultPinTheme ?? defaultPinTheme,
                  onCompleted: config.autoSubmitOnFill ? _onCompleted : null,
                  onChanged:
                      (value) => textConfig.onChanged?.call(
                        LoginData(name: _name, secret: value),
                      ),
                  onSubmitted: (value) {
                    textConfig.onSubmitted?.call(
                      LoginData(name: _name, secret: value),
                    );
                    _onCompleted(value);
                  },
                  onAppPrivateCommand: textConfig.onAppPrivateCommand,
                  onClipboardFound: textConfig.onClipboardFound,
                  onLongPress: textConfig.onLongPress,
                  onTap: textConfig.onTap,
                  onTapOutside: textConfig.onTapOutside,
                  onTapUpOutside: textConfig.onTapUpOutside,
                  animationCurve: textConfig.animationCurve,
                  animationDuration:
                      textConfig.animationDuration ?? kThemeAnimationDuration,
                  autofocus: textConfig.autofocus,
                  closeKeyboardWhenCompleted:
                      textConfig.closeKeyboardWhenCompleted,
                  contextMenuBuilder: textConfig.contextMenuBuilder,
                  crossAxisAlignment: textConfig.crossAxisAlignment,
                  cursor: textConfig.cursor,
                  disabledPinTheme: textConfig.disabledPinTheme,
                  enableIMEPersonalizedLearning:
                      textConfig.enableIMEPersonalizedLearning,
                  enableInteractiveSelection:
                      textConfig.enableInteractiveSelection,
                  enableSuggestions: textConfig.enableSuggestions,
                  enabled: textConfig.enabled,
                  errorBuilder: textConfig.errorBuilder,
                  errorText: textConfig.errorText,
                  errorTextStyle: textConfig.errorTextStyle,
                  showErrorWhenFocused: textConfig.showErrorWhenFocused,
                  keyboardType: textConfig.keyboardType,
                  focusNode: textConfig.focusNode,
                  followingPinTheme: textConfig.followingPinTheme,
                  forceErrorState: textConfig.forceErrorState,
                  hapticFeedbackType: textConfig.hapticFeedbackType,
                  inputFormatters: textConfig.inputFormatters,
                  isCursorAnimationEnabled: textConfig.isCursorAnimationEnabled,
                  keyboardAppearance: textConfig.keyboardAppearance,
                  mainAxisAlignment: textConfig.mainAxisAlignment,
                  mouseCursor: textConfig.mouseCursor,
                  obscureText: textConfig.obscureText,
                  obscuringCharacter: textConfig.obscuringCharacter,
                  obscuringWidget: textConfig.obscuringWidget,
                  pinContentAlignment: textConfig.pinContentAlignment,
                  pinputAutovalidateMode: textConfig.pinputAutovalidateMode,
                  preFilledWidget: textConfig.preFilledWidget,
                  readOnly: textConfig.readOnly,
                  restorationId: textConfig.restorationId,
                  scrollPadding: textConfig.scrollPadding,
                  selectionControls: textConfig.selectionControls,
                  separatorBuilder: textConfig.separatorBuilder,
                  showCursor: textConfig.showCursor,
                  slideTransitionBeginOffset:
                      textConfig.slideTransitionBeginOffset,
                  textCapitalization: textConfig.textCapitalization,
                  textInputAction: textConfig.textInputAction,
                  toolbarEnabled: textConfig.toolbarEnabled,
                  useNativeKeyboard: textConfig.useNativeKeyboard,
                  validator: textConfig.validator,
                ),
              ),
              const SizedBox(height: 20),
              _buildResend(context, textTheme),
              if (config.showProviders)
                OAuthWidget(
                  providers: widget.providers,
                  termsAndConditions: widget.termsAndConditions,
                  footerWidget: config.footer ?? widget.footerWidget,
                  messages: messages,
                  controller: controller,
                  layout: widget.providerLayout,
                  spacing: widget.providerSpacing,
                )
              else
                (config.footer ?? widget.footerWidget).orShrink,
            ],
          ),
    );
  }

  Widget _buildResend(BuildContext context, TextTheme textTheme) {
    // Without onResendOtp there is nothing to resend with. The button used to
    // show anyway, and a tap restarted the countdown as though a new code were
    // on its way.
    if (widget.onResendOtp == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    if (_resendExhausted) {
      return Text(
        messages.resendLimitReached,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
      );
    }

    if (_cooldownActive) {
      final custom = config.countdownBuilder?.call(context, _remaining);
      if (custom != null) return custom;
      return Semantics(
        liveRegion: true,
        child: Text(
          '${messages.resendOTP} '
          '(${_remaining.inMinutes.toDigital}:'
          '${(_remaining.inSeconds % 60).toDigital})',
          style: textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ActionButtonBox(
      child: AutoLoadingButton(
        variant: AutoLoadingButtonVariant.text,
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          textStyle:
              config.buttonTextStyle ??
              AnimatedLoginTheme.of(context).linkStyle ??
              textTheme.titleMedium,
        ),
        onPressed: _resend,
        child: config.resendButton ?? Text(messages.resendOTP),
      ),
    );
  }
}
