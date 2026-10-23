import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/app_lite.dart';
import 'package:pharmo_app/views/track_map/stop_markers.dart';

Map<String, dynamic> _order(int id, String process,
        {Map<String, dynamic>? orderer, Map<String, dynamic>? customer}) =>
    {
      'id': id,
      'orderNo': '$id',
      'process': process,
      'totalPrice': 1000,
      'totalCount': 1,
      if (orderer != null) 'orderer': orderer,
      if (customer != null) 'customer': customer,
    };

Delivery _delivery(List<Map<String, dynamic>> orders, {String? startedOn}) => Delivery.fromJson({
      'id': 7,
      'delman': {'id': 1, 'name': 'Бат'},
      'zones': [],
      'orders': orders,
      'items': [],
      'started_on': startedOn,
      'progress': 0,
      'created': '2026-10-22 08:00:00',
    });

void main() {
  group('handled orders', () {
    test('delivered, returned and closed are handled; the rest are not', () {
      final handled = OrderProcess.values.where((p) => p.isHandled).toSet();
      expect(handled, {OrderProcess.delivered, OrderProcess.returned, OrderProcess.closed});
    });

    test('a return still lets the delivery reach 100%', () {
      final d = _delivery([
        _order(1, 'D', orderer: {'id': 'a', 'name': 'A'}),
        _order(2, 'R', orderer: {'id': 'a', 'name': 'A'}),
        _order(3, 'C', orderer: {'id': 'b', 'name': 'B'}),
      ]);
      expect(d.handledCount, 3);
      expect(d.doneRatio, 1);
    });

    test('pending and on-the-way orders are not done', () {
      final d = _delivery([
        _order(1, 'P', orderer: {'id': 'a', 'name': 'A'}),
        _order(2, 'O', orderer: {'id': 'a', 'name': 'A'}),
        _order(3, 'D', orderer: {'id': 'a', 'name': 'A'}),
        _order(4, 'D', orderer: {'id': 'a', 'name': 'A'}),
      ]);
      expect(d.handledCount, 2);
      expect(d.doneRatio, 0.5);
      expect(d.countOf(OrderProcess.onDelivery), 1);
    });
  });

  group('stops', () {
    test('group orders by recipient, orderer before customer, in first-seen order', () {
      final d = _delivery([
        _order(1, 'P', orderer: {'id': 'p12', 'name': 'Салбар'}),
        _order(2, 'D', customer: {'id': 305, 'name': 'Эм Импекс'}),
        _order(3, 'D',
            orderer: {'id': 'p12', 'name': 'Салбар'}, customer: {'id': 305, 'name': 'Эм Импекс'}),
        _order(4, 'P'),
      ]);
      final stops = d.stops;
      expect(stops.map((s) => s.key), ['p12', '305', '']);
      expect(stops.first.orders.map((o) => o.id), [1, 3]);
      expect(stops.first.isDone, isFalse);
      expect(stops[1].isDone, isTrue);
      expect(stops.last.name, 'Захиалагч');
    });

    test('only numeric recipients take customer payments', () {
      final d = _delivery([
        _order(1, 'P', orderer: {'id': 'p12', 'name': 'Салбар'}),
        _order(2, 'P', customer: {'id': 305, 'name': 'Эм Импекс'}),
      ]);
      expect(d.stops.map((s) => s.customerId), [null, 305]);
    });

    test('a name sent as "null" falls back to the next recipient', () {
      final order = DeliveryOrder.fromJson(_order(
        1,
        'P',
        orderer: {'id': 'p1', 'name': null},
        customer: {'id': 2, 'name': 'Харилцагч'},
      ));
      expect(order.recipientName, 'Харилцагч');
    });

    test('coordinates come from whoever has them; (0, 0) does not count', () {
      final order = DeliveryOrder.fromJson(_order(
        1,
        'P',
        orderer: {'id': 'p1', 'name': 'A', 'lat': 0, 'lng': 0},
        customer: {'id': 2, 'name': 'B', 'lat': '47.91', 'lng': '106.9'},
      ));
      expect(order.recipientCoordinates, (47.91, 106.9));
    });
  });

  group('stop markers', () {
    test('one per stop with coordinates, with the same ids every time', () {
      final d = _delivery([
        _order(1, 'P', orderer: {'id': 'a', 'name': 'A', 'lat': '47.9', 'lng': '106.9'}),
        _order(2, 'D', orderer: {'id': 'a', 'name': 'A', 'lat': '47.9', 'lng': '106.9'}),
        _order(3, 'D', orderer: {'id': 'b', 'name': 'B', 'lat': '47.8', 'lng': '106.8'}),
        _order(4, 'P', orderer: {'id': 'c', 'name': 'C'}),
      ]);
      final first = stopMarkers(d).map((m) => m.markerId.value).toSet();
      final again = stopMarkers(d).map((m) => m.markerId.value).toSet();
      expect(first, {'stop-a', 'stop-b'});
      expect(again, first);
      expect(stopMarkers(null), isEmpty);
    });
  });

  group('dates', () {
    test('server timestamps parse, junk does not', () {
      expect(parseDateTime('2026-06-18 09:14:00'), DateTime(2026, 6, 18, 9, 14));
      expect(parseDateTime('soon'), isNull);
      expect(parseDateTime(null), isNull);
      expect(parseDateTime('2026-06-18T01:14:00Z')!.isUtc, isFalse);
    });

    test('a delivery has started once it has a start time', () {
      expect(_delivery([]).isStarted, isFalse);
      final started = _delivery([], startedOn: '2026-10-22 09:05:00');
      expect(started.isStarted, isTrue);
      expect(hourMinute(started.startedAt!), '09:05');
    });

    test('friendly times say today and yesterday', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 9, 14);
      expect(friendlyDateTime(today), 'Өнөөдөр 09:14');
      expect(friendlyDateTime(today.subtract(const Duration(days: 1))), 'Өчигдөр 09:14');
    });
  });
}
