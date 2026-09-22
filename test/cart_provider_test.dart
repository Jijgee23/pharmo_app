import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/models/basket.dart';
import 'package:pharmo_app/views/cart/cart_provider.dart';

Basket _basket(List<CartItemModel> items) {
  return Basket(1, 'b', 'C', 100, 1, null, null, null, items);
}

CartItemModel _item(String allowedPaytypes) {
  return CartItemModel.fromJson({
    'id': 1,
    'product_id': 10,
    'name': 'item',
    'price': 100.0,
    'qty': 1.0,
    'allowed_paytypes': allowedPaytypes,
  });
}

void main() {
  group('CartProvider.isCashOnlyBasket', () {
    test('false when there is no basket', () {
      final cart = CartProvider();
      expect(cart.isCashOnlyBasket, isFalse);
    });

    test('false when the basket is empty', () {
      final cart = CartProvider()..basket = _basket([]);
      expect(cart.isCashOnlyBasket, isFalse);
    });

    test('true only when every item in the basket is cash-only', () {
      final allCash = CartProvider()..basket = _basket([_item('C'), _item('C')]);
      expect(allCash.isCashOnlyBasket, isTrue);

      final mixed = CartProvider()..basket = _basket([_item('C'), _item('CT')]);
      expect(mixed.isCashOnlyBasket, isFalse);

      final noneCash = CartProvider()..basket = _basket([_item('CT'), _item('L')]);
      expect(noneCash.isCashOnlyBasket, isFalse);
    });
  });

  group('CartProvider.basketIsEmpty', () {
    test('true when basket is null, has zero items, or zero total count', () {
      expect((CartProvider()).basketIsEmpty, isTrue);
      expect((CartProvider()..basket = _basket([])).basketIsEmpty, isTrue);

      final zeroCount = Basket(1, 'b', 'C', 0, 0, null, null, null, [_item('C')]);
      expect((CartProvider()..basket = zeroCount).basketIsEmpty, isTrue);
    });

    test('false when the basket has items and a non-zero total count', () {
      final full = Basket(1, 'b', 'C', 100, 1, null, null, null, [_item('C')]);
      expect((CartProvider()..basket = full).basketIsEmpty, isFalse);
    });
  });
}
