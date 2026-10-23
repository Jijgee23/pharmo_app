import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history_filter.dart';

void main() {
  group('DeliveryHistoryFilter.toQuery', () {
    test('newest first, and nothing else, by default', () {
      expect(const DeliveryHistoryFilter().toQuery(), {'ordering': '-started_on'});
    });

    test('search goes out under the chosen field, trimmed', () {
      expect(
        const DeliveryHistoryFilter(search: ' 412 ').toQuery(),
        {'ordering': '-started_on', 'delivery_no': '412'},
      );
      expect(
        const DeliveryHistoryFilter(searchBy: DeliverySearch.orderNo, search: '10245').toQuery(),
        {'ordering': '-started_on', 'order_no': '10245'},
      );
    });

    test('dates are whole days on the start, sent as the API names them', () {
      final filter = DeliveryHistoryFilter(
        dates: DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 31)),
      );
      expect(filter.toQuery(), {
        'ordering': '-started_on',
        'started_on__gte': '2026-08-01T00:00:00',
        'started_on__lte': '2026-08-31T23:59:59',
      });
    });

    test('zone, progress and ordering', () {
      const complete = DeliveryHistoryFilter(
        zoneId: 4,
        zoneName: 'Баянзүрх',
        progress: DeliveryProgress.complete,
        oldestFirst: true,
      );
      expect(complete.toQuery(), {'ordering': 'started_on', 'zone': '4', 'progress__gte': '100'});
      expect(
        const DeliveryHistoryFilter(progress: DeliveryProgress.partial).toQuery(),
        {'ordering': '-started_on', 'progress__lte': '99'},
      );
    });
  });

  group('DeliveryHistoryFilter state', () {
    test('activeCount ignores the search and the default ordering', () {
      expect(const DeliveryHistoryFilter(search: '1').activeCount, 0);
      expect(
        const DeliveryHistoryFilter(zoneId: 1, progress: DeliveryProgress.partial, oldestFirst: true)
            .activeCount,
        3,
      );
    });

    test('cleared keeps only the search box', () {
      const filter = DeliveryHistoryFilter(
        searchBy: DeliverySearch.orderNo,
        search: '7',
        zoneId: 2,
        oldestFirst: true,
      );
      expect(filter.cleared().toQuery(), {'ordering': '-started_on', 'order_no': '7'});
    });

    test('copyWith clears a field with null and keeps the rest', () {
      const filter = DeliveryHistoryFilter(zoneId: 2, zoneName: 'Төв', progress: DeliveryProgress.complete);
      final next = filter.copyWith(zoneId: null, zoneName: null);
      expect(next.zoneId, isNull);
      expect(next.zoneName, isNull);
      expect(next.progress, DeliveryProgress.complete);
    });
  });
}
