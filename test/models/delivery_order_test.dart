import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/enum/enums.dart';
import 'package:pharmo_app/data/models/delivery.dart';

DeliveryOrder _order({required String status, required String process}) {
  return DeliveryOrder(
    id: 1,
    orderNo: '1001',
    totalPrice: 1000,
    totalCount: 1,
    status: status,
    process: process,
    deliveryId: 1,
    payType: 'C',
    zone: Zone(id: 1, name: 'Zone 1'),
    createdOn: '2027-01-01',
    items: [],
    payments: [],
  );
}

void main() {
  group('DeliveryOrder.orderProcess / orderStatus', () {
    test('resolves the short backend code to the matching enum value', () {
      expect(_order(status: 'W', process: 'O').orderProcess, OrderProcess.onDelivery);
      expect(_order(status: 'W', process: 'O').orderStatus, OrderStatus.waiting);
      expect(_order(status: 'P', process: 'D').orderProcess, OrderProcess.delivered);
      expect(_order(status: 'P', process: 'D').orderStatus, OrderStatus.paid);
    });

    test('falls back to unknown for an unrecognized code', () {
      expect(_order(status: 'X', process: 'X').orderProcess, OrderProcess.unknown);
      expect(_order(status: 'X', process: 'X').orderStatus, OrderStatus.unknown);
    });

    test('isDelivered / isOnDelivery reflect the process code', () {
      expect(_order(status: 'W', process: 'D').isDelivered, isTrue);
      expect(_order(status: 'W', process: 'O').isOnDelivery, isTrue);
      expect(_order(status: 'W', process: 'D').isOnDelivery, isFalse);
    });
  });
}
