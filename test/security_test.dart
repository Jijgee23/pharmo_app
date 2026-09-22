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

  group('Security.isTracker', () {
    test('true for S (seller), D (driver) and VS (van sales)', () {
      expect(_security('S').isTracker, isTrue);
      expect(_security('D').isTracker, isTrue);
      expect(_security('VS').isTracker, isTrue);
    });

    test('false for roles without continuous background tracking', () {
      expect(_security('R').isTracker, isFalse);
      expect(_security('PA').isTracker, isFalse);
      expect(_security('A').isTracker, isFalse);
    });
  });
}
