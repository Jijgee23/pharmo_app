import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/enum/enums.dart';
import 'package:pharmo_app/application/function/validator/varlidator.dart';

void main() {
  group('LoginMethod.of', () {
    test('reads an all-digit identifier as a phone number', () {
      expect(LoginMethod.of('99112233'), LoginMethod.phone);
      expect(LoginMethod.of(' 99112233 '), LoginMethod.phone);
    });

    test('reads anything else, including empty, as an e-mail', () {
      expect(LoginMethod.of('bat@gmail.com'), LoginMethod.email);
      expect(LoginMethod.of(''), LoginMethod.email);
    });

    test('key is the field name the auth endpoints expect', () {
      expect(LoginMethod.email.key, 'email');
      expect(LoginMethod.phone.key, 'phone');
    });
  });

  group('LoginMethod.validate', () {
    test('e-mail: required, format-checked, case and spaces tolerated', () {
      expect(LoginMethod.email.validate(''), 'И-мейл хаягаа оруулна уу');
      expect(LoginMethod.email.validate('bat'), 'Имэйл хаяг буруу байна!');
      expect(LoginMethod.email.validate(' Bat@Gmail.com '), isNull);
    });

    test('phone: required, exactly 8 digits, spaces tolerated', () {
      expect(LoginMethod.phone.validate(null), 'Утасны дугаараа оруулна уу');
      expect(LoginMethod.phone.validate('9911223'), isNotNull);
      expect(LoginMethod.phone.validate('9911a233'), isNotNull);
      expect(LoginMethod.phone.validate(' 99112233 '), isNull);
    });
  });

  test('validatePhone is what the phone method uses', () {
    expect(validatePhone('99112233'), LoginMethod.phone.validate('99112233'));
  });
}
