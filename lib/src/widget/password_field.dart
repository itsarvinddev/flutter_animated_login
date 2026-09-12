import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../flutter_animated_login.dart';
import '../utils/extension.dart';

/// A password field with a reveal toggle, an optional policy, an optional
/// strength meter and a caps-lock warning.
class PasswordTextField extends StatefulWidget {
  /// Creates a password field.
  const PasswordTextField({
    super.key,
    required this.formMessages,
    required this.config,
    required this.controller,
    this.onSubmitted,
  });

  /// How the field is configured.
  final PasswordTextFiledConfig config;

  /// Controls the field.
  final TextEditingController controller;

  /// Every user-facing string.
  final FormMessages formMessages;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  // Owned by the State. Before 1.0.0 this notifier was constructed inside
  // build(), so the reveal toggle snapped back to hidden on every rebuild —
  // a window resize, a rotation, or the Android keyboard opening — and leaked
  // a notifier each time.
  late final ValueNotifier<bool> _isObscure =
      ValueNotifier<bool>(widget.config.obscureText);
  bool _capsLockOn = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _isObscure.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PasswordTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    if (!mounted) return;
    final config = widget.config;
    if (config.showStrengthMeter || config.showRequirementChecklist) {
      setState(() {});
    }
  }

  void _syncCapsLock() {
    if (!widget.config.showCapsLockHint) return;
    final on = HardwareKeyboard.instance.lockModesEnabled
        .contains(KeyboardLockMode.capsLock);
    if (on != _capsLockOn && mounted) setState(() => _capsLockOn = on);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final messages = widget.formMessages;
    final theme = Theme.of(context);
    final radius = AnimatedLoginTheme.of(context).fieldRadius ??
        const BorderRadius.all(Radius.circular(16));

    return ValueListenableBuilder<bool>(
      valueListenable: _isObscure,
      builder: (context, obscure, _) {
        final field = TextFormField(
          controller: widget.controller,
          obscureText: obscure,
          focusNode: config.focusNode,
          onChanged: (value) {
            _syncCapsLock();
            config.onChanged?.call(value);
          },
          onTap: config.onTap,
          onEditingComplete: config.onEditingComplete,
          onFieldSubmitted: (value) {
            config.onFieldSubmitted?.call(value);
            widget.onSubmitted?.call(value);
          },
          onSaved: config.onSaved,
          validator: (value) {
            // The policy runs first so a caller-supplied validator composes
            // with it instead of having to re-implement it.
            final policyError = config.policy.isEmpty
                ? (value.isEmptyOrNull ? messages.passwordIsRequired : null)
                : config.policy.validate(value, messages);
            if (policyError != null) return policyError;
            return config.validator?.call(value);
          },
          inputFormatters: config.inputFormatters,
          enabled: config.enabled,
          cursorWidth: config.cursorWidth,
          cursorHeight: config.cursorHeight,
          cursorRadius: config.cursorRadius,
          cursorColor: config.cursorColor,
          cursorErrorColor: config.cursorErrorColor,
          keyboardAppearance: config.keyboardAppearance,
          scrollPadding: config.scrollPadding,
          enableInteractiveSelection: config.enableInteractiveSelection,
          selectionControls: config.selectionControls,
          buildCounter: config.buildCounter,
          scrollPhysics: config.scrollPhysics,
          autofillHints:
              config.autofillHints ?? const <String>[AutofillHints.password],
          autovalidateMode: config.autovalidateMode,
          scrollController: config.scrollController,
          restorationId: config.restorationId,
          decoration: config.decoration?.call(_isObscure) ??
              InputDecoration(
                hintText: messages.enterYourPassword,
                labelText: messages.password,
                border: OutlineInputBorder(borderRadius: radius),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  // Icon-only controls announce nothing useful without these.
                  tooltip:
                      obscure ? messages.showPassword : messages.hidePassword,
                  onPressed: () => _isObscure.value = !obscure,
                ),
              ),
          keyboardType: config.keyboardType,
          textCapitalization: config.textCapitalization,
          textInputAction: config.textInputAction ?? TextInputAction.next,
          style: config.style,
          strutStyle: config.strutStyle,
          textDirection: config.textDirection,
          textAlign: config.textAlign,
          textAlignVertical: config.textAlignVertical,
          autofocus: config.autofocus,
          readOnly: config.readOnly,
          showCursor: config.showCursor,
          obscuringCharacter: config.obscuringCharacter,
          autocorrect: config.autocorrect,
          canRequestFocus: config.canRequestFocus,
          clipBehavior: config.clipBehavior,
          contentInsertionConfiguration: config.contentInsertionConfiguration,
          contextMenuBuilder: config.contextMenuBuilder,
          cursorOpacityAnimates: config.cursorOpacityAnimates,
          dragStartBehavior: config.dragStartBehavior,
          enableIMEPersonalizedLearning: config.enableIMEPersonalizedLearning,
          enableSuggestions: config.enableSuggestions,
          expands: config.expands,
          magnifierConfiguration: config.magnifierConfiguration,
          maxLength: config.maxLength,
          maxLengthEnforcement: config.maxLengthEnforcement,
          maxLines: config.maxLines,
          minLines: config.minLines,
          mouseCursor: config.mouseCursor,
          onAppPrivateCommand: config.onAppPrivateCommand,
          onTapAlwaysCalled: config.onTapAlwaysCalled,
          onTapOutside: config.onTapOutside,
          selectionHeightStyle: config.selectionHeightStyle,
          selectionWidthStyle: config.selectionWidthStyle,
          smartDashesType: config.smartDashesType,
          smartQuotesType: config.smartQuotesType,
          spellCheckConfiguration: config.spellCheckConfiguration,
          statesController: config.statesController,
          stylusHandwritingEnabled: config.stylusHandwritingEnabled,
          undoController: config.undoController,
        );

        final text = widget.controller.text;
        final policy = config.policy;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              // Caps lock is pure Dart via HardwareKeyboard, so this needs no
              // plugin and works on desktop and web.
              canRequestFocus: false,
              onKeyEvent: (_, __) {
                _syncCapsLock();
                return KeyEventResult.ignored;
              },
              child: config.semanticLabel == null
                  ? field
                  : Semantics(
                      textField: true,
                      label: config.semanticLabel,
                      child: field,
                    ),
            ),
            if (config.showCapsLockHint && _capsLockOn)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_capslock,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      messages.capsLockOn,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            if (config.showStrengthMeter)
              config.strengthBuilder?.call(
                    context,
                    policy.strengthOf(text),
                    policy.strengthOf(text).score,
                  ) ??
                  PasswordStrengthMeter(
                    strength: policy.strengthOf(text),
                    messages: messages,
                  ),
            if (config.showRequirementChecklist && !policy.isEmpty)
              PasswordRequirementList(
                unmet: text.isEmpty
                    ? const <String>[]
                    : policy.violations(text, messages),
                satisfiedCount: 0,
              ),
          ],
        );
      },
    );
  }
}
