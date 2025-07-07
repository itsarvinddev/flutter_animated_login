// File: src/controllers/form_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/validation.dart';

/// Provider for login form controller
final loginFormProvider = Provider.autoDispose((ref) => FormController());

/// Provider for signup form controller
final signupFormProvider = Provider.autoDispose((ref) => FormController());

/// Provider for reset form controller
final resetFormProvider = Provider.autoDispose((ref) => FormController());

/// Provider for verify form controller
final verifyFormProvider = Provider.autoDispose((ref) => FormController());

/// Form controller for managing form state and validation
class FormController {
  /// Form key for validation
  final formKey = GlobalKey<FormState>();

  /// Email controller
  final emailController = TextEditingController();

  /// Password controller
  final passwordController = TextEditingController();

  /// Confirm password controller
  final confirmPasswordController = TextEditingController();

  /// OTP controller
  final otpController = TextEditingController();

  /// Phone controller
  final phoneController = TextEditingController();

  /// Remember me state
  final rememberMe = ValueNotifier<bool>(false);

  /// Obscure password state
  final obscurePassword = ValueNotifier<bool>(true);

  /// Obscure confirm password state
  final obscureConfirmPassword = ValueNotifier<bool>(true);

  /// Dispose resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    phoneController.dispose();
    rememberMe.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
  }

  /// Reset all fields
  void resetFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    phoneController.clear();
    rememberMe.value = false;
  }

  /// Validate email
  String? validateEmail(String? value, {bool required = true}) {
    return ValidationUtils.validateEmail(value, required: required);
  }

  /// Validate password
  String? validatePassword(String? value, {bool required = true}) {
    return ValidationUtils.validatePassword(value, required: required);
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value, {bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate OTP
  String? validateOtp(String? value, {int length = 6, bool required = true}) {
    return ValidationUtils.validateOtp(value,
        length: length, required: required);
  }

  /// Validate phone
  String? validatePhone(String? value, {bool required = true}) {
    return ValidationUtils.validatePhone(value, required: required);
  }

  /// Validate the form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
