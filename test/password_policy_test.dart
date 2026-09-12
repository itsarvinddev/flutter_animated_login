import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const messages = FormMessages.fallback;

  group('PasswordPolicy.none', () {
    test('accepts anything that is not empty', () {
      const policy = PasswordPolicy.none();

      expect(policy.isEmpty, isTrue);
      expect(policy.validate('a'), isNull);
      expect(policy.validate(' '), isNull);
      expect(policy.validate('correct horse battery staple'), isNull);
      expect(policy.violations('a'), isEmpty);
    });

    test('rejects the empty string and null', () {
      const policy = PasswordPolicy.none();

      expect(policy.validate(''), messages.passwordIsRequired);
      expect(policy.validate(null), messages.passwordIsRequired);
    });
  });

  group('violations', () {
    test('minLength has its own message', () {
      const policy = PasswordPolicy(minLength: 8);

      expect(policy.violations('short'), <String>[
        messages.passwordTooShortFor(8),
      ]);
      expect(policy.violations('longenough'), isEmpty);
    });

    test('maxLength has its own message', () {
      const policy = PasswordPolicy(minLength: 0, maxLength: 6);

      expect(policy.violations('1234567'), <String>[
        messages.passwordTooLongFor(6),
      ]);
      expect(policy.violations('123456'), isEmpty);
    });

    test('each character-class rule has its own message', () {
      const policy = PasswordPolicy(
        minLength: 0,
        requireUppercase: true,
        requireLowercase: true,
        requireDigit: true,
        requireSpecial: true,
      );

      expect(policy.violations('ABCD'), <String>[
        messages.passwordNeedsLowercase,
        messages.passwordNeedsDigit,
        messages.passwordNeedsSpecial,
      ]);
      expect(policy.violations('abcd'), <String>[
        messages.passwordNeedsUppercase,
        messages.passwordNeedsDigit,
        messages.passwordNeedsSpecial,
      ]);
      expect(policy.violations('aB1!'), isEmpty);
    });

    test('returns every broken rule, in display order', () {
      const policy = PasswordPolicy(
        minLength: 10,
        requireUppercase: true,
        requireLowercase: true,
        requireDigit: true,
        requireSpecial: true,
      );

      expect(policy.violations('ab'), <String>[
        messages.passwordTooShortFor(10),
        messages.passwordNeedsUppercase,
        messages.passwordNeedsDigit,
        messages.passwordNeedsSpecial,
      ]);
    });

    test('disallow matches a substring, and reports once', () {
      const policy = PasswordPolicy(
        minLength: 0,
        disallow: <Pattern>['acme', 'password'],
      );

      expect(policy.violations('my-acme-login'), <String>[
        messages.passwordNotAllowed,
      ]);
      expect(policy.violations('acme-password'), <String>[
        messages.passwordNotAllowed,
      ]);
      expect(policy.violations('unrelated'), isEmpty);
    });

    test('minStrength rejects a password below the bar', () {
      const policy = PasswordPolicy(
        minLength: 0,
        minStrength: PasswordStrength.good,
      );

      expect(policy.strengthOf('abc'), PasswordStrength.weak);
      expect(policy.violations('abc'), contains(messages.passwordTooWeak));
      expect(policy.violations('Abcdefgh1234'), isEmpty);
    });

    test('uses the messages it is handed', () {
      const policy = PasswordPolicy(minLength: 9, requireDigit: true);
      const german = FormMessages(
        passwordTooShort: 'Mindestens {min} Zeichen',
        passwordNeedsDigit: 'Ziffer fehlt',
      );

      expect(policy.violations('kurz', german), <String>[
        'Mindestens 9 Zeichen',
        'Ziffer fehlt',
      ]);
    });
  });

  group('validate', () {
    test('returns the first violation rather than null', () {
      const policy = PasswordPolicy(minLength: 10, requireDigit: true);

      expect(policy.validate('ab'), messages.passwordTooShortFor(10));
      expect(policy.validate('abcdefghijk'), messages.passwordNeedsDigit);
      expect(policy.validate('abcdefghijk1'), isNull);
    });

    test('reports an empty field before any other rule', () {
      const policy = PasswordPolicy(minLength: 10, requireDigit: true);

      expect(policy.validate(''), messages.passwordIsRequired);
      expect(policy.validate(null), messages.passwordIsRequired);
    });
  });

  group('strengthOf', () {
    const policy = PasswordPolicy.none();

    test('an empty password is empty', () {
      expect(policy.strengthOf(''), PasswordStrength.empty);
    });

    test('two or fewer distinct characters is weak at any length', () {
      expect(policy.strengthOf('aaaa'), PasswordStrength.weak);
      expect(policy.strengthOf('a' * 32), PasswordStrength.weak);
      expect(policy.strengthOf('ab' * 16), PasswordStrength.weak);
    });

    test('a long mixed-class password is strong', () {
      expect(policy.strengthOf('Str0ng!PasswordMix9'), PasswordStrength.strong);
      expect(policy.strengthOf(r'Abcdefgh1234!@#$'), PasswordStrength.strong);
    });

    test('climbs the ladder as length and variety grow', () {
      expect(policy.strengthOf('abcdefgh'), PasswordStrength.weak);
      expect(policy.strengthOf('abcdefg1'), PasswordStrength.fair);
      expect(policy.strengthOf('Abcdefgh1234'), PasswordStrength.good);
      expect(policy.strengthOf(r'Abcdefgh1234!@#$'), PasswordStrength.strong);
    });
  });

  group('PasswordStrength', () {
    test('score is monotonic across the enum', () {
      final scores =
          PasswordStrength.values.map((value) => value.score).toList();

      expect(scores.first, 0);
      expect(scores.last, 1);
      for (var i = 1; i < scores.length; i++) {
        expect(scores[i], greaterThan(scores[i - 1]),
            reason: '${PasswordStrength.values[i]} must outrank '
                '${PasswordStrength.values[i - 1]}');
      }
    });

    test('label is localized, and empty for the empty strength', () {
      expect(PasswordStrength.empty.label(messages), isEmpty);
      expect(PasswordStrength.weak.label(messages), messages.strengthWeak);
      expect(PasswordStrength.fair.label(messages), messages.strengthFair);
      expect(PasswordStrength.good.label(messages), messages.strengthGood);
      expect(PasswordStrength.strong.label(messages), messages.strengthStrong);
    });
  });

  group('FormMessages interpolation', () {
    test('passwordTooShortFor substitutes {min}', () {
      final message = messages.passwordTooShortFor(8);

      expect(message, contains('8'));
      expect(message, isNot(contains('{min}')));
    });

    test('passwordTooLongFor substitutes {max}', () {
      final message = messages.passwordTooLongFor(64);

      expect(message, contains('64'));
      expect(message, isNot(contains('{max}')));
    });
  });

  group('presets and copyWith', () {
    test('standard and strict tighten the default', () {
      const standard = PasswordPolicy.standard();
      expect(standard.minLength, 8);
      expect(standard.requireLowercase, isTrue);
      expect(standard.requireDigit, isTrue);
      expect(standard.isEmpty, isFalse);

      const strict = PasswordPolicy.strict();
      expect(strict.minLength, 12);
      expect(strict.requireUppercase, isTrue);
      expect(strict.requireSpecial, isTrue);
      expect(strict.minStrength, PasswordStrength.good);
      expect(strict.validate('abcdefghijkl'), isNotNull);
      expect(strict.validate(r'Abcdefgh1234!@#$'), isNull);
    });

    test('copyWith replaces only what it is given', () {
      const policy = PasswordPolicy(minLength: 8, requireDigit: true);

      final copy = policy.copyWith(minLength: 12, requireSpecial: true);

      expect(copy.minLength, 12);
      expect(copy.requireDigit, isTrue);
      expect(copy.requireSpecial, isTrue);
      expect(policy.minLength, 8, reason: 'the original is untouched');
      expect(policy.requireSpecial, isFalse);
    });
  });
}
