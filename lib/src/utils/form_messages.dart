import 'package:flutter/foundation.dart';

/// Every user-facing string the package can render.
///
/// The package ships English defaults and takes no localization dependency.
/// Override the strings you need, wherever your app already resolves them:
///
/// ```dart
/// FlutterAnimatedLogin(
///   loginConfig: LoginConfig(
///     messages: FormMessages(
///       signIn: AppLocalizations.of(context).signIn,
///       password: AppLocalizations.of(context).password,
///     ),
///   ),
/// )
/// ```
///
/// Anything omitted keeps its English default, so adding a field here is
/// never a breaking change for callers.
@immutable
class FormMessages {
  // ---------------------------------------------------------------- actions

  /// Title of the signup screen and the label of its submit button.
  final String signUp;

  /// Label of the link that opens the signup screen from the login screen.
  ///
  /// Separate from [signUp] because the screen wants a sentence
  /// ("Create Account") where the link wants a word ("Sign Up").
  final String signUpShort;

  /// Label of the sign-in submit button, and of the link back to the login
  /// screen from the signup and reset screens.
  final String signIn;

  /// Label of the submit button when the login type sends a one-time code
  /// rather than signing in directly.
  final String continueButton;

  /// Label of the link that opens the reset-password screen.
  final String forgotPassword;

  /// Subtitle of the signup screen.
  final String createAccountLong;

  // -------------------------------------------------------------- password

  /// Label of the confirm-password field.
  final String confirmPassword;

  /// Hint of the confirm-password field.
  final String reEnterPassword;

  /// Shown when the two password fields disagree.
  final String passwordsUnmatched;

  /// Shown when a required password field is left empty.
  final String passwordIsRequired;

  /// Hint of the password field.
  final String enterYourPassword;

  /// Label of the password field.
  final String password;

  /// Tooltip of the control that reveals the password.
  final String showPassword;

  /// Tooltip of the control that hides the password again.
  final String hidePassword;

  /// Shown while the keyboard's caps lock is engaged.
  final String capsLockOn;

  /// Shown when a password is shorter than [PasswordPolicy.minLength].
  /// `{min}` is replaced with the required length.
  final String passwordTooShort;

  /// Shown when a password is longer than [PasswordPolicy.maxLength].
  /// `{max}` is replaced with the permitted length.
  final String passwordTooLong;

  /// Shown when [PasswordPolicy.requireUppercase] is unmet.
  final String passwordNeedsUppercase;

  /// Shown when [PasswordPolicy.requireLowercase] is unmet.
  final String passwordNeedsLowercase;

  /// Shown when [PasswordPolicy.requireDigit] is unmet.
  final String passwordNeedsDigit;

  /// Shown when [PasswordPolicy.requireSpecial] is unmet.
  final String passwordNeedsSpecial;

  /// Shown when a password matches one of [PasswordPolicy.disallow].
  final String passwordNotAllowed;

  /// Shown when the password is too weak for [PasswordPolicy.minStrength].
  final String passwordTooWeak;

  /// Label of the strength meter at [PasswordStrength.weak].
  final String strengthWeak;

  /// Label of the strength meter at [PasswordStrength.fair].
  final String strengthFair;

  /// Label of the strength meter at [PasswordStrength.good].
  final String strengthGood;

  /// Label of the strength meter at [PasswordStrength.strong].
  final String strengthStrong;

  // ------------------------------------------------------------- identifier

  /// Hint of the identifier field when it only accepts a phone number.
  final String loginFieldEnterPhone;

  /// Hint of the identifier field when it accepts an email or a phone number.
  final String loginFieldEnterEmailOrPhone;

  /// Hint of the identifier field when it only accepts an email address.
  final String loginFieldEnterEmail;

  /// Label of the identifier field when it only accepts a phone number.
  final String phone;

  /// Label of the identifier field when it accepts either.
  final String emailOrPhone;

  /// Label of the identifier field when it only accepts an email address.
  final String email;

  /// Shown when the identifier field is empty.
  final String loginFieldEnterPhoneValidatorEmpty;

  /// Shown when the identifier field holds neither a valid email nor a valid
  /// phone number.
  final String loginFieldEnterPhoneValidatorInvalid;

  /// Shown when an email-only identifier field holds something that is not an
  /// email address.
  final String invalidEmail;

  /// Shown when a phone-only identifier field holds an invalid number.
  final String invalidPhoneNumber;

  /// Hint of the country picker's search field.
  final String searchCountry;

  // -------------------------------------------------------------------- otp

  /// Label of the button that requests a new one-time code.
  final String resendOTP;

  /// Title of the verify screen when the code was sent to an email address.
  final String otpSentToEmail;

  /// Title of the verify screen when the code was sent to a phone number.
  final String otpSentToPhone;

  /// Accessible label of the one-time-code field.
  final String otpFieldLabel;

  /// Appended to the subtitle of a screen that can return to the login screen.
  ///
  /// Rendered as its own tappable span, so it needs no leading space.
  final String edit;

  /// Shown when the resend limit configured by [VerifyConfig.maxResendAttempts]
  /// is reached.
  final String resendLimitReached;

  // ------------------------------------------------------------------ reset

  /// Title of the reset-password screen.
  final String resetTitle;

  /// Subtitle of the reset-password screen.
  final String resetSubtitle;

  /// Label of the reset-password submit button.
  final String resetButton;

  /// Shown after a reset link is dispatched successfully.
  final String resetLinkSent;

  // ----------------------------------------------------------------- shared

  /// Shown when a form is submitted with fields still invalid.
  final String invalidFormData;

  /// Title of the error notification.
  final String errorTitle;

  /// Title of the success notification.
  final String successTitle;

  /// Separator between the credential form and the social login buttons.
  final String orDivider;

  /// Shown when [ConsentConfig.required] is set and the box is not ticked.
  final String consentRequired;

  /// Label of the control that switches the login screen to one-time codes.
  final String useOtpInstead;

  /// Label of the control that switches the login screen back to a password.
  final String usePasswordInstead;

  /// Creates a set of strings; anything omitted keeps its English default.
  const FormMessages({
    this.signUp = 'Create Account',
    this.signUpShort = 'Sign Up',
    this.signIn = 'Sign In',
    this.continueButton = 'Continue',
    this.forgotPassword = 'Forgot Password?',
    this.createAccountLong = 'Create an account to get started with our app.',
    this.confirmPassword = 'Confirm Password*',
    this.reEnterPassword = 'Re-enter your password',
    this.passwordsUnmatched = 'Password does not match',
    this.passwordIsRequired = 'Password is required',
    this.enterYourPassword = 'Enter your password',
    this.password = 'Password*',
    this.showPassword = 'Show password',
    this.hidePassword = 'Hide password',
    this.capsLockOn = 'Caps lock is on',
    this.passwordTooShort = 'Use at least {min} characters',
    this.passwordTooLong = 'Use at most {max} characters',
    this.passwordNeedsUppercase = 'Add an uppercase letter',
    this.passwordNeedsLowercase = 'Add a lowercase letter',
    this.passwordNeedsDigit = 'Add a number',
    this.passwordNeedsSpecial = 'Add a special character',
    this.passwordNotAllowed = 'This password is not allowed',
    this.passwordTooWeak = 'This password is too weak',
    this.strengthWeak = 'Weak',
    this.strengthFair = 'Fair',
    this.strengthGood = 'Good',
    this.strengthStrong = 'Strong',
    this.loginFieldEnterPhone = 'Enter your phone',
    this.loginFieldEnterEmailOrPhone = 'Enter your email or phone',
    this.loginFieldEnterEmail = 'Enter your email',
    this.phone = 'Phone*',
    this.emailOrPhone = 'Email or Phone*',
    this.email = 'Email*',
    this.loginFieldEnterPhoneValidatorEmpty =
        'Please enter your email or phone number',
    this.loginFieldEnterPhoneValidatorInvalid =
        'Please enter a valid email or phone number',
    this.invalidEmail = 'Please enter a valid email address',
    this.invalidPhoneNumber = 'Please enter a valid phone number',
    this.searchCountry = 'Search country',
    this.resendOTP = 'Resend OTP',
    this.otpSentToEmail = 'Enter OTP sent to your email',
    this.otpSentToPhone = 'Enter OTP sent to your phone',
    this.otpFieldLabel = 'One-time code',
    this.edit = 'Edit',
    this.resendLimitReached = 'No more attempts left, please try again later',
    this.resetTitle = 'Reset Account Password',
    this.resetSubtitle =
        "We'll send you a link to reset your account password.",
    this.resetButton = 'Reset Password',
    this.resetLinkSent = 'Password reset link sent successfully',
    this.invalidFormData = 'Invalid form data, fill all required fields',
    this.errorTitle = 'Error',
    this.successTitle = 'Success',
    this.orDivider = 'OR',
    this.consentRequired = 'Please accept the terms to continue',
    this.useOtpInstead = 'Use a one-time code instead',
    this.usePasswordInstead = 'Use a password instead',
  });

  /// English defaults.
  static const FormMessages fallback = FormMessages();

  /// [passwordTooShort] with `{min}` replaced by [min].
  String passwordTooShortFor(int min) =>
      passwordTooShort.replaceAll('{min}', '$min');

  /// [passwordTooLong] with `{max}` replaced by [max].
  String passwordTooLongFor(int max) =>
      passwordTooLong.replaceAll('{max}', '$max');

  /// A copy of these strings with the given ones replaced.
  FormMessages copyWith({
    String? signUp,
    String? signUpShort,
    String? signIn,
    String? continueButton,
    String? forgotPassword,
    String? createAccountLong,
    String? confirmPassword,
    String? reEnterPassword,
    String? passwordsUnmatched,
    String? passwordIsRequired,
    String? enterYourPassword,
    String? password,
    String? showPassword,
    String? hidePassword,
    String? capsLockOn,
    String? passwordTooShort,
    String? passwordTooLong,
    String? passwordNeedsUppercase,
    String? passwordNeedsLowercase,
    String? passwordNeedsDigit,
    String? passwordNeedsSpecial,
    String? passwordNotAllowed,
    String? passwordTooWeak,
    String? strengthWeak,
    String? strengthFair,
    String? strengthGood,
    String? strengthStrong,
    String? loginFieldEnterPhone,
    String? loginFieldEnterEmailOrPhone,
    String? loginFieldEnterEmail,
    String? phone,
    String? emailOrPhone,
    String? email,
    String? loginFieldEnterPhoneValidatorEmpty,
    String? loginFieldEnterPhoneValidatorInvalid,
    String? invalidEmail,
    String? invalidPhoneNumber,
    String? searchCountry,
    String? resendOTP,
    String? otpSentToEmail,
    String? otpSentToPhone,
    String? otpFieldLabel,
    String? edit,
    String? resendLimitReached,
    String? resetTitle,
    String? resetSubtitle,
    String? resetButton,
    String? resetLinkSent,
    String? invalidFormData,
    String? errorTitle,
    String? successTitle,
    String? orDivider,
    String? consentRequired,
    String? useOtpInstead,
    String? usePasswordInstead,
  }) {
    return FormMessages(
      signUp: signUp ?? this.signUp,
      signUpShort: signUpShort ?? this.signUpShort,
      signIn: signIn ?? this.signIn,
      continueButton: continueButton ?? this.continueButton,
      forgotPassword: forgotPassword ?? this.forgotPassword,
      createAccountLong: createAccountLong ?? this.createAccountLong,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      reEnterPassword: reEnterPassword ?? this.reEnterPassword,
      passwordsUnmatched: passwordsUnmatched ?? this.passwordsUnmatched,
      passwordIsRequired: passwordIsRequired ?? this.passwordIsRequired,
      enterYourPassword: enterYourPassword ?? this.enterYourPassword,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      hidePassword: hidePassword ?? this.hidePassword,
      capsLockOn: capsLockOn ?? this.capsLockOn,
      passwordTooShort: passwordTooShort ?? this.passwordTooShort,
      passwordTooLong: passwordTooLong ?? this.passwordTooLong,
      passwordNeedsUppercase:
          passwordNeedsUppercase ?? this.passwordNeedsUppercase,
      passwordNeedsLowercase:
          passwordNeedsLowercase ?? this.passwordNeedsLowercase,
      passwordNeedsDigit: passwordNeedsDigit ?? this.passwordNeedsDigit,
      passwordNeedsSpecial: passwordNeedsSpecial ?? this.passwordNeedsSpecial,
      passwordNotAllowed: passwordNotAllowed ?? this.passwordNotAllowed,
      passwordTooWeak: passwordTooWeak ?? this.passwordTooWeak,
      strengthWeak: strengthWeak ?? this.strengthWeak,
      strengthFair: strengthFair ?? this.strengthFair,
      strengthGood: strengthGood ?? this.strengthGood,
      strengthStrong: strengthStrong ?? this.strengthStrong,
      loginFieldEnterPhone: loginFieldEnterPhone ?? this.loginFieldEnterPhone,
      loginFieldEnterEmailOrPhone:
          loginFieldEnterEmailOrPhone ?? this.loginFieldEnterEmailOrPhone,
      loginFieldEnterEmail: loginFieldEnterEmail ?? this.loginFieldEnterEmail,
      phone: phone ?? this.phone,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      email: email ?? this.email,
      loginFieldEnterPhoneValidatorEmpty:
          loginFieldEnterPhoneValidatorEmpty ??
          this.loginFieldEnterPhoneValidatorEmpty,
      loginFieldEnterPhoneValidatorInvalid:
          loginFieldEnterPhoneValidatorInvalid ??
          this.loginFieldEnterPhoneValidatorInvalid,
      invalidEmail: invalidEmail ?? this.invalidEmail,
      invalidPhoneNumber: invalidPhoneNumber ?? this.invalidPhoneNumber,
      searchCountry: searchCountry ?? this.searchCountry,
      resendOTP: resendOTP ?? this.resendOTP,
      otpSentToEmail: otpSentToEmail ?? this.otpSentToEmail,
      otpSentToPhone: otpSentToPhone ?? this.otpSentToPhone,
      otpFieldLabel: otpFieldLabel ?? this.otpFieldLabel,
      edit: edit ?? this.edit,
      resendLimitReached: resendLimitReached ?? this.resendLimitReached,
      resetTitle: resetTitle ?? this.resetTitle,
      resetSubtitle: resetSubtitle ?? this.resetSubtitle,
      resetButton: resetButton ?? this.resetButton,
      resetLinkSent: resetLinkSent ?? this.resetLinkSent,
      invalidFormData: invalidFormData ?? this.invalidFormData,
      errorTitle: errorTitle ?? this.errorTitle,
      successTitle: successTitle ?? this.successTitle,
      orDivider: orDivider ?? this.orDivider,
      consentRequired: consentRequired ?? this.consentRequired,
      useOtpInstead: useOtpInstead ?? this.useOtpInstead,
      usePasswordInstead: usePasswordInstead ?? this.usePasswordInstead,
    );
  }
}
