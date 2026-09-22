import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/models/basket.dart';

CartItemModel _item({String? allowedPaytypes}) {
  return CartItemModel.fromJson({
    'id': 1,
    'product_id': 10,
    'name': 'Пензал',
    'price': 1000.0,
    'qty': 2.0,
    if (allowedPaytypes != null) 'allowed_paytypes': allowedPaytypes,
  });
}

void main() {
  group('CartItemModel.cashOnly', () {
    test('is true only when allowed_paytypes is exactly "C"', () {
      expect(_item(allowedPaytypes: 'C').cashOnly, isTrue);
      expect(_item(allowedPaytypes: 'c').cashOnly, isTrue);
    });

    test('is false for combined pay types or other codes', () {
      expect(_item(allowedPaytypes: 'CL').cashOnly, isFalse);
      expect(_item(allowedPaytypes: 'CT').cashOnly, isFalse);
      expect(_item(allowedPaytypes: 'L').cashOnly, isFalse);
    });

    test('defaults to false when allowed_paytypes is missing from the API response', () {
      expect(_item().cashOnly, isFalse);
    });
  });

  group('Basket.fromJson', () {
    test('parses items and carries cashOnly through', () {
      final basket = Basket.fromJson({
        'id': 5,
        'name': 'basket',
        'payType': 'C',
        'totalPrice': 2000.0,
        'totalCount': 2.0,
        'extra': null,
        'branch': null,
        'supplier': null,
        'items': [
          {
            'id': 1,
            'product_id': 10,
            'name': 'Cash only drug',
            'price': 1000.0,
            'qty': 1.0,
            'allowed_paytypes': 'C',
          },
          {
            'id': 2,
            'product_id': 11,
            'name': 'Any pay type drug',
            'price': 1000.0,
            'qty': 1.0,
            'allowed_paytypes': 'CTL',
          },
        ],
      });

      expect(basket.items, hasLength(2));
      expect(basket.items[0].cashOnly, isTrue);
      expect(basket.items[1].cashOnly, isFalse);
    });
  });
}
