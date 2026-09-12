import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flutter_animated_login.dart';
import 'controller.dart';
import 'utils/extension.dart';
import 'widget/button.dart';
import 'widget/identity_field.dart';
import 'widget/oauth.dart';
import 'widget/password_field.dart';

/// Runs your sign-in.
///
/// Return `null` or the empty string on success, or a message describing the
/// failure — it is shown to the user.
typedef LoginCallback = Future<String?>? Function(LoginData);

/// Runs your account creation. Same success and failure convention as
/// [LoginCallback].
typedef SignupCallback = Future<String?>? Function(SignupData);

/// Asked after a provider signs a user in. Resolve `true` to open the signup
/// screen so extra details can be collected.
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// Runs a social provider's authentication. Same success and failure
/// convention as [LoginCallback].
typedef ProviderAuthCallback = Future<String?>? Function();

/// Runs your one-time-code check. Same success and failure convention as
/// [LoginCallback].
typedef VerifyCallback = Future<String?>? Function(LoginData);

/// Sends another one-time code. Same success and failure convention as
/// [LoginCallback].
typedef ResendOtpCallback = Future<String?>? Function(LoginData);

/// Sends a password-reset link. Same success and failure convention as
/// [LoginCallback].
typedef ResetPasswordCallback = Future<String?>? Function(String);

/// How the user signs in.
enum LoginType {
  /// A one-time code only. Submitting the identifier advances to the verify
  /// screen.
  otp,

  /// A password only.
  password,

  /// The user chooses. The login screen shows a password field and a link that
  /// switches to the one-time-code path, and [LoginData.method] tells you which
  /// one ran.
  ///
  /// Before 1.0.0 this behaved exactly like [otp] — no password field, no
  /// choice, and no advance to the verify screen.
  otpAndPassword,
}

/// An animated login flow: sign in, one-time code, sign up and reset password
/// on one widget.
///
/// ```dart
/// FlutterAnimatedLogin(
///   onLogin: (data) async {
///     await api.sendOtp(data.name);
///     return null;            // null means success
///   },
///   onVerify: (data) async => api.verify(data.name, data.secret!),
/// )
/// ```
///
/// Pass a [controller] to drive the flow yourself — jump to the verify screen,
/// prefill from a deep link, reset after a sign-out.
class FlutterAnimatedLogin extends StatefulWidget {
  /// Runs your sign-in.
  final LoginCallback? onLogin;

  /// Runs your account creation. Supplying it shows the "Sign Up" link.
  final SignupCallback? onSignup;

  /// Runs your one-time-code check.
  final VerifyCallback? onVerify;

  /// Sends another one-time code.
  final ResendOtpCallback? onResendOtp;

  /// Sends a password-reset link. Supplying it shows the
  /// "Forgot Password?" link.
  final ResetPasswordCallback? onResetPassword;

  /// Everything about the login screen.
  final LoginConfig loginConfig;

  /// The social sign-in options.
  final List<LoginProvider>? providers;

  /// How the user signs in.
  final LoginType loginType;

  /// Everything about the one-time-code screen.
  final VerifyConfig verifyConfig;

  /// Terms text shown under the social buttons.
  ///
  /// For consent that must be given before the form can be submitted, use
  /// [consent] instead.
  final Widget? termsAndConditions;

  /// A checkbox the user must tick before the primary button enables.
  final ConsentConfig? consent;

  /// Everything about the page the screens are drawn on.
  final PageConfig config;

  /// Everything about the reset-password screen.
  final ResetConfig resetConfig;

  /// Everything about the signup screen.
  final SignupConfig signupConfig;

  /// Drives the flow from outside.
  ///
  /// Optional: one is created and disposed internally when you pass none. A
  /// controller you supply is yours to dispose.
  final FlutterAnimatedLoginController? controller;

  /// Branding for every screen. Wins over
  /// `Theme.of(context).extension<AnimatedLoginTheme>()`.
  final AnimatedLoginTheme? theme;

  /// Called whenever the visible screen changes.
  final ValueChanged<LoginStep>? onStepChanged;

  /// Whether the Android system back button and the browser back button move
  /// back to the login screen instead of leaving the flow.
  ///
  /// Only intercepts back while a screen other than [LoginStep.login] is
  /// showing, so the host route still pops normally from the login screen.
  final bool handleBackNavigation;

  /// No longer used.
  @Deprecated(
    'Signals were removed in 1.0.0, so there is no observer left to toggle. '
    'This flag does nothing and will be removed in 2.0.0.',
  )
  final bool debug;

  /// Creates an animated login flow.
  const FlutterAnimatedLogin({
    super.key,
    this.onLogin,
    this.onSignup,
    this.onVerify,
    this.onResendOtp,
    this.onResetPassword,
    this.loginConfig = const LoginConfig(),
    this.providers,
    this.loginType = LoginType.otp,
    this.verifyConfig = const VerifyConfig(),
    this.termsAndConditions,
    this.consent,
    this.config = const PageConfig(),
    this.resetConfig = const ResetConfig(),
    this.signupConfig = const SignupConfig(),
    this.controller,
    this.theme,
    this.onStepChanged,
    this.handleBackNavigation = true,
    @Deprecated('Does nothing since 1.0.0. Removed in 2.0.0.')
    this.debug = false,
  });

  @override
  State<FlutterAnimatedLogin> createState() => _FlutterAnimatedLoginState();
}

class _FlutterAnimatedLoginState extends State<FlutterAnimatedLogin> {
  late FlutterAnimatedLoginController _controller;
  bool _ownsController = false;
  LoginStep? _lastStep;

  @override
  void initState() {
    super.initState();
    _attach(widget.controller);
  }

  void _attach(FlutterAnimatedLoginController? external) {
    _ownsController = external == null;
    _controller = external ??
        FlutterAnimatedLoginController(
          initialIdentifier: widget.loginConfig.textFiledConfig.initialValue,
          initialCountryCode:
              widget.loginConfig.textFiledConfig.initialCountryCode ?? 'IN',
          identifierController: widget.loginConfig.textFiledConfig.controller,
          passwordController: widget.loginConfig.passwordConfig.controller,
          otpController: widget.verifyConfig.textFiledConfig.controller,
        );
    if (widget.consent?.initialValue ?? false) {
      _controller.setAcceptedTerms(true);
    }
    _lastStep = _controller.step;
    _controller.addListener(_onControllerChanged);
  }

  void _detach() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onControllerChanged() {
    final step = _controller.step;
    if (step != _lastStep) {
      _lastStep = step;
      widget.onStepChanged?.call(step);
    }
  }

  @override
  void didUpdateWidget(FlutterAnimatedLogin oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Swapping the controller after mount used to be ignored entirely.
    if (oldWidget.controller != widget.controller) {
      _detach();
      _attach(widget.controller);
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final resolved = theme == null
        ? AnimatedLoginTheme.of(context)
        : AnimatedLoginTheme.of(context).merge(theme);

    Widget flow = AnimatedLoginScope(
      controller: _controller,
      child: _AnimatedLoginBody(
        owner: widget,
        controller: _controller,
        loginTheme: resolved,
      ),
    );

    if (theme != null) {
      flow = AnimatedLoginThemeScope(theme: resolved, child: flow);
    }

    if (!widget.handleBackNavigation) return flow;

    // Back used to leave the whole flow from the OTP, signup and reset
    // screens, with no way to return to the login screen but a small link.
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) => PopScope(
        canPop: _controller.step == LoginStep.login,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _controller.goTo(LoginStep.login);
        },
        child: child!,
      ),
      child: flow,
    );
  }
}

class _AnimatedLoginBody extends StatelessWidget {
  const _AnimatedLoginBody({
    required this.owner,
    required this.controller,
    required this.loginTheme,
  });

  final FlutterAnimatedLogin owner;
  final FlutterAnimatedLoginController controller;
  final AnimatedLoginTheme loginTheme;

  @override
  Widget build(BuildContext context) {
    // Subscribe to the controller so a step change rebuilds the switcher.
    AnimatedLoginScope.of(context);

    final screens = <LoginStep, Widget Function()>{
      LoginStep.login: () => _LoginPage(owner: owner, controller: controller),
      LoginStep.verify: () => FlutterAnimatedVerify(
            onVerify: owner.onVerify,
            onResendOtp: owner.onResendOtp,
            config: owner.verifyConfig,
            pageConfig: owner.config,
            formMessages: owner.loginConfig.messages,
            controller: controller,
            termsAndConditions: owner.termsAndConditions,
            providers: owner.providers,
            providerLayout: owner.loginConfig.providerLayout,
            providerSpacing: owner.loginConfig.providerSpacing,
          ),
      LoginStep.signup: () => FlutterAnimatedSignup(
            onSignup: owner.onSignup,
            loginConfig: owner.loginConfig,
            loginType: owner.loginType,
            pageConfig: owner.config,
            config: owner.signupConfig,
            controller: controller,
            consent: owner.consent,
            termsAndConditions: owner.termsAndConditions,
            providers: owner.providers,
          ),
      LoginStep.resetPassword: () => FlutterAnimatedReset(
            onResetPassword: owner.onResetPassword,
            loginConfig: owner.loginConfig,
            loginType: owner.loginType,
            pageConfig: owner.config,
            config: owner.resetConfig,
            controller: controller,
          ),
    };

    return AnimatedStack(
      value: controller.step.index,
      duration: loginTheme.pageTransitionDuration ??
          const Duration(milliseconds: 300),
      switchInCurve: loginTheme.pageTransitionCurve ?? Curves.easeIn,
      switchOutCurve: loginTheme.pageTransitionCurve ?? Curves.easeOut,
      transitionBuilder: loginTheme.pageTransitionBuilder ??
          AnimatedSwitcher.defaultTransitionBuilder,
      // Only the visible screen is built. Before 1.0.0 all four were
      // constructed on every frame and then thrown away.
      builder: (context, value) => screens[LoginStep.values[value]]!(),
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({required this.owner, required this.controller});

  final FlutterAnimatedLogin owner;
  final FlutterAnimatedLoginController controller;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  // Each screen owns its own Form. Before 1.0.0 one GlobalKey wrapped the
  // switcher, so during a page transition two screens' fields lived in the
  // same FormState and validate() ran against the screen being left.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FlutterAnimatedLoginController get controller => widget.controller;
  LoginConfig get config => widget.owner.loginConfig;
  FormMessages get messages => config.messages;

  bool get _usesOtp =>
      widget.owner.loginType == LoginType.otp ||
      (widget.owner.loginType == LoginType.otpAndPassword && controller.useOtp);

  bool get _needsPassword => !_usesOtp;

  Future<String?> _submit() async {
    final consent = widget.owner.consent;
    if ((consent?.isRequired ?? false) && !controller.acceptedTerms) {
      context.error(
        messages.errorTitle,
        description: consent?.errorText ?? messages.consentRequired,
      );
      return null;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      context.error(
        messages.errorTitle,
        description: messages.invalidFormData,
      );
      return null;
    }
    _formKey.currentState?.save();

    final onLogin = widget.owner.onLogin;
    if (onLogin == null) return null;

    controller.setBusy(true);
    try {
      final result = await onLogin(
        LoginData(
          name: controller.identifier,
          secret: _needsPassword ? controller.passwordController.text : null,
          method: _usesOtp ? LoginMethod.otp : LoginMethod.password,
          phoneNumber: controller.isPhone ? controller.phoneNumber : null,
          acceptedTerms: controller.acceptedTerms,
        ),
      );
      if (!mounted) return null;
      if (result.isNotEmptyOrNull) {
        context.error(messages.errorTitle, description: result);
        return result;
      }
      if (_usesOtp) {
        controller.showOtp();
      } else {
        // Signals the platform that the credentials are worth saving; without
        // it the AutofillGroup never prompts.
        TextInput.finishAutofillContext();
        _formKey.currentState?.reset();
        controller.reset();
      }
      return null;
    } finally {
      // Guarded: the host may have navigated away inside onLogin.
      controller.setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AnimatedLoginScope.of(context);
    final owner = widget.owner;
    final consent = owner.consent;
    final gap =
        config.fieldGap ?? AnimatedLoginTheme.of(context).fieldGap ?? 18;

    controller.configure(
      passwordRequired: _needsPassword,
      consentRequired:
          (consent?.isRequired ?? false) && (consent?.showOnLogin ?? false),
    );

    final showSignup = config.showSignupLink ?? (owner.onSignup != null);
    // Supplying onResetPassword is the opt-in, whatever the login type: an
    // app can sign people in with a one-time code and still let them reset a
    // password they use elsewhere. Hide it with showForgotLink: false.
    final showForgot = config.showForgotLink ?? (owner.onResetPassword != null);

    return PageWidget(
      config: owner.config,
      builder: (context, constraints) => Form(
        key: _formKey,
        // Lets the platform password manager offer to save the credentials.
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              config.header ??
                  config.titleWidget ??
                  TitleWidget(
                    title: config.title,
                    subtitle: config.subtitle,
                    child: config.logo,
                  ),
              IdentityField(
                config: config.textFiledConfig,
                controller: controller,
                formMessages: messages,
                loginFieldInputType: config.loginFieldInputType,
                textInputAction: _needsPassword
                    ? TextInputAction.next
                    : TextInputAction.done,
                onSubmitted: _needsPassword ? null : (_) => _submit(),
              ),
              if (_needsPassword) ...[
                SizedBox(height: gap),
                PasswordTextField(
                  config: config.passwordConfig.copyWith(
                    textInputAction: TextInputAction.done,
                  ),
                  controller: controller.passwordController,
                  formMessages: messages,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              if (owner.loginType == LoginType.otpAndPassword)
                LoginMethodToggle(
                  messages: messages,
                  controller: controller,
                  textStyle: config.buttonTextStyle,
                ),
              if (showSignup || showForgot) ...[
                const SizedBox(height: 8),
                SignUpAndForgetButton(
                  messages: messages,
                  controller: controller,
                  showSignup: showSignup,
                  showForgot: showForgot,
                  textStyle: config.buttonTextStyle,
                ),
              ],
              if (consent != null && consent.showOnLogin) ...[
                SizedBox(height: gap / 2),
                ConsentCheckbox(config: consent, controller: controller),
              ],
              SizedBox(height: gap),
              SignInButton(
                onPressed: _submit,
                config: config,
                loginType: owner.loginType,
                controller: controller,
              ),
              OAuthWidget(
                providers: owner.providers,
                termsAndConditions: owner.termsAndConditions,
                footerWidget: config.footer,
                messages: messages,
                controller: controller,
                layout: config.providerLayout,
                spacing: config.providerSpacing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
