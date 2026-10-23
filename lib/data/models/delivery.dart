import 'package:pharmo_app/application/app_lite.dart';

class Delivery {
  int id;
  DeliveryMan delman;
  List<Zone> zones;
  List<DeliveryOrder> orders;
  String? startedOn;
  double? lat;
  double? lng;
  String? endedOn;
  String? progress;
  String created;
  List<DeliveryItem>? items;

  Delivery({
    required this.id,
    required this.delman,
    required this.zones,
    required this.orders,
    this.startedOn,
    this.lat,
    this.lng,
    this.endedOn,
    this.progress,
    this.items,
    required this.created,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      delman: DeliveryMan.fromJson(json['delman']),
      zones: (json['zones'] as List).map((e) => Zone.fromJson(e)).toList(),
      orders: (json['orders'] as List).map((e) => DeliveryOrder.fromJson(e)).toList(),
      items: (json['items'] as List).map((e) => DeliveryItem.fromJson(e)).toList(),
      startedOn: json['started_on'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      endedOn: json['ended_on'],
      progress: json['progress'].toString(),
      created: json['created'],
    );
  }

  /// When it started, in local time; null until it has.
  DateTime? get startedAt => parseDateTime(startedOn);
  bool get isStarted => startedAt != null;

  /// Orders done with: delivered, returned or closed.
  int get handledCount => orders.where((o) => o.isHandled).length;

  /// [handledCount] as a share of all orders, 0 to 1.
  double get doneRatio => orders.isEmpty ? 0 : handledCount / orders.length;

  int countOf(OrderProcess process) => orders.where((o) => o.orderProcess == process).length;

  /// The orders grouped by who they go to, in the order first met.
  List<DeliveryStop> get stops {
    final byKey = <String, List<DeliveryOrder>>{};
    for (final order in orders) {
      byKey.putIfAbsent(order.recipient?.id ?? '', () => []).add(order);
    }
    return [for (final e in byKey.entries) DeliveryStop(e.key, e.value)];
  }

  /// The stop for recipient [key], if the delivery still has one.
  DeliveryStop? stop(String key) => stops.where((s) => s.key == key).firstOrNull;
}

/// One place a delivery calls at: a recipient and their orders on it.
class DeliveryStop {
  /// The recipient's id; empty for orders with none.
  final String key;
  final List<DeliveryOrder> orders;
  const DeliveryStop(this.key, this.orders);

  User? get recipient => orders.first.recipient;
  String get name => orders.first.recipientName;

  /// Where to go: the first order whose recipient has coordinates.
  (double, double)? get coordinates =>
      orders.map((o) => o.recipientCoordinates).nonNulls.firstOrNull;

  int get handledCount => orders.where((o) => o.isHandled).length;
  double get doneRatio => handledCount / orders.length;
  bool get isDone => handledCount == orders.length;

  /// Customer payments take a customer id; branches ("p…") have none.
  int? get customerId => int.tryParse(key);
}

class DeliveryMan {
  int id;
  String name;

  DeliveryMan({required this.id, required this.name});

  factory DeliveryMan.fromJson(Map<String, dynamic> json) {
    return DeliveryMan(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Zone {
  int id;
  String name;

  Zone({required this.id, required this.name});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: parseInt(json['id']),
      name: json['name'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DeliveryOrder {
  int id;
  String orderNo;
  User? user;
  User? customer;
  User? orderer;
  double totalPrice;
  double totalCount;
  String status;
  String process;
  User? seller;
  int deliveryId;
  String payType;
  Zone zone;
  String createdOn;
  // List<dynamic> items;/
  List<DeliveryOrderItem> items;
  List<OrderPayment> payments;

  DeliveryOrder({
    required this.id,
    required this.orderNo,
    this.user,
    this.customer,
    this.orderer,
    required this.totalPrice,
    required this.totalCount,
    required this.status,
    required this.process,
    this.seller,
    required this.deliveryId,
    required this.payType,
    required this.zone,
    required this.createdOn,
    required this.items,
    required this.payments,
  });
  PayType get paymentType => PayType.fromValue(payType);
  OrderProcess get orderProcess => OrderProcess.fromCode(process);
  bool get isDelivered => orderProcess == OrderProcess.delivered;
  bool get isPending => orderProcess == OrderProcess.packed;
  bool get isOnDelivery => orderProcess == OrderProcess.onDelivery;
  OrderStatus get orderStatus => OrderStatus.fromValue(status);

  bool get isHandled => orderProcess.isHandled;

  /// Who it goes to: the orderer, else the customer, else the user.
  User? get recipient => orderer ?? customer ?? user;

  /// Where it goes: the first of orderer, customer and user with coordinates.
  (double, double)? get recipientCoordinates =>
      [orderer, customer, user].map((u) => u?.coordinates).nonNulls.firstOrNull;

  /// Who it goes to, for display: the orderer, else the customer, else the
  /// user. A missing name arrives stringified as 'null' and doesn't count.
  String get recipientName {
    for (final u in [orderer, customer, user]) {
      final name = u?.name.trim();
      if (name != null && name.isNotEmpty && name != 'null') return name;
    }
    return 'Захиалагч';
  }

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
        id: json['id'],
        orderNo: json['orderNo'].toString(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        customer: json['customer'] != null ? User.fromJson(json['customer']) : null,
        orderer: json['orderer'] != null ? User.fromJson(json['orderer']) : null,
        totalPrice: parseDouble(json['totalPrice']),
        totalCount: parseDouble(json['totalCount']),
        status: json['status'] ?? '',
        process: json['process'] ?? '',
        seller: json['seller'] != null ? User.fromJson(json['seller']) : null,
        deliveryId: json['delivery_id'] ?? 0,
        payType: json['payType'] ?? '',
        zone: Zone.fromJson(json['zone'] ?? {}),
        createdOn: json['createdOn'] ?? '',
        items: (json['items'] as List? ?? []).map((e) => DeliveryOrderItem.fromJson(e)).toList(),
        payments: (json['payments'] as List? ?? []).map((e) => OrderPayment.fromJson(e)).toList());
  }
}

class DeliveryOrderItem {
  final int id, productId;
  final String name;
  final double qty, price, totalPrice;

  const DeliveryOrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.totalPrice,
    required this.qty,
  });
  factory DeliveryOrderItem.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItem(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      name: json['itemName'].toString(),
      qty: parseDouble(json['itemQty']),
      price: json['itemPrice'],
      totalPrice: json['itemTotalPrice'],
    );
  }
}

// "id": 158075,
//           "itemName": "Дустар №30",
//           "itemQty": 55.0,
//           "itemPrice": 33600.0,
//           "itemTotalPrice": 1848000.0,
//           "product_id": 11428

class User {
  String id;
  String name;
  Zone? zone;
  String? lat;
  String? lng;

  User({required this.id, required this.name, this.zone, this.lat, this.lng});

  /// (lat, lng), or null when missing; (0, 0) counts as missing too.
  (double, double)? get coordinates {
    final la = double.tryParse(lat ?? ''), lo = double.tryParse(lng ?? '');
    if (la == null || lo == null || (la == 0 && lo == 0)) return null;
    return (la, lo);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'].toString(),
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class OrderPayment {
  final int orderId;
  final int paymentId;
  final double amount;
  final String payType;
  final int receiverId;
  final DateTime paidOn;

  OrderPayment({
    required this.orderId,
    required this.paymentId,
    required this.amount,
    required this.payType,
    required this.receiverId,
    required this.paidOn,
  });

  // Factory constructor to create an instance from a JSON map
  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      orderId: json['order_id'] as int,
      paymentId: json['payment_id'] as int,
      amount: json['amount'].toDouble(),
      payType: json['pay_type'] as String,
      receiverId: json['receiver_id'] as int,
      paidOn: DateTime.parse(json['paid_on']),
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'payment_id': paymentId,
      'amount': amount,
      'pay_type': payType,
      'receiver_id': receiverId,
      'paid_on': paidOn.toIso8601String(),
    };
  }
}

class DeliveryItem {
  final int id;
  final int delivery;
  final int delman;
  final String note;
  final DateTime visitedOn;
  final double? lat;
  final double? lng;
  final DateTime created;

  DeliveryItem({
    required this.id,
    required this.delivery,
    required this.delman,
    required this.note,
    required this.visitedOn,
    required this.lat,
    required this.lng,
    required this.created,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      delivery: json['delivery'],
      delman: json['delman'],
      note: json['note'],
      visitedOn: DateTime.parse(json['visited_on']),
      lat: json['lat'],
      lng: json['lng'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery': delivery,
      'delman': delman,
      'note': note,
      'visited_on': visitedOn.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'created': created.toIso8601String(),
    };
  }
}
