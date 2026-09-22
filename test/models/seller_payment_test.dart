import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/data/models/seller_payment_settings.dart';
import 'package:pharmo_app/data/models/seller_qpay_invoice.dart';

void main() {
  group('SellerQpayInvoice', () {
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

  group('SellerSubOrder.listFrom', () {
    // Real seller/order/ response body (cash order, single order, no split).
    const response = {
      'id': 2408,
      'orderNo': '125846',
      'totalPrice': 18720.0,
      'totalCount': 5.0,
      'note': null,
      'payType': 'C',
      'split_group': null,
      'orders': [
        {
          'id': 2408,
          'orderNo': '125846',
          'totalPrice': 18720.0,
          'totalCount': 5.0,
          'note': null,
          'payType': 'C',
          'forced': [],
          'requires_payment': true,
          'low_stock': [],
          'qpay': {
            'invoiceId': '5b9e3ef6-9200-4a03-b6df-7b1e9693a3ee',
            'qrTxt': '000201...',
            'shortUrl': 'https://s.qpay.mn/HPulnnmLg1',
            'urls': [
              {
                'name': 'qPay wallet',
                'description': 'qPay хэтэвч',
                'logo': 'https://s3.qpay.mn/p/e9bbdc69/launcher-icon-ios.jpg',
                'link': 'qpaywallet://q?qPay_QRcode=000201...',
              },
            ],
          },
        },
      ],
    };

    test('parses the nested per-order qpay invoice, not a top-level one', () {
      final subOrders = SellerSubOrder.listFrom(response);
      expect(subOrders, hasLength(1));
      final order = subOrders.single;
      expect(order.id, 2408);
      expect(order.requiresPayment, isTrue);
      expect(order.qpay, isNotNull);
      expect(order.qpay!.invoiceId, '5b9e3ef6-9200-4a03-b6df-7b1e9693a3ee');
      expect(order.qpay!.urls, hasLength(1));
    });

    test('a sub-order with requires_payment: false has no qpay', () {
      final subOrders = SellerSubOrder.listFrom({
        'orders': [
          {
            'id': 1,
            'orderNo': '1',
            'totalPrice': 1000.0,
            'totalCount': 1.0,
            'requires_payment': false,
          },
        ],
      });
      expect(subOrders.single.requiresPayment, isFalse);
      expect(subOrders.single.qpay, isNull);
    });

    test('returns an empty list when the response has no orders key', () {
      expect(SellerSubOrder.listFrom({'orderNo': '1'}), isEmpty);
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
