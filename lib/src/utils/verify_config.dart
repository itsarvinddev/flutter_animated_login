import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_animated_login.dart';

/// Everything about the one-time-code screen.
@immutable
class VerifyConfig {
  /// Shown above the title.
  final Widget? logo;

  /// Replaces the whole title block.
  final Widget? header;

  /// Rendered at the very bottom of the screen.
  final Widget? footer;

  /// The screen's title. Defaults to [FormMessages.otpSentToEmail] or
  /// [FormMessages.otpSentToPhone], whichever matches the identifier.
  final String? title;

  /// The screen's subtitle. Defaults to where the code was sent.
  final String? subtitle;

  /// Replaces the generated [TitleWidget].
  final TitleWidget? titleWidget;

  /// The label inside the resend button. Defaults to
  /// [FormMessages.resendOTP].
  final Widget? resendButton;

  /// The style of the resend button's label.
  final TextStyle? buttonTextStyle;

  /// Configures the code field.
  final OtpTextFiledConfig textFiledConfig;

  /// How long the user must wait before another code can be requested.
  ///
  /// Before 1.0.0 this was hardcoded to 60 seconds, which no backend with a
  /// different rate limit could match.
  final Duration resendCooldown;

  /// Whether the countdown starts as soon as the screen opens.
  ///
  /// Set false when your first code is sent by some other route, so the resend
  /// button is available immediately.
  final bool startCooldownOnOpen;

  /// How many times the user may request a new code. `0` means no limit.
  ///
  /// Once reached, the resend button is replaced by
  /// [FormMessages.resendLimitReached].
  final int maxResendAttempts;

  /// Renders the countdown. Receives the time still to wait.
  final Widget Function(BuildContext context, Duration remaining)?
      countdownBuilder;

  /// Called when the countdown reaches zero.
  final VoidCallback? onCooldownFinished;

  /// Whether filling the last cell submits the code automatically.
  final bool autoSubmitOnFill;

  /// Whether to show the social login buttons and terms text on this screen.
  final bool showProviders;

  /// Creates the verify screen's configuration.
  const VerifyConfig({
    this.logo,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.resendButton,
    this.buttonTextStyle,
    this.textFiledConfig = const OtpTextFiledConfig(),
    this.resendCooldown = const Duration(seconds: 60),
    this.startCooldownOnOpen = true,
    this.maxResendAttempts = 0,
    this.countdownBuilder,
    this.onCooldownFinished,
    this.autoSubmitOnFill = true,
    this.showProviders = true,
  });

  /// A copy of this configuration with the given properties replaced.
  VerifyConfig copyWith({
    Widget? logo,
    Widget? header,
    Widget? footer,
    String? title,
    String? subtitle,
    TitleWidget? titleWidget,
    Widget? resendButton,
    TextStyle? buttonTextStyle,
    OtpTextFiledConfig? textFiledConfig,
    Duration? resendCooldown,
    bool? startCooldownOnOpen,
    int? maxResendAttempts,
    Widget Function(BuildContext, Duration)? countdownBuilder,
    VoidCallback? onCooldownFinished,
    bool? autoSubmitOnFill,
    bool? showProviders,
  }) {
    return VerifyConfig(
      logo: logo ?? this.logo,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      titleWidget: titleWidget ?? this.titleWidget,
      resendButton: resendButton ?? this.resendButton,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      textFiledConfig: textFiledConfig ?? this.textFiledConfig,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      startCooldownOnOpen: startCooldownOnOpen ?? this.startCooldownOnOpen,
      maxResendAttempts: maxResendAttempts ?? this.maxResendAttempts,
      countdownBuilder: countdownBuilder ?? this.countdownBuilder,
      onCooldownFinished: onCooldownFinished ?? this.onCooldownFinished,
      autoSubmitOnFill: autoSubmitOnFill ?? this.autoSubmitOnFill,
      showProviders: showProviders ?? this.showProviders,
    );
  }
}

/// Everything about the one-time-code field: the [Pinput] parameters it
/// forwards, plus this package's own callbacks and semantics.
@immutable
class OtpTextFiledConfig {
  /// Theme of the pin in default state
  final PinTheme? defaultPinTheme;

  /// Theme of the pin in focused state
  final PinTheme? focusedPinTheme;

  /// Theme of the pin in submitted state
  final PinTheme? submittedPinTheme;

  /// Theme of the pin in following state
  final PinTheme? followingPinTheme;

  /// Theme of the pin in disabled state
  final PinTheme? disabledPinTheme;

  /// Theme of the pin in error state
  final PinTheme? errorPinTheme;

  /// If true keyboard will be closed
  final bool closeKeyboardWhenCompleted;

  /// Displayed fields count. PIN code length.
  final int? length;

  /// Fires when user completes pin input
  final ValueChanged<LoginData>? onCompleted;

  /// Called every time input value changes.
  final ValueChanged<LoginData>? onChanged;

  /// See [EditableText.onSubmitted]
  final ValueChanged<LoginData>? onSubmitted;

  /// Called when user clicks on PinPut
  final VoidCallback? onTap;

  /// Triggered when a pointer has remained in contact with the Pinput at the
  /// same location for a long period of time.
  final VoidCallback? onLongPress;

  /// Used to get, modify PinPut value and more.
  /// Don't forget to dispose controller
  /// ``` dart
  ///   @override
  ///   void dispose() {
  ///     controller.dispose();
  ///     super.dispose();
  ///   }
  /// ```
  final TextEditingController? controller;

  /// Defines the keyboard focus for this
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  /// Don't forget to dispose focusNode
  /// ``` dart
  ///   @override
  ///   void dispose() {
  ///     focusNode.dispose();
  ///     super.dispose();
  ///   }
  /// ```
  final FocusNode? focusNode;

  /// Widget that is displayed before field submitted.
  final Widget? preFilledWidget;

  /// Builds a Pinput separator
  /// If null SizedBox(width: 8) will be used
  final JustIndexedWidgetBuilder? separatorBuilder;

  /// Defines how [Pinput] fields are being placed inside [Row]
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how [Pinput] and ([errorText] or [errorBuilder]) are being placed inside [Column]
  final CrossAxisAlignment crossAxisAlignment;

  /// Defines how each [Pinput] field are being placed within the container
  final AlignmentGeometry pinContentAlignment;

  /// curve of every [Pinput] Animation
  final Curve animationCurve;

  /// Duration of every [Pinput] Animation
  final Duration? animationDuration;

  /// Animation Type of each [Pinput] field
  /// options:
  /// none, scale, fade, slide, rotation
  final PinAnimationType pinAnimationType;

  /// Begin Offset of ever [Pinput] field when [pinAnimationType] is slide
  final Offset? slideTransitionBeginOffset;

  /// Defines [Pinput] state
  final bool enabled;

  /// See [EditableText.readOnly]
  final bool readOnly;

  /// See [EditableText.autofocus]
  final bool autofocus;

  /// Whether to use Native keyboard or custom one
  /// when flag is set to false [Pinput] wont be focusable anymore
  /// so you should set value of [Pinput]'s [TextFieldController] programmatically
  final bool useNativeKeyboard;

  /// If true, paste button will appear on longPress event
  final bool toolbarEnabled;

  /// Whether show cursor or not
  /// Default cursor '|' or [cursor]
  final bool showCursor;

  /// Whether to enable cursor animation
  final bool isCursorAnimationEnabled;

  /// Whether to enable that the IME update personalized data such as typing history and user dictionary data.
  //
  // This flag only affects Android. On iOS, there is no equivalent flag.
  //
  // Defaults to false. Cannot be null.
  final bool enableIMEPersonalizedLearning;

  /// If [showCursor] true the focused field will show passed Widget
  final Widget? cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// See [EditableText.inputFormatters]
  final List<TextInputFormatter> inputFormatters;

  /// See [EditableText.keyboardType]
  final TextInputType keyboardType;

  /// Provide any symbol to obscure each [Pinput] pin
  /// Recommended ●
  final String obscuringCharacter;

  /// IF [obscureText] is true typed text will be replaced with passed Widget
  final Widget? obscuringWidget;

  /// Whether hide typed pin or not
  final bool obscureText;

  /// See [EditableText.textCapitalization]
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// See [EditableText.autofillHints]
  final Iterable<String>? autofillHints;

  /// See [EditableText.enableSuggestions]
  final bool enableSuggestions;

  /// See [EditableText.selectionControls]
  final TextSelectionControls? selectionControls;

  /// See [TextField.restorationId]
  final String? restorationId;

  /// Fires when clipboard has text of Pinput's length
  final ValueChanged<String>? onClipboardFound;

  /// Use haptic feedback everytime user types on keyboard
  /// See more details in [HapticFeedback]
  final HapticFeedbackType hapticFeedbackType;

  /// See [EditableText.onAppPrivateCommand]
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// See [EditableText.mouseCursor]
  final MouseCursor? mouseCursor;

  /// If true [errorPinTheme] will be applied and [errorText] will be displayed under the Pinput
  final bool forceErrorState;

  /// Text displayed under the Pinput if Pinput is invalid
  final String? errorText;

  /// Style of error text
  final TextStyle? errorTextStyle;

  /// If [Pinput] has error and [errorBuilder] is passed it will be rendered under the Pinput
  final PinputErrorBuilder? errorBuilder;

  /// Return null if pin is valid or any String otherwise
  final FormFieldValidator<String>? validator;

  /// Return null if pin is valid or any String otherwise
  final PinputAutovalidateMode pinputAutovalidateMode;

  /// When this widget receives focus and is not completely visible (for example scrolled partially
  /// off the screen or overlapped by the keyboard)
  /// then it will attempt to make itself visible by scrolling a surrounding [Scrollable], if one is present.
  /// This value controls how far from the edges of a [Scrollable] the TextField will be positioned after the scroll.
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// A callback to be invoked when a tap is detected outside of this [TapRegion]
  /// The [PointerDownEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  /// This is useful if you want to unfocus the [Pinput] when user taps outside of it
  final TapRegionCallback? onTapOutside;

  /// Supplies the code from an SMS listener.
  ///
  /// The package takes no SMS-reading dependency. Add `smart_auth` (or any
  /// other retriever) to your own app and implement pinput's `SmsRetriever`.
  final SmsRetriever? smsRetriever;

  /// Called when a pointer is released outside the field. New in pinput 6.
  final TapRegionUpCallback? onTapUpOutside;

  /// Whether the error shows while the field still has focus. New in pinput 6.
  final bool showErrorWhenFocused;

  /// Whether text in the code cells can be selected.
  ///
  /// pinput 6 turns this on by default; the package keeps it off, which is
  /// what a code field wants.
  final bool? enableInteractiveSelection;

  /// Accessible label announced for the code field. Defaults to
  /// [FormMessages.otpFieldLabel].
  final String? semanticLabel;

  /// Creates the one-time-code field's configuration.
  const OtpTextFiledConfig({
    this.length,
    this.defaultPinTheme,
    this.focusedPinTheme,
    this.submittedPinTheme,
    this.followingPinTheme,
    this.disabledPinTheme,
    this.errorPinTheme,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onTap,
    this.onLongPress,
    this.controller,
    this.focusNode,
    this.preFilledWidget,
    this.separatorBuilder,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.pinContentAlignment = Alignment.center,
    this.animationCurve = Curves.easeIn,
    this.animationDuration,
    this.pinAnimationType = PinAnimationType.scale,
    this.enabled = true,
    this.readOnly = false,
    this.useNativeKeyboard = true,
    this.toolbarEnabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.showCursor = true,
    this.isCursorAnimationEnabled = true,
    this.enableIMEPersonalizedLearning = false,
    this.enableSuggestions = true,
    this.hapticFeedbackType = HapticFeedbackType.disabled,
    this.closeKeyboardWhenCompleted = true,
    this.keyboardType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.slideTransitionBeginOffset,
    this.cursor,
    this.keyboardAppearance,
    this.inputFormatters = const [],
    this.textInputAction,
    this.autofillHints,
    this.obscuringCharacter = '•',
    this.obscuringWidget,
    this.selectionControls,
    this.restorationId,
    this.onClipboardFound,
    this.onAppPrivateCommand,
    this.mouseCursor,
    this.forceErrorState = false,
    this.errorText,
    this.validator,
    this.errorBuilder,
    this.errorTextStyle,
    this.pinputAutovalidateMode = PinputAutovalidateMode.onSubmit,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contextMenuBuilder,
    this.onTapOutside,
    this.smsRetriever,
    this.onTapUpOutside,
    this.showErrorWhenFocused = false,
    this.enableInteractiveSelection = false,
    this.semanticLabel,
  });

  /// A copy of this configuration with the given properties replaced.
  OtpTextFiledConfig copyWith({
    PinTheme? defaultPinTheme,
    PinTheme? focusedPinTheme,
    PinTheme? submittedPinTheme,
    PinTheme? followingPinTheme,
    PinTheme? disabledPinTheme,
    PinTheme? errorPinTheme,
    bool? closeKeyboardWhenCompleted,
    int? length,
    ValueChanged<LoginData>? onCompleted,
    ValueChanged<LoginData>? onChanged,
    ValueChanged<LoginData>? onSubmitted,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    TextEditingController? controller,
    FocusNode? focusNode,
    Widget? preFilledWidget,
    JustIndexedWidgetBuilder? separatorBuilder,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    AlignmentGeometry? pinContentAlignment,
    Curve? animationCurve,
    Duration? animationDuration,
    PinAnimationType? pinAnimationType,
    Offset? slideTransitionBeginOffset,
    bool? enabled,
    bool? readOnly,
    bool? autofocus,
    bool? useNativeKeyboard,
    bool? toolbarEnabled,
    bool? showCursor,
    bool? isCursorAnimationEnabled,
    bool? enableIMEPersonalizedLearning,
    Widget? cursor,
    Brightness? keyboardAppearance,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    String? obscuringCharacter,
    Widget? obscuringWidget,
    bool? obscureText,
    TextCapitalization? textCapitalization,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool? enableSuggestions,
    TextSelectionControls? selectionControls,
    String? restorationId,
    ValueChanged<String>? onClipboardFound,
    HapticFeedbackType? hapticFeedbackType,
    AppPrivateCommandCallback? onAppPrivateCommand,
    MouseCursor? mouseCursor,
    bool? forceErrorState,
    String? errorText,
    TextStyle? errorTextStyle,
    PinputErrorBuilder? errorBuilder,
    FormFieldValidator<String>? validator,
    PinputAutovalidateMode? pinputAutovalidateMode,
    EdgeInsets? scrollPadding,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    TapRegionCallback? onTapOutside,
    SmsRetriever? smsRetriever,
    TapRegionUpCallback? onTapUpOutside,
    bool? showErrorWhenFocused,
    bool? enableInteractiveSelection,
    String? semanticLabel,
  }) {
    return OtpTextFiledConfig(
      defaultPinTheme: defaultPinTheme ?? this.defaultPinTheme,
      focusedPinTheme: focusedPinTheme ?? this.focusedPinTheme,
      submittedPinTheme: submittedPinTheme ?? this.submittedPinTheme,
      followingPinTheme: followingPinTheme ?? this.followingPinTheme,
      disabledPinTheme: disabledPinTheme ?? this.disabledPinTheme,
      errorPinTheme: errorPinTheme ?? this.errorPinTheme,
      closeKeyboardWhenCompleted:
          closeKeyboardWhenCompleted ?? this.closeKeyboardWhenCompleted,
      length: length ?? this.length,
      onCompleted: onCompleted ?? this.onCompleted,
      onChanged: onChanged ?? this.onChanged,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      controller: controller ?? this.controller,
      focusNode: focusNode ?? this.focusNode,
      preFilledWidget: preFilledWidget ?? this.preFilledWidget,
      separatorBuilder: separatorBuilder ?? this.separatorBuilder,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      pinContentAlignment: pinContentAlignment ?? this.pinContentAlignment,
      animationCurve: animationCurve ?? this.animationCurve,
      animationDuration: animationDuration ?? this.animationDuration,
      pinAnimationType: pinAnimationType ?? this.pinAnimationType,
      slideTransitionBeginOffset:
          slideTransitionBeginOffset ?? this.slideTransitionBeginOffset,
      enabled: enabled ?? this.enabled,
      readOnly: readOnly ?? this.readOnly,
      autofocus: autofocus ?? this.autofocus,
      useNativeKeyboard: useNativeKeyboard ?? this.useNativeKeyboard,
      toolbarEnabled: toolbarEnabled ?? this.toolbarEnabled,
      showCursor: showCursor ?? this.showCursor,
      isCursorAnimationEnabled:
          isCursorAnimationEnabled ?? this.isCursorAnimationEnabled,
      enableIMEPersonalizedLearning:
          enableIMEPersonalizedLearning ?? this.enableIMEPersonalizedLearning,
      cursor: cursor ?? this.cursor,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      keyboardType: keyboardType ?? this.keyboardType,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      obscuringWidget: obscuringWidget ?? this.obscuringWidget,
      obscureText: obscureText ?? this.obscureText,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      autofillHints: autofillHints ?? this.autofillHints,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      selectionControls: selectionControls ?? this.selectionControls,
      restorationId: restorationId ?? this.restorationId,
      onClipboardFound: onClipboardFound ?? this.onClipboardFound,
      hapticFeedbackType: hapticFeedbackType ?? this.hapticFeedbackType,
      onAppPrivateCommand: onAppPrivateCommand ?? this.onAppPrivateCommand,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      forceErrorState: forceErrorState ?? this.forceErrorState,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      validator: validator ?? this.validator,
      pinputAutovalidateMode:
          pinputAutovalidateMode ?? this.pinputAutovalidateMode,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      contextMenuBuilder: contextMenuBuilder ?? this.contextMenuBuilder,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      smsRetriever: smsRetriever ?? this.smsRetriever,
      onTapUpOutside: onTapUpOutside ?? this.onTapUpOutside,
      showErrorWhenFocused: showErrorWhenFocused ?? this.showErrorWhenFocused,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }
}

/// Correctly spelled alias for [OtpTextFiledConfig], which configures
/// the one-time-code field.
///
/// The original name carries a typo ("TextFiled"). Both names work and mean
/// the same class; prefer this one. The misspelling will be deprecated in
/// 2.0.0 and removed in 3.0.0.
typedef OtpTextFieldConfig = OtpTextFiledConfig;
