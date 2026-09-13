import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

const PhoneNumber _indianNumber = PhoneNumber(
  countryISOCode: 'IN',
  countryCode: '+91',
  number: '9876543210',
);

void main() {
  // The controller asks SchedulerBinding for the current phase before it
  // notifies, so the binding has to exist even for these pure unit tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initial state', () {
    test('a fresh controller starts on LoginStep.login', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      expect(controller.step, LoginStep.login);
      expect(controller.isBusy, isFalse);
      expect(controller.isPhone, isFalse);
      expect(controller.acceptedTerms, isFalse);
      expect(controller.useOtp, isFalse);
      expect(controller.resendAttempts, 0);
      expect(controller.countryIsoCode, 'IN');
      expect(controller.phoneNumber, isNull);
      expect(controller.identifier, '');
      expect(controller.identifierController.text, isEmpty);
      expect(controller.additionalFieldValues, isEmpty);
    });

    test('a second controller does not see the first one\'s state', () {
      final first = FlutterAnimatedLoginController();
      addTearDown(first.dispose);
      first.identifierController.text = 'someone@example.com';
      first.goTo(LoginStep.verify);

      final second = FlutterAnimatedLoginController();
      addTearDown(second.dispose);

      expect(second.step, LoginStep.login);
      expect(second.identifierController.text, isEmpty);
    });

    test('the constructor honours initialStep and initialIdentifier', () {
      final controller = FlutterAnimatedLoginController(
        initialStep: LoginStep.signup,
        initialIdentifier: '9876543210',
        initialCountryCode: 'US',
      );
      addTearDown(controller.dispose);

      expect(controller.step, LoginStep.signup);
      expect(controller.identifierController.text, '9876543210');
      expect(controller.countryIsoCode, 'US');
      expect(controller.isPhone, isTrue);
    });
  });

  group('goTo', () {
    test('moves the step and notifies exactly once per change', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.goTo(LoginStep.signup);
      expect(controller.step, LoginStep.signup);
      expect(notifications, 1);

      controller.goTo(LoginStep.resetPassword);
      expect(controller.step, LoginStep.resetPassword);
      expect(notifications, 2);
    });

    test('does not notify when the step is unchanged', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.goTo(LoginStep.login);
      expect(notifications, 0);

      controller.goTo(LoginStep.verify);
      expect(notifications, 1);
      controller.goTo(LoginStep.verify);
      expect(notifications, 1);
    });

    test('setBusy, setAcceptedTerms and setUseOtp also de-duplicate', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller
        ..setBusy(false)
        ..setAcceptedTerms(false)
        ..setUseOtp(false);
      expect(notifications, 0);

      controller
        ..setBusy(true)
        ..setAcceptedTerms(true)
        ..setUseOtp(true);
      expect(notifications, 3);
      expect(controller.isBusy, isTrue);
      expect(controller.acceptedTerms, isTrue);
      expect(controller.useOtp, isTrue);
    });
  });

  group('showOtp', () {
    test('records the destination, clears the code and zeroes resends', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = 'someone@example.com';
      controller.otpController.text = '123456';
      expect(controller.recordResend(), 1);
      expect(controller.recordResend(), 2);

      controller.showOtp(sentTo: '+919876543210');

      expect(controller.step, LoginStep.verify);
      expect(controller.otpSentTo, '+919876543210');
      expect(controller.otpController.text, isEmpty);
      expect(controller.resendAttempts, 0);
    });

    test('falls back to the identifier when no destination is given', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = '  someone@example.com  ';

      controller.showOtp();

      expect(controller.otpSentTo, 'someone@example.com');
      expect(controller.step, LoginStep.verify);
    });
  });

  group('reset', () {
    test('clearFields: true empties every field and unticks consent', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = '9876543210';
      controller.passwordController.text = 'hunter2';
      controller.confirmPasswordController.text = 'hunter2';
      controller.otpController.text = '123456';
      controller.additionalFieldController('fullName').text = 'Ada';
      controller.setCustomValue('plan', 'pro');
      controller.updatePhoneNumber(_indianNumber);
      controller.setAcceptedTerms(true);
      controller.setBusy(true);
      controller.goTo(LoginStep.verify);
      expect(controller.isPhone, isTrue);

      controller.reset();

      expect(controller.step, LoginStep.login);
      expect(controller.identifierController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
      expect(controller.confirmPasswordController.text, isEmpty);
      expect(controller.otpController.text, isEmpty);
      expect(controller.additionalFieldValues, <String, String>{
        'fullName': '',
      });
      expect(controller.phoneNumber, isNull);
      expect(controller.isPhone, isFalse);
      expect(controller.acceptedTerms, isFalse);
      expect(controller.isBusy, isFalse);
      expect(controller.resendAttempts, 0);
      expect(controller.identifier, '');
    });

    test('clearFields: false moves the step but keeps the text', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = 'someone@example.com';
      controller.passwordController.text = 'hunter2';
      controller.setAcceptedTerms(true);
      controller.goTo(LoginStep.verify);

      controller.reset(clearFields: false);

      expect(controller.step, LoginStep.login);
      expect(controller.identifierController.text, 'someone@example.com');
      expect(controller.passwordController.text, 'hunter2');
      expect(controller.acceptedTerms, isTrue);
    });
  });

  group('prefill', () {
    test('sets the identifier, the country and the password', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.prefill(
        identifier: '+919876543210',
        countryIsoCode: 'US',
        password: 'hunter2',
        additionalFields: const <String, String>{'fullName': 'Ada'},
      );

      expect(controller.identifierController.text, '+919876543210');
      expect(controller.countryIsoCode, 'US');
      expect(controller.passwordController.text, 'hunter2');
      expect(controller.additionalFieldValues['fullName'], 'Ada');
    });

    test('flips isPhone on for a phone string', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.prefill(identifier: '+91 98765-43210');

      expect(controller.isPhone, isTrue);
    });

    test('flips isPhone off for an email string', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.prefill(identifier: '9876543210');
      expect(controller.isPhone, isTrue);

      controller.prefill(identifier: 'someone@example.com');

      expect(controller.isPhone, isFalse);
    });
  });

  group('identifier', () {
    test('is the trimmed email in email mode', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '  someone@example.com  ';

      expect(controller.isPhone, isFalse);
      expect(controller.identifier, 'someone@example.com');
    });

    test('is the E.164 complete number in phone mode', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '98765 43210';
      expect(controller.isPhone, isTrue);
      controller.updatePhoneNumber(_indianNumber);

      expect(controller.identifier, '+919876543210');
      expect(controller.countryIsoCode, 'IN');
    });

    test('is built from the country while the number is still empty', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '98765';
      controller.updatePhoneNumber(
        const PhoneNumber(countryISOCode: 'IN', countryCode: '+91', number: ''),
      );

      expect(controller.isPhone, isTrue);
      // The phone field has not reported a number yet — right after prefill(),
      // say — so E.164 is assembled from the selected country rather than the
      // callback being handed a bare national number.
      expect(controller.identifier, '+9198765');
    });

    test('strips punctuation from text already in E.164 form', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '+91 98765-43210';

      expect(controller.isPhone, isTrue);
      expect(controller.identifier, '+919876543210');
    });

    test('falls back to the typed text when E.164 cannot be built', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '98765';
      controller.updatePhoneNumber(
        const PhoneNumber(countryISOCode: 'ZZ', countryCode: '', number: ''),
      );

      expect(controller.isPhone, isTrue);
      expect(controller.identifier, '98765', reason: 'no such country');
    });
  });

  group('isFormValid', () {
    test('is false while the form is empty', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      expect(controller.isFormValid, isFalse);
    });

    test('is true for a valid email when nothing else is required', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.configure(passwordRequired: false, consentRequired: false);

      controller.identifierController.text = 'someone@example.com';
      expect(controller.isFormValid, isTrue);

      controller.identifierController.text = 'someone@example';
      expect(controller.isFormValid, isFalse);
    });

    test('is false when a password is required and the field is empty', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = 'someone@example.com';
      controller.configure(passwordRequired: true, consentRequired: false);

      expect(controller.isFormValid, isFalse);

      controller.passwordController.text = 'hunter2';
      expect(controller.isFormValid, isTrue);
    });

    test('is false when consent is required and the box is unticked', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);
      controller.identifierController.text = 'someone@example.com';
      controller.configure(passwordRequired: false, consentRequired: true);

      expect(controller.acceptedTerms, isFalse);
      expect(controller.isFormValid, isFalse);

      controller.setAcceptedTerms(true);
      expect(controller.isFormValid, isTrue);
    });

    test('needs a valid phone number in phone mode', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.identifierController.text = '987';
      expect(controller.isPhone, isTrue);
      expect(
        controller.isFormValid,
        isFalse,
        reason: 'no number reported and the raw text is too short',
      );

      // With no PhoneNumber reported yet the raw text is parsed against the
      // selected country (India by default), so a prefilled number does not
      // leave the button disabled until the user touches the field — but a
      // number too short for that country does not pass either. This used to
      // be a bare 4–15 digit shape check, which accepted "98765".
      controller.identifierController.text = '98765';
      expect(controller.isFormValid, isFalse, reason: 'too short for India');

      controller.identifierController.text = '98765 43210';
      expect(controller.isFormValid, isTrue, reason: 'a valid Indian number');

      controller.updatePhoneNumber(
        const PhoneNumber(
          countryISOCode: 'IN',
          countryCode: '+91',
          number: '98765',
        ),
      );
      expect(controller.isFormValid, isFalse, reason: 'too few digits');

      controller.updatePhoneNumber(_indianNumber);
      expect(controller.isFormValid, isTrue);
    });
  });

  group('text controller ownership', () {
    test('disposes the controllers it created itself', () {
      final controller = FlutterAnimatedLoginController();
      final identifier = controller.identifierController as TextFieldController;
      final password = controller.passwordController as TextFieldController;
      final confirm =
          controller.confirmPasswordController as TextFieldController;
      final otp = controller.otpController as TextFieldController;
      expect(identifier.isDisposed, isFalse);

      controller.dispose();

      expect(identifier.isDisposed, isTrue);
      expect(password.isDisposed, isTrue);
      expect(confirm.isDisposed, isTrue);
      expect(otp.isDisposed, isTrue);
    });

    test('never disposes a controller it was handed', () {
      final identifier = TextFieldController();
      final password = TextFieldController();
      final confirm = TextFieldController();
      final otp = TextFieldController();
      final controller = FlutterAnimatedLoginController(
        identifierController: identifier,
        passwordController: password,
        confirmPasswordController: confirm,
        otpController: otp,
      );

      controller.dispose();

      expect(identifier.isDisposed, isFalse);
      expect(password.isDisposed, isFalse);
      expect(confirm.isDisposed, isFalse);
      expect(otp.isDisposed, isFalse);

      // Still usable, because it is still ours.
      identifier.text = 'someone@example.com';
      expect(identifier.text, 'someone@example.com');

      identifier.dispose();
      password.dispose();
      confirm.dispose();
      otp.dispose();
    });

    test('mixes owned and borrowed controllers correctly', () {
      final identifier = TextFieldController();
      final controller = FlutterAnimatedLoginController(
        identifierController: identifier,
      );
      final password = controller.passwordController as TextFieldController;

      controller.dispose();

      expect(identifier.isDisposed, isFalse);
      expect(password.isDisposed, isTrue);
      identifier.dispose();
    });
  });

  group('additional fields', () {
    test('additionalFieldController returns the same instance every time', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      final first = controller.additionalFieldController('fullName');
      final second = controller.additionalFieldController('fullName');

      expect(identical(first, second), isTrue);
      expect(
        controller.additionalFieldController('company'),
        isNot(same(first)),
      );
    });

    test('their text shows up in additionalFieldValues', () {
      final controller = FlutterAnimatedLoginController();
      addTearDown(controller.dispose);

      controller.additionalFieldController('fullName').text = 'Ada';
      controller.additionalFieldController('company').text = 'Analytical';
      controller.setCustomValue('plan', 'pro');

      expect(controller.additionalFieldValues, <String, String>{
        'fullName': 'Ada',
        'company': 'Analytical',
        'plan': 'pro',
      });
    });

    test('all of them are disposed with the controller', () {
      final controller = FlutterAnimatedLoginController();
      final fullName =
          controller.additionalFieldController('fullName')
              as TextFieldController;
      final company =
          controller.additionalFieldController('company')
              as TextFieldController;

      controller.dispose();

      expect(fullName.isDisposed, isTrue);
      expect(company.isDisposed, isTrue);
    });
  });

  group('after dispose', () {
    test('mutators are no-ops instead of throwing', () {
      final controller = FlutterAnimatedLoginController();
      controller.addListener(() {});
      controller.dispose();

      expect(() {
        controller
          ..goTo(LoginStep.signup)
          ..setBusy(true)
          ..setAcceptedTerms(true)
          ..setUseOtp(true)
          ..setCustomValue('plan', 'pro')
          ..setIsPhone(true)
          ..configure(passwordRequired: true, consentRequired: true)
          ..recordResend();
      }, returnsNormally);
    });
  });
}
