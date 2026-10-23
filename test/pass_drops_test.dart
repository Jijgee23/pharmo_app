import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/application.dart';

void main() {
  group('DriverProvider.passErrorMessage', () {
    test('orders not on the caller\'s delivery, or already delivered', () {
      expect(
        DriverProvider.passErrorMessage({
          'non_field_errors': ['No orders to pass!'],
        }),
        contains('Шилжүүлэх захиалга алга'),
      );
      expect(
        DriverProvider.passErrorMessage({'detail': 'No orders to pass!'}),
        contains('Шилжүүлэх захиалга алга'),
      );
    });

    test('a deliveryman with no active delivery to take them', () {
      expect(
        DriverProvider.passErrorMessage({
          'non_field_errors': ['Target delman has no active delivery!'],
        }),
        'Сонгосон түгээгчид идэвхтэй түгээлт алга.',
      );
    });

    test('anything else comes through as the server put it', () {
      expect(DriverProvider.passErrorMessage({'detail': 'Boom'}), 'Boom');
      expect(DriverProvider.passErrorMessage(const {}), 'Шилжүүлэхэд алдаа гарлаа!');
    });
  });
}
