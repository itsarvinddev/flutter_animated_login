// File: src/widgets/fields/pin_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/defaults.dart';
import '../../theme/auth_theme_extension.dart';

/// A pin code input field for OTP verification
class PinInput extends StatefulWidget {
  /// Pin code length
  final int length;

  /// Text controller
  final TextEditingController controller;

  /// Field validator
  final FormFieldValidator<String>? validator;

  /// On complete callback
  final ValueChanged<String>? onCompleted;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  /// Pin field height
  final double fieldHeight;

  /// Pin field width
  final double fieldWidth;

  /// Pin box decoration
  final BoxDecoration? boxDecoration;

  /// Pin selected box decoration
  final BoxDecoration? selectedBoxDecoration;

  /// Pin text style
  final TextStyle? textStyle;

  /// Auto validation mode
  final AutovalidateMode? autovalidateMode;

  const PinInput({
    super.key,
    this.length = 6,
    required this.controller,
    this.validator,
    this.onCompleted,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.fieldHeight = 50,
    this.fieldWidth = 50,
    this.boxDecoration,
    this.selectedBoxDecoration,
    this.textStyle,
    this.autovalidateMode,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller;

    _controller.addListener(_controllerListener);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {});
    }

    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }

    if (_controller.text.length == widget.length &&
        widget.onCompleted != null) {
      widget.onCompleted!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get our theme extension
    final authTheme = Theme.of(context).extension<AuthThemeExtension>() ??
        AuthThemeExtension.defaults(context);

    // Default box decoration
    final defaultBoxDecoration = BoxDecoration(
      color: authTheme.otpFieldBackgroundColor,
      border: Border.all(color: authTheme.otpFieldBorderColor),
      borderRadius: BorderRadius.circular(Defaults.fieldBorderRadius),
    );

    // Default selected box decoration
    final defaultSelectedBoxDecoration = BoxDecoration(
      color: authTheme.otpFieldBackgroundColor,
      border: Border.all(color: authTheme.otpFieldActiveColor, width: 2),
      borderRadius: BorderRadius.circular(Defaults.fieldBorderRadius),
    );

    // Default text style
    final defaultTextStyle = TextStyle(
      color: authTheme.otpFieldTextColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    final effectiveBoxDecoration = widget.boxDecoration ?? defaultBoxDecoration;
    final effectiveSelectedBoxDecoration =
        widget.selectedBoxDecoration ?? defaultSelectedBoxDecoration;
    final effectiveTextStyle = widget.textStyle ?? defaultTextStyle;

    return FormField<String>(
      initialValue: _controller.text,
      validator: widget.validator,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (fieldState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Invisible text field for input
                  Opacity(
                    opacity: 0,
                    child: TextFormField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(widget.length),
                      ],
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                  ),

                  // Visible pin boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.length, (index) {
                      final isFilled = index < _controller.text.length;
                      final isCurrentFocus = index == _controller.text.length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: widget.fieldWidth,
                          height: widget.fieldHeight,
                          decoration: isCurrentFocus && _focusNode.hasFocus
                              ? effectiveSelectedBoxDecoration
                              : effectiveBoxDecoration,
                          alignment: Alignment.center,
                          child: isFilled
                              ? Text(
                                  _controller.text[index],
                                  style: effectiveTextStyle,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Error message
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: authTheme.textFieldErrorColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
