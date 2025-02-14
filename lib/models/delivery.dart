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
    required this.created,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      delman: DeliveryMan.fromJson(json['delman']),
      zones: (json['zones'] as List).map((e) => Zone.fromJson(e)).toList(),
      orders: (json['orders'] as List).map((e) => Order.fromJson(e)).toList(),
      startedOn: json['started_on'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      endedOn: json['ended_on'],
      progress: json['progress'],
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
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Order {
  int id;
  int orderNo;
  User? user;
  User? customer;
  User? orderer;
  double totalPrice;
  int totalCount;
  String status;
  String process;
  User? seller;
  int deliveryId;
  String payType;
  Zone zone;
  String createdOn;
  List<Item> items;

  Order({
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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNo: json['orderNo'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      customer: json['customer'] != null ? User.fromJson(json['customer']) : null,
      orderer: json['orderer'] != null ? User.fromJson(json['orderer']) : null,
      totalPrice: json['totalPrice'].toDouble(),
      totalCount: json['totalCount'],
      status: json['status'],
      process: json['process'],
      seller: json['seller'] != null ? User.fromJson(json['seller']) : null,
      deliveryId: json['delivery_id'],
      payType: json['payType'],
      zone: Zone.fromJson(json['zone']),
      createdOn: json['createdOn'],
      items: (json['items'] as List).map((e) => Item.fromJson(e)).toList(),
    );
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

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
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
  int itemQty;
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
      itemQty: json['itemQty'],
      itemPrice: json['itemPrice'].toDouble(),
      itemTotalPrice: json['itemTotalPrice'].toDouble(),
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
