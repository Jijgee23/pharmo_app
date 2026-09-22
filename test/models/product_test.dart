import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/models/products.dart';

Product _product(String allowedPaytypes) {
  return Product.fromJson({
    'id': 1,
    'expDate': '2027-01-01',
    'discount_expireddate': null,
    'name': 'Test drug',
    'price': 1000.0,
    'itemname_id': null,
    'barcode': null,
    'sale_price': 900.0,
    'sale_qty': null,
    'discount': null,
    'in_stock': true,
    'intName': null,
    'description': null,
    'created_at': null,
    'modified_at': null,
    'mohs': null,
    'supplier': null,
    'mnfr': null,
    'vndr': null,
    'images': null,
    'image': null,
    'qty': 5.0,
    'category': null,
    'allowed_paytypes': allowedPaytypes,
  });
}

void main() {
  group('Product.cashOnly', () {
    test('is true only when allowed_paytypes is exactly "C"', () {
      expect(_product('C').cashOnly, isTrue);
    });

    test('is false for combined pay types', () {
      expect(_product('CL').cashOnly, isFalse);
      expect(_product('CT').cashOnly, isFalse);
      expect(_product('CTL').cashOnly, isFalse);
      expect(_product('L').cashOnly, isFalse);
    });
  });
}
