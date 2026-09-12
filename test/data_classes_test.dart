import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

const PhoneNumber _indianNumber = PhoneNumber(
  countryISOCode: 'IN',
  countryCode: '+91',
  number: '9876543210',
);

const PhoneNumber _britishNumber = PhoneNumber(
  countryISOCode: 'GB',
  countryCode: '+44',
  number: '7911123456',
);

void main() {
  group('LoginData equality', () {
    test('two payloads with the same values are equal', () {
      const a = LoginData(
        name: 'someone@example.com',
        secret: '123456',
        method: LoginMethod.otp,
        acceptedTerms: true,
      );
      const b = LoginData(
        name: 'someone@example.com',
        secret: '123456',
        method: LoginMethod.otp,
        acceptedTerms: true,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a phone number is compared by value, not identity', () {
      final a = LoginData(
        name: '+919876543210',
        phoneNumber: PhoneNumber(
          countryISOCode: 'IN',
          countryCode: '+91',
          number: '9876543210',
        ),
      );
      const b = LoginData(name: '+919876543210', phoneNumber: _indianNumber);

      expect(identical(a.phoneNumber, b.phoneNumber), isFalse);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('any differing field breaks equality', () {
      const base = LoginData(
        name: 'someone@example.com',
        secret: '123456',
        method: LoginMethod.otp,
      );

      expect(base, isNot(base.copyWith(name: 'other@example.com')));
      expect(base, isNot(base.copyWith(secret: '654321')));
      expect(base, isNot(base.copyWith(method: LoginMethod.password)));
      expect(base, isNot(base.copyWith(phoneNumber: _indianNumber)));
      expect(base, isNot(base.copyWith(acceptedTerms: true)));
      expect(base, isNot(const SignupData(name: 'someone@example.com')));
    });
  });

  group('LoginData toString', () {
    test('redacts the secret', () {
      const data = LoginData(
        name: 'someone@example.com',
        secret: 'hunter2',
        method: LoginMethod.password,
      );

      final text = data.toString();

      expect(text, isNot(contains('hunter2')));
      expect(text, contains('***'));
      expect(text, contains('someone@example.com'));
      expect(text, contains('password'));
    });

    test('says null when there is no secret at all', () {
      const data = LoginData(name: 'someone@example.com');

      final text = data.toString();

      expect(text, contains('secret: null'));
      expect(text, isNot(contains('***')));
    });
  });

  group('LoginData copyWith and isPhone', () {
    test('copyWith replaces only what it is given', () {
      const base = LoginData(
        name: 'someone@example.com',
        secret: '123456',
        method: LoginMethod.otp,
        acceptedTerms: true,
      );

      final copy = base.copyWith(
        name: '+919876543210',
        method: LoginMethod.password,
        phoneNumber: _indianNumber,
      );

      expect(copy.name, '+919876543210');
      expect(copy.method, LoginMethod.password);
      expect(copy.phoneNumber, _indianNumber);
      expect(copy.secret, '123456', reason: 'kept');
      expect(copy.acceptedTerms, isTrue, reason: 'kept');
      expect(base.phoneNumber, isNull, reason: 'the original is untouched');
    });

    test('isPhone follows phoneNumber', () {
      const email = LoginData(name: 'someone@example.com');
      const phone = LoginData(
        name: '+919876543210',
        phoneNumber: _indianNumber,
      );

      expect(email.isPhone, isFalse);
      expect(phone.isPhone, isTrue);
    });

    test('the default method is otp', () {
      expect(const LoginData(name: 'x').method, LoginMethod.otp);
    });
  });

  group('SignupData equality', () {
    test('equal but not identical additional maps compare equal', () {
      final a = SignupData(
        name: 'someone@example.com',
        password: 'hunter2',
        additionalSignupData: <String, String>{
          'fullName': 'Ada',
          'company': 'Analytical',
        },
      );
      final b = SignupData(
        name: 'someone@example.com',
        password: 'hunter2',
        additionalSignupData: <String, String>{
          'fullName': 'Ada',
          'company': 'Analytical',
        },
      );

      expect(
        identical(a.additionalSignupData, b.additionalSignupData),
        isFalse,
        reason: 'the maps must be two separate instances',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('two maps built in a different key order hash the same', () {
      final a = SignupData(
        additionalSignupData: <String, String>{'a': '1', 'b': '2', 'c': '3'},
      );
      final b = SignupData(
        additionalSignupData: <String, String>{'c': '3', 'b': '2', 'a': '1'},
      );

      expect(a.additionalSignupData.keys, isNot(b.additionalSignupData.keys));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a differing entry, key or length breaks equality', () {
      final base = SignupData(
        additionalSignupData: <String, String>{'fullName': 'Ada'},
      );

      expect(
        base,
        isNot(
          SignupData(
            additionalSignupData: <String, String>{'fullName': 'Grace'},
          ),
        ),
        reason: 'different value',
      );
      expect(
        base,
        isNot(
          SignupData(additionalSignupData: <String, String>{'name': 'Ada'}),
        ),
        reason: 'different key',
      );
      expect(
        base,
        isNot(
          SignupData(
            additionalSignupData: <String, String>{
              'fullName': 'Ada',
              'company': 'Analytical',
            },
          ),
        ),
        reason: 'different length',
      );
      expect(base, isNot(const SignupData()));
    });

    test('an empty payload equals another empty payload', () {
      expect(const SignupData(), const SignupData());
      expect(const SignupData().hashCode, const SignupData().hashCode);
      expect(const SignupData().additionalSignupData, isEmpty);
    });

    test('the other fields are compared too', () {
      const base = SignupData(
        name: 'someone@example.com',
        password: 'hunter2',
        phoneNumber: _indianNumber,
        acceptedTerms: true,
      );

      expect(base, base.copyWith());
      expect(base, isNot(base.copyWith(name: 'other@example.com')));
      expect(base, isNot(base.copyWith(password: 'hunter3')));
      expect(base, isNot(base.copyWith(phoneNumber: _britishNumber)));
      expect(base, isNot(base.copyWith(acceptedTerms: false)));
    });
  });

  group('SignupData toString', () {
    test('redacts the password', () {
      const data = SignupData(name: 'someone@example.com', password: 'hunter2');

      final text = data.toString();

      expect(text, isNot(contains('hunter2')));
      expect(text, contains('***'));
      expect(text, contains('someone@example.com'));
    });

    test('says null when there is no password', () {
      final text = const SignupData(name: 'someone@example.com').toString();

      expect(text, contains('password: null'));
      expect(text, isNot(contains('***')));
    });
  });

  group('SignupData copyWith, constructors and isPhone', () {
    test('copyWith replaces only what it is given', () {
      final base = SignupData(
        name: 'someone@example.com',
        password: 'hunter2',
        additionalSignupData: <String, String>{'fullName': 'Ada'},
      );

      final copy = base.copyWith(
        password: 'hunter3',
        phoneNumber: _indianNumber,
      );

      expect(copy.name, 'someone@example.com', reason: 'kept');
      expect(copy.password, 'hunter3');
      expect(copy.phoneNumber, _indianNumber);
      expect(copy.additionalSignupData, <String, String>{'fullName': 'Ada'});
      expect(base.phoneNumber, isNull, reason: 'the original is untouched');
    });

    test('isPhone follows phoneNumber', () {
      const email = SignupData(name: 'someone@example.com');
      const phone = SignupData(
        name: '+919876543210',
        phoneNumber: _indianNumber,
      );

      expect(email.isPhone, isFalse);
      expect(phone.isPhone, isTrue);
    });

    test('fromSignupForm and fromProvider fill the right fields', () {
      const fromForm = SignupData.fromSignupForm(
        name: 'someone@example.com',
        password: 'hunter2',
        acceptedTerms: true,
      );
      expect(fromForm.name, 'someone@example.com');
      expect(fromForm.password, 'hunter2');
      expect(fromForm.acceptedTerms, isTrue);
      expect(fromForm.additionalSignupData, isEmpty);
      expect(fromForm.isPhone, isFalse);

      const fromProvider = SignupData.fromProvider(
        additionalSignupData: <String, String>{'providerId': 'google'},
      );
      expect(fromProvider.name, isNull);
      expect(fromProvider.password, isNull);
      expect(fromProvider.phoneNumber, isNull);
      expect(fromProvider.additionalSignupData, <String, String>{
        'providerId': 'google',
      });
    });
  });
}
