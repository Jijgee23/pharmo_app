import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/database/security.dart';

Security _security(String role) {
  return Security(
    id: 1,
    name: 'test',
    email: 'test@test.com',
    role: role,
    companyName: '',
    access: '',
    refresh: '',
  );
}

void main() {
  group('Security.isDeliveryCapable', () {
    test('true for D (driver)', () {
      expect(_security('D').isDeliveryCapable, isTrue);
    });

    test('true for VS (van sales, the merged S+D role)', () {
      expect(_security('VS').isDeliveryCapable, isTrue);
    });

    test('false for roles that do not do deliveries', () {
      expect(_security('S').isDeliveryCapable, isFalse);
      expect(_security('R').isDeliveryCapable, isFalse);
      expect(_security('PA').isDeliveryCapable, isFalse);
      expect(_security('A').isDeliveryCapable, isFalse);
    });
  });
}
