import 'package:pharmo_app/application/function/utilities/utils.dart';

class Delivery {
  int id;
  DeliveryMan delman;
  List<Zone> zones;
  List<Order> orders;
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
      orders: (json['orders'] as List).map((e) => Order.fromJson(e)).toList(),
      items:
          (json['items'] as List).map((e) => DeliveryItem.fromJson(e)).toList(),
      startedOn: json['started_on'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      endedOn: json['ended_on'],
      progress: json['progress'].toString(),
      created: json['created'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delman': delman.toJson(),
      'zones': zones.map((e) => e.toJson()).toList(),
      'orders': orders.map((e) => e.toJson()).toList(),
      'started_on': startedOn,
      'lat': lat,
      'lng': lng,
      'ended_on': endedOn,
      'progress': progress,
      'created': created,
    };
  }
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

class Order {
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
  List<Item> items;
  List<OrderPayment>? payments;

  Order(
      {required this.id,
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
      this.payments});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        orderNo: json['orderNo'].toString(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        customer:
            json['customer'] != null ? User.fromJson(json['customer']) : null,
        orderer:
            json['orderer'] != null ? User.fromJson(json['orderer']) : null,
        totalPrice: parseDouble(json['totalPrice']),
        totalCount: parseDouble(json['totalCount']),
        status: json['status'] ?? '',
        process: json['process'] ?? '',
        seller: json['seller'] != null ? User.fromJson(json['seller']) : null,
        deliveryId: json['delivery_id'] ?? 0,
        payType: json['payType'] ?? '',
        zone: Zone.fromJson(json['zone'] ?? {}),
        createdOn: json['createdOn'] ?? '',
        items: (json['items'] as List? ?? [])
            .map((e) => Item.fromJson(e))
            .toList(),
        payments: (json['payments'] as List? ?? [])
            .map((e) => OrderPayment.fromJson(e))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNo': orderNo,
        'user': user!.toJson(),
        'customer': customer?.toJson(),
        'orderer': orderer!.toJson(),
        'totalPrice': totalPrice,
        'totalCount': totalCount,
        'status': status,
        'process': process,
        'seller': seller?.toJson(),
        'delivery_id': deliveryId,
        'payType': payType,
        'zone': zone.toJson(),
        'createdOn': createdOn,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class User {
  String id;
  String name;
  Zone? zone;
  String? lat;
  String? lng;

  User({required this.id, required this.name, this.zone, this.lat, this.lng});

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

class Item {
  int id;
  String itemName;
  double itemQty;
  double itemPrice;
  double itemTotalPrice;
  int productId;

  Item({
    required this.id,
    required this.itemName,
    required this.itemQty,
    required this.itemPrice,
    required this.itemTotalPrice,
    required this.productId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      itemName: json['itemName'],
      itemQty: parseDouble(json['itemQty']),
      itemPrice: parseDouble(json['itemPrice']),
      itemTotalPrice: parseDouble(json['itemTotalPrice']),
      productId: json['product_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'itemQty': itemQty,
        'itemPrice': itemPrice,
        'itemTotalPrice': itemTotalPrice,
        'product_id': productId,
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
  final double lat;
  final double lng;
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
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
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
