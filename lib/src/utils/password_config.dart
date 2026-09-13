import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_animated_login.dart';

/// Everything about a password field: the Material [TextFormField]
/// parameters it forwards, plus the policy, strength meter and caps-lock hint
/// this package adds on top.
@immutable
class PasswordTextFiledConfig {
  /// Controls the field.
  ///
  /// A controller you pass here is never disposed by the package.
  final TextEditingController? controller;

  /// Defines the keyboard focus for this field.
  final FocusNode? focusNode;

  /// Builds the field's decoration.
  ///
  /// Receives the notifier holding the obscure state, so a custom suffix icon
  /// can toggle it: `onPressed: () => isObscure.value = !isObscure.value`.
  final InputDecoration? Function(ValueNotifier<bool> isObscure)? decoration;

  /// Which keyboard to show.
  final TextInputType? keyboardType;

  /// How to capitalize typed text.
  final TextCapitalization textCapitalization;

  /// Which action key the keyboard shows.
  final TextInputAction? textInputAction;

  /// The style of the typed text.
  final TextStyle? style;

  /// The strut applied to the typed text.
  final StrutStyle? strutStyle;

  /// The reading direction of the typed text.
  final TextDirection? textDirection;

  /// How the text is aligned horizontally.
  final TextAlign textAlign;

  /// How the text is aligned vertically.
  final TextAlignVertical? textAlignVertical;

  /// Whether the field takes focus when its screen opens.
  final bool autofocus;

  /// Whether the field rejects input while still showing its value.
  final bool readOnly;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// The character drawn in place of each hidden one.
  final String obscuringCharacter;

  /// Whether the field starts with its text hidden.
  final bool obscureText;

  /// Whether to autocorrect the typed text.
  final bool autocorrect;

  /// Whether typed dashes become en and em dashes.
  final SmartDashesType? smartDashesType;

  /// Whether typed quotes become curly quotes.
  final SmartQuotesType? smartQuotesType;

  /// Whether the keyboard offers suggestions.
  final bool enableSuggestions;

  /// What happens when [maxLength] is exceeded.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Most lines shown before the field scrolls.
  final int? maxLines;

  /// Fewest lines the field occupies.
  final int? minLines;

  /// Whether the field expands to fill its parent.
  final bool expands;

  /// Most characters accepted.
  final int? maxLength;

  /// Called on every keystroke.
  final void Function(String)? onChanged;

  /// Called when the field is tapped.
  final void Function()? onTap;

  /// Whether [onTap] fires even when the field already has focus.
  final bool onTapAlwaysCalled;

  /// Called when a pointer goes down outside the field.
  final void Function(PointerDownEvent)? onTapOutside;

  /// Called when the user finishes editing.
  final void Function()? onEditingComplete;

  /// Called when the user submits from the keyboard.
  final void Function(String)? onFieldSubmitted;

  /// Called when the enclosing [Form] is saved.
  final void Function(String?)? onSaved;

  /// Extra validation, run after [policy] passes.
  ///
  /// It composes with the policy rather than replacing it, so you do not have
  /// to re-implement the empty check or the localized messages.
  final String? Function(String?)? validator;

  /// Restricts or reformats what can be typed.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field accepts input.
  final bool? enabled;

  /// How thick the cursor is.
  final double cursorWidth;

  /// How tall the cursor is.
  final double? cursorHeight;

  /// How rounded the cursor's corners are.
  final Radius? cursorRadius;

  /// The colour of the cursor.
  final Color? cursorColor;

  /// The colour of the cursor while the field shows an error.
  final Color? cursorErrorColor;

  /// The appearance of the keyboard. iOS only.
  final Brightness? keyboardAppearance;

  /// How far from a scrollable edge the focused field settles.
  final EdgeInsets scrollPadding;

  /// Whether the typed text can be selected.
  final bool? enableInteractiveSelection;

  /// Builds the selection handles and toolbar.
  final TextSelectionControls? selectionControls;

  /// Builds the character counter.
  final Widget? Function(
    BuildContext, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  })?
  buildCounter;

  /// Scroll physics for the field.
  final ScrollPhysics? scrollPhysics;

  /// Autofill categories this field belongs to.
  final Iterable<String>? autofillHints;

  /// When validation errors appear.
  final AutovalidateMode? autovalidateMode;

  /// Controls the field's own scroll position.
  final ScrollController? scrollController;

  /// Identifier for state restoration.
  final String? restorationId;

  /// Whether the IME may learn from what is typed. Android only.
  final bool enableIMEPersonalizedLearning;

  /// The cursor shown when a pointer hovers the field.
  final MouseCursor? mouseCursor;

  /// Builds the text selection context menu.
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;

  /// Configures spell checking.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// Configures the text magnifier.
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Controls the field's undo history.
  final UndoHistoryController? undoController;

  /// Receives platform-private input commands.
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;

  /// Whether the cursor fades in and out rather than blinking.
  final bool? cursorOpacityAnimates;

  /// How tall the selection highlight is drawn.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// How wide the selection highlight is drawn.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// When a drag gesture is recognised.
  final DragStartBehavior dragStartBehavior;

  /// Configures rich content insertion, such as pasted images.
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// Reports and drives the field's widget states.
  final WidgetStatesController? statesController;

  /// How the field clips its content.
  final Clip clipBehavior;

  /// Whether stylus handwriting input is accepted.
  final bool stylusHandwritingEnabled;

  /// Whether stylus handwriting input is accepted.
  @Deprecated(
    'Renamed to stylusHandwritingEnabled, matching Flutter 3.29. '
    'Removed in 2.0.0.',
  )
  bool get scribbleEnabled => stylusHandwritingEnabled;

  /// Whether the field may take focus at all.
  final bool canRequestFocus;

  /// Rules the password must satisfy.
  ///
  /// Defaults to [PasswordPolicy.none], which only requires a non-empty
  /// value — exactly what every version before 1.0.0 did. Opt in with
  /// [PasswordPolicy.standard] or [PasswordPolicy.strict], or build your own.
  ///
  /// The policy runs *before* [validator], so your own rule composes with it
  /// rather than replacing it.
  final PasswordPolicy policy;

  /// Whether to show a strength bar under the field.
  final bool showStrengthMeter;

  /// Replaces the built-in strength bar.
  final Widget Function(
    BuildContext context,
    PasswordStrength strength,
    double score,
  )?
  strengthBuilder;

  /// Whether to warn the user while caps lock is on.
  ///
  /// Detected from [HardwareKeyboard], so it needs no plugin and works on
  /// every desktop and web target.
  final bool showCapsLockHint;

  /// Whether to list the policy's unmet requirements under the field as the
  /// user types.
  final bool showRequirementChecklist;

  /// Accessible label announced for the field.
  final String? semanticLabel;

  /// Creates the password field's configuration.
  const PasswordTextFiledConfig({
    this.policy = const PasswordPolicy.none(),
    this.showStrengthMeter = false,
    this.strengthBuilder,
    this.showCapsLockHint = true,
    this.showRequirementChecklist = false,
    this.semanticLabel,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = true,
    this.autocorrect = false,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.dragStartBehavior = DragStartBehavior.start,
    this.contentInsertionConfiguration,
    this.statesController,
    this.clipBehavior = Clip.hardEdge,
    bool stylusHandwritingEnabled = true,
    @Deprecated(
      'Renamed to stylusHandwritingEnabled, matching Flutter 3.29. '
      'Removed in 2.0.0.',
    )
    bool? scribbleEnabled,
    this.canRequestFocus = true,
  }) : stylusHandwritingEnabled = scribbleEnabled ?? stylusHandwritingEnabled;

  /// A copy of this configuration with the given properties replaced.
  PasswordTextFiledConfig copyWith({
    PasswordPolicy? policy,
    bool? showStrengthMeter,
    Widget Function(BuildContext, PasswordStrength, double)? strengthBuilder,
    bool? showCapsLockHint,
    bool? showRequirementChecklist,
    String? semanticLabel,
    TextEditingController? controller,
    FocusNode? focusNode,
    InputDecoration? Function(ValueNotifier<bool> isObscure)? decoration,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign? textAlign,
    TextAlignVertical? textAlignVertical,
    bool? autofocus,
    bool? readOnly,
    bool? showCursor,
    String? obscuringCharacter,
    bool? obscureText,
    bool? autocorrect,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool? enableSuggestions,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines,
    int? minLines,
    bool? expands,
    int? maxLength,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool? onTapAlwaysCalled,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onEditingComplete,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double? cursorWidth,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Color? cursorErrorColor,
    Brightness? keyboardAppearance,
    EdgeInsets? scrollPadding,
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    Widget? Function(
      BuildContext, {
      required int currentLength,
      required bool isFocused,
      required int? maxLength,
    })?
    buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    String? restorationId,
    bool? enableIMEPersonalizedLearning,
    MouseCursor? mouseCursor,
    Widget Function(BuildContext, EditableTextState)? contextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
    UndoHistoryController? undoController,
    void Function(String, Map<String, dynamic>)? onAppPrivateCommand,
    bool? cursorOpacityAnimates,
    ui.BoxHeightStyle? selectionHeightStyle,
    ui.BoxWidthStyle? selectionWidthStyle,
    DragStartBehavior? dragStartBehavior,
    ContentInsertionConfiguration? contentInsertionConfiguration,
    WidgetStatesController? statesController,
    Clip? clipBehavior,
    bool? stylusHandwritingEnabled,
    @Deprecated('Use stylusHandwritingEnabled. Removed in 2.0.0.')
    bool? scribbleEnabled,
    bool? canRequestFocus,
  }) {
    return PasswordTextFiledConfig(
      policy: policy ?? this.policy,
      showStrengthMeter: showStrengthMeter ?? this.showStrengthMeter,
      strengthBuilder: strengthBuilder ?? this.strengthBuilder,
      showCapsLockHint: showCapsLockHint ?? this.showCapsLockHint,
      showRequirementChecklist:
          showRequirementChecklist ?? this.showRequirementChecklist,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      controller: controller ?? this.controller,
      focusNode: focusNode ?? this.focusNode,
      decoration: decoration ?? this.decoration,
      keyboardType: keyboardType ?? this.keyboardType,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      style: style ?? this.style,
      strutStyle: strutStyle ?? this.strutStyle,
      textDirection: textDirection ?? this.textDirection,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      autofocus: autofocus ?? this.autofocus,
      readOnly: readOnly ?? this.readOnly,
      showCursor: showCursor ?? this.showCursor,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      obscureText: obscureText ?? this.obscureText,
      autocorrect: autocorrect ?? this.autocorrect,
      smartDashesType: smartDashesType ?? this.smartDashesType,
      smartQuotesType: smartQuotesType ?? this.smartQuotesType,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      expands: expands ?? this.expands,
      maxLength: maxLength ?? this.maxLength,
      onChanged: onChanged ?? this.onChanged,
      onTap: onTap ?? this.onTap,
      onTapAlwaysCalled: onTapAlwaysCalled ?? this.onTapAlwaysCalled,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onFieldSubmitted: onFieldSubmitted ?? this.onFieldSubmitted,
      onSaved: onSaved ?? this.onSaved,
      validator: validator ?? this.validator,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      enabled: enabled ?? this.enabled,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      selectionControls: selectionControls ?? this.selectionControls,
      buildCounter: buildCounter ?? this.buildCounter,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      autofillHints: autofillHints ?? this.autofillHints,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      scrollController: scrollController ?? this.scrollController,
      restorationId: restorationId ?? this.restorationId,
      enableIMEPersonalizedLearning:
          enableIMEPersonalizedLearning ?? this.enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      contextMenuBuilder: contextMenuBuilder ?? this.contextMenuBuilder,
      spellCheckConfiguration:
          spellCheckConfiguration ?? this.spellCheckConfiguration,
      magnifierConfiguration:
          magnifierConfiguration ?? this.magnifierConfiguration,
      undoController: undoController ?? this.undoController,
      onAppPrivateCommand: onAppPrivateCommand ?? this.onAppPrivateCommand,
      cursorOpacityAnimates:
          cursorOpacityAnimates ?? this.cursorOpacityAnimates,
      selectionHeightStyle: selectionHeightStyle ?? this.selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle ?? this.selectionWidthStyle,
      dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
      contentInsertionConfiguration:
          contentInsertionConfiguration ?? this.contentInsertionConfiguration,
      statesController: statesController ?? this.statesController,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      stylusHandwritingEnabled:
          stylusHandwritingEnabled ??
          scribbleEnabled ??
          this.stylusHandwritingEnabled,
      canRequestFocus: canRequestFocus ?? this.canRequestFocus,
    );
  }
}

/// Correctly spelled alias for [PasswordTextFiledConfig], which configures
/// the password field.
///
/// The original name carries a typo ("TextFiled"). Both names work and mean
/// the same class; prefer this one. The misspelling will be deprecated in
/// 2.0.0 and removed in 3.0.0.
typedef PasswordTextFieldConfig = PasswordTextFiledConfig;
