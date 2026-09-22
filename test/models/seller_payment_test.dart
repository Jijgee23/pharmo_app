import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/models/seller_payment_settings.dart';
import 'package:pharmo_app/data/models/seller_qpay_invoice.dart';

void main() {
  group('SellerQpayInvoice', () {
    test('presentIn is true only when invoiceId and qrTxt are both present', () {
      expect(SellerQpayInvoice.presentIn({'invoiceId': 'a', 'qrTxt': 'b'}), isTrue);
      expect(SellerQpayInvoice.presentIn({'orderNo': '123'}), isFalse);
      expect(SellerQpayInvoice.presentIn({'invoiceId': 'a'}), isFalse);
    });

    test('fromJson parses bank urls', () {
      final invoice = SellerQpayInvoice.fromJson({
        'invoiceId': 'a1b2',
        'qrTxt': '00020101...',
        'shortUrl': 'https://s.qpay.mn/q/abc',
        'urls': [
          {
            'name': 'Khan bank',
            'description': 'Хаан банк',
            'logo': 'https://qpay.mn/q/logo/khanbank.png',
            'link': 'khanbank://q?qPay_QRcode=00020101...',
          },
        ],
      });
      expect(invoice.invoiceId, 'a1b2');
      expect(invoice.urls, hasLength(1));
      expect(invoice.urls.first.name, 'Khan bank');
    });
  });

  group('SellerPaymentSettings', () {
    test('fromJson parses bank accounts and flags', () {
      final settings = SellerPaymentSettings.fromJson({
        'supplier_id': 12,
        'supplier_name': 'Эм Импекс ХХК',
        'delv_limit': 150000,
        'bank_accounts': [
          {
            'id': 4,
            'bank_name': 'Хаан банк',
            'account_number': '5001234567',
            'account_holder': 'Эм Импекс ХХК',
            'note': null,
          },
        ],
        'has_qpay': true,
        'can_pay_by_transfer': true,
      });
      expect(settings.supplierId, 12);
      expect(settings.hasQpay, isTrue);
      expect(settings.canPayByTransfer, isTrue);
      expect(settings.bankAccounts, hasLength(1));
      expect(settings.bankAccounts.first.accountNumber, '5001234567');
    });

    test('defaults to an empty bank account list when absent', () {
      final settings = SellerPaymentSettings.fromJson({
        'supplier_id': 12,
        'supplier_name': 'Эм Импекс ХХК',
        'delv_limit': 0,
        'has_qpay': false,
        'can_pay_by_transfer': false,
      });
      expect(settings.bankAccounts, isEmpty);
    });
  });
}
