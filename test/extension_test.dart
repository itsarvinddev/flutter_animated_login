import 'package:flutter_animated_login/src/utils/extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String.isEmail', () {
    test('accepts the addresses the pre-1.0.0 regex rejected', () {
      // The old pattern was r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$', which had no
      // '+' in the local part and capped the TLD at four characters.
      expect('a+b@c.com'.isEmail, isTrue, reason: 'plus addressing');
      expect('x@y.technology'.isEmail, isTrue, reason: 'long TLD');
      expect(
        'user@mail.corp.example.co.uk'.isEmail,
        isTrue,
        reason: 'subdomains',
      );
      expect('bücher@münchen.de'.isEmail, isTrue, reason: 'non-ASCII');
    });

    test('accepts ordinary addresses, with surrounding space', () {
      expect('someone@example.com'.isEmail, isTrue);
      expect('  someone@example.com  '.isEmail, isTrue);
      expect("o'neill@example.com".isEmail, isTrue);
    });

    test('rejects malformed addresses', () {
      expect('no-at-sign.example.com'.isEmail, isFalse, reason: 'no @');
      expect('user@nodot'.isEmail, isFalse, reason: 'no dot in the domain');
      expect('user@example.com.'.isEmail, isFalse, reason: 'trailing dot');
      expect('user@.example.com'.isEmail, isFalse, reason: 'leading dot');
      expect('two names@example.com'.isEmail, isFalse, reason: 'space');
      expect('user@exa mple.com'.isEmail, isFalse, reason: 'space');
      expect('user@@example.com'.isEmail, isFalse);
      expect('@example.com'.isEmail, isFalse);
      expect(''.isEmail, isFalse);
      expect('   '.isEmail, isFalse);
      expect(null.isEmail, isFalse);
    });

    test('rejects an address longer than 254 characters', () {
      const domain = '@example.com';
      final tooLong = '${'a' * 250}$domain';
      expect(tooLong.length, greaterThan(254));
      expect(tooLong.isEmail, isFalse);

      final atTheLimit = '${'a' * (254 - domain.length)}$domain';
      expect(atTheLimit.length, 254);
      expect(atTheLimit.isEmail, isTrue);
    });
  });

  group('String.looksLikePhone', () {
    test('accepts a number that is still being typed', () {
      expect('9'.looksLikePhone, isTrue, reason: 'one digit is enough');
      expect('+91'.looksLikePhone, isTrue);
      expect('+91 98765-43210'.looksLikePhone, isTrue);
      expect('020 7123 4567'.looksLikePhone, isTrue);
      expect('  9876543210  '.looksLikePhone, isTrue, reason: 'trimmed');
    });

    test('accepts a number written with a bracketed area code', () {
      // A pasted UK or US number routinely starts with its area code in
      // brackets. The pattern used to be r'^[+]?[0-9][0-9\s\-().]*$', which
      // demanded a digit before any punctuation, so these fell through to
      // email mode in LoginFieldInputType.phoneOrEmail and then failed email
      // validation. The optional leading '(' is what this guards.
      expect('(020) 7123'.looksLikePhone, isTrue);
      expect('(555) 123-4567'.looksLikePhone, isTrue);
    });

    test('rejects anything that is not a number', () {
      expect('a1'.looksLikePhone, isFalse);
      expect('1a'.looksLikePhone, isFalse);
      expect(''.looksLikePhone, isFalse);
      expect('+'.looksLikePhone, isFalse);
      expect('('.looksLikePhone, isFalse, reason: 'a bracket needs a digit');
      expect('(abc)'.looksLikePhone, isFalse);
      expect('((555'.looksLikePhone, isFalse, reason: 'only one bracket');
      expect('someone@example.com'.looksLikePhone, isFalse);
      expect(null.looksLikePhone, isFalse);
    });
  });

  group('String.isPhoneNumber / String.isIntlPhoneNumber', () {
    test('isPhoneNumber accepts 4 to 15 bare digits', () {
      expect('9876'.isPhoneNumber, isTrue);
      expect('9876543210'.isPhoneNumber, isTrue);
      expect(('9' * 15).isPhoneNumber, isTrue);
      expect('987'.isPhoneNumber, isFalse, reason: 'too short');
      expect(('9' * 16).isPhoneNumber, isFalse, reason: 'too long');
      expect('+919876543210'.isPhoneNumber, isFalse, reason: 'has a +');
      expect('98765 43210'.isPhoneNumber, isFalse, reason: 'has a space');
      expect(''.isPhoneNumber, isFalse);
      expect(null.isPhoneNumber, isFalse);
    });

    test('isIntlPhoneNumber allows a leading +', () {
      expect('+9876'.isIntlPhoneNumber, isTrue);
      expect('+919876543210'.isIntlPhoneNumber, isTrue);
      expect('919876543210'.isIntlPhoneNumber, isTrue);
      expect('  +919876543210  '.isIntlPhoneNumber, isTrue, reason: 'trimmed');
      expect('+987'.isIntlPhoneNumber, isFalse, reason: 'too short');
      expect('+${'9' * 16}'.isIntlPhoneNumber, isFalse, reason: 'too long');
      expect('+91 98765-43210'.isIntlPhoneNumber, isFalse);
      expect(''.isIntlPhoneNumber, isFalse);
      expect(null.isIntlPhoneNumber, isFalse);
    });
  });

  group('String null-safety helpers', () {
    test('isEmptyOrNull, isNotEmptyOrNull, hasContent, orEmpty', () {
      const String? nothing = null;
      expect(nothing.isEmptyOrNull, isTrue);
      expect(''.isEmptyOrNull, isTrue);
      expect(' '.isEmptyOrNull, isFalse);
      expect('x'.isNotEmptyOrNull, isTrue);
      expect('x'.hasContent, isTrue);
      expect(nothing.hasContent, isFalse);
      expect(nothing.orEmpty, '');
      expect('x'.orEmpty, 'x');
    });
  });

  group('int.toDigital', () {
    test('pads a single digit to two', () {
      expect(0.toDigital, '00');
      expect(5.toDigital, '05');
      expect(9.toDigital, '09');
    });

    test('leaves two or more digits alone', () {
      expect(10.toDigital, '10');
      expect(59.toDigital, '59');
      expect(100.toDigital, '100');
    });
  });

  group('List null-safety helpers', () {
    test('isEmptyOrNull and isNotEmptyOrNull', () {
      const List<int>? none = null;
      expect(none.isEmptyOrNull, isTrue);
      expect(<int>[].isEmptyOrNull, isTrue);
      expect(<int>[1].isNotEmptyOrNull, isTrue);
      expect(none.isNotEmptyOrNull, isFalse);
    });
  });
}
