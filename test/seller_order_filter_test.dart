import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/enum/enums.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_filter.dart';

void main() {
  group('SellerOrderFilter.toQuery', () {
    test('sends nothing by default', () {
      expect(const SellerOrderFilter().toQuery(), isEmpty);
      expect(const SellerOrderFilter(search: '   ').toQuery(), isEmpty);
    });

    test('search goes out under the chosen field, trimmed', () {
      expect(const SellerOrderFilter(search: ' эм ').toQuery(), {'customer__name__icontains': 'эм'});
      expect(
        const SellerOrderFilter(searchBy: SellerOrderSearch.orderNo, search: '10245').toQuery(),
        {'orderNo': '10245'},
      );
    });

    test('dates cover whole days', () {
      final filter = SellerOrderFilter(
        dates: DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31)),
      );
      expect(filter.toQuery(), {
        'start': '2026-08-01T00:00:00',
        'end': '2026-08-31T23:59:59',
      });
    });

    test('choices go out as the model letter codes', () {
      const filter = SellerOrderFilter(
        status: OrderStatus.waiting,
        process: OrderProcess.packed,
        payType: PayType.loan,
        qpay: false,
      );
      expect(filter.toQuery(), {'status': 'W', 'process': 'P', 'payType': 'L', 'qp': 'false'});
    });

    test('ranges use the double-underscore names, widened to be inclusive', () {
      const filter = SellerOrderFilter(minTotal: 100000, maxTotal: 500000, minCount: 5, maxCount: 50);
      expect(filter.toQuery(), {
        'totalPrice__gt': '99999',
        'totalPrice__lt': '500001',
        'totalCount__gt': '4',
        'totalCount__lt': '51',
      });
    });
  });

  group('SellerOrderFilter state', () {
    test('copyWith clears a field with null and keeps the rest', () {
      const filter = SellerOrderFilter(status: OrderStatus.paid, payType: PayType.cash, search: 'эм');
      final next = filter.copyWith(status: null);
      expect(next.status, isNull);
      expect(next.payType, PayType.cash);
      expect(next.search, 'эм');
    });

    test('activeCount counts each range once and ignores the search', () {
      const filter = SellerOrderFilter(
        search: 'эм',
        status: OrderStatus.paid,
        minTotal: 1,
        maxTotal: 2,
        maxCount: 9,
      );
      expect(filter.activeCount, 3);
    });

    test('cleared keeps only the search box', () {
      const filter = SellerOrderFilter(
        searchBy: SellerOrderSearch.orderNo,
        search: '12',
        qpay: true,
        minCount: 3,
      );
      final cleared = filter.cleared();
      expect(cleared.activeCount, 0);
      expect(cleared.toQuery(), {'orderNo': '12'});
    });

    test('datesLabel shows one date for a single day', () {
      final day = SellerOrderFilter(
        dates: DateTimeRange(start: DateTime(2026, 10, 21), end: DateTime(2026, 10, 21)),
      );
      final range = SellerOrderFilter(
        dates: DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 21)),
      );
      expect(day.datesLabel, '2026.10.21');
      expect(range.datesLabel, '2026.10.01 – 2026.10.21');
    });
  });
}
