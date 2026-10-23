import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/settings/services/taxpayer_lookup.dart';

void main() {
  group('TaxpayerLookup.isRegister', () {
    test('an organisation is 7 digits', () {
      expect(TaxpayerLookup.isRegister('5317878'), isTrue);
      expect(TaxpayerLookup.isRegister('531787'), isFalse);
      expect(TaxpayerLookup.isRegister('53178781'), isFalse);
    });

    test('a citizen is 2 Cyrillic letters and 8 digits, any case', () {
      expect(TaxpayerLookup.isRegister('УБ99112233'), isTrue);
      expect(TaxpayerLookup.isRegister('өү99112233'), isTrue);
      expect(TaxpayerLookup.isRegister('UB99112233'), isFalse);
      expect(TaxpayerLookup.isRegister('УБ9911223'), isFalse);
    });

    test('surrounding spaces are ignored', () {
      expect(TaxpayerLookup.isRegister(' 5317878 '), isTrue);
      expect(TaxpayerLookup.normalize(' аа12345678 '), 'АА12345678');
    });
  });
}
