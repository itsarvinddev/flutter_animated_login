import 'package:flutter/material.dart';

enum InputType { email, phone, username }

class AdaptiveInputField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final Map<InputType, String Function(String?)>? customValidators;
  final int minUsernameLength;
  final int maxUsernameLength;

  const AdaptiveInputField({
    super.key,
    this.controller,
    this.decoration,
    this.customValidators,
    this.minUsernameLength = 3,
    this.maxUsernameLength = 30,
  });

  @override
  State<AdaptiveInputField> createState() => _AdaptiveInputFieldState();
}

class _AdaptiveInputFieldState extends State<AdaptiveInputField> {
  late TextEditingController _controller;
  InputType _currentInputType = InputType.username;
  bool _showValidationError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_detectInputType);
  }

  @override
  void dispose() {
    _controller.removeListener(_detectInputType);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _detectInputType() {
    final text = _controller.text;
    InputType newType;

    if (text.startsWith('+') && text.length > 1) {
      newType = InputType.phone;
    } else if (text.contains('@')) {
      newType = InputType.email;
    } else {
      newType = InputType.username;
    }

    if (newType != _currentInputType) {
      setState(() => _currentInputType = newType);
    }
  }

  String? _validator(String? value) {
    final customValidator = widget.customValidators?[_currentInputType];
    if (customValidator != null) return customValidator(value);

    switch (_currentInputType) {
      case InputType.email:
        return _validateEmail(value);
      case InputType.phone:
        return _validatePhone(value);
      case InputType.username:
        return _validateUsername(value);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter phone number';
    if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
      return 'Invalid international format (e.g., +1234567890)';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Enter username';
    if (value.length < widget.minUsernameLength ||
        value.length > widget.maxUsernameLength) {
      return 'Username must be ${widget.minUsernameLength}-${widget.maxUsernameLength} characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value)) {
      return 'Allowed: letters, numbers, _ . -';
    }
    return null;
  }

  TextInputType _getKeyboardType() {
    switch (_currentInputType) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.username:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: widget.decoration?.copyWith(
        hintText: _getHintText(),
        prefixIcon: _getPrefixIcon(),
      ),
      keyboardType: _getKeyboardType(),
      validator: _validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => setState(() => _showValidationError = true),
    );
  }

  String? _getHintText() {
    if (widget.decoration?.hintText != null) return widget.decoration?.hintText;
    switch (_currentInputType) {
      case InputType.email:
        return 'example@domain.com';
      case InputType.phone:
        return '+1234567890';
      case InputType.username:
        return 'your_username';
    }
  }

  Widget? _getPrefixIcon() {
    if (widget.decoration?.prefixIcon != null) {
      return widget.decoration?.prefixIcon;
    }
    switch (_currentInputType) {
      case InputType.email:
        return const Icon(Icons.email);
      case InputType.phone:
        return const Icon(Icons.phone);
      case InputType.username:
        return const Icon(Icons.person);
    }
  }
}
