

class Ship {
  int id;
  String? name;
  String? startTime;
  String? endTime;
  String? lng;
  String? lat;
  int? ordersCnt;
  int? progress;
  String? createdOn;
  int? supplier;
  int? delman;
  double? duration;
  double? expense;
  int? stopsCnt;
  List<ShipOrders> inItems;
  Ship(
    this.id,
    this.name,
    this.startTime,
    this.endTime,
    this.lng,
    this.lat,
    this.ordersCnt,
    this.progress,
    this.createdOn,
    this.supplier,
    this.delman,
    this.duration,
    this.expense,
    this.stopsCnt,
    this.inItems,
  );
  factory Ship.fromJson(Map<String, dynamic> json) {
    return Ship(
      json['id'],
      json['name'].toString(),
      json['startTime'].toString(),
      json['endTime'].toString(),
      json['lng'].toString(),
      json['lat'].toString(),
      json['ordersCnt'],
      json['progress'],
      json['createdOn'].toString(),
      json['supplier'],
      json['delman'],
      json['duration'],
      json['expense'],
      json['stopsCnt'],
      (json['inItems'] as List)
          .map((item) => ShipOrders.fromJson(item))
          .toList(),
    );
  }
}

class ShipOrders {
  int id;
  String? orderNo;
  bool? isGiven;
  String? givenOn;
  String? note;
  int? branchId;
  String? branch;
  String? lat;
  String? lng;
  String? user;
  String? process;
  int? orderId;
  List<ShipOrderItem> items;
  ShipOrders(
      this.id,
      this.orderNo,
      this.isGiven,
      this.givenOn,
      this.note,
      this.branchId,
      this.branch,
      this.lat,
      this.lng,
      this.user,
      this.process,
      this.orderId,
      this.items);
  factory ShipOrders.fromJson(Map<String, dynamic> json) {
    return ShipOrders(
      json['id'],
      json['orderNo'],
      json['isGiven'],
      json['givenOn'],
      json['note'],
      json['branchId'],
      json['branch'],
      json['lat'],
      json['lng'],
      json['user'],
      json['process'],
      json['orderId'],
      (json['items'] as List)
          .map((item) => ShipOrderItem.fromJson(item))
          .toList(),
    );
  }
}

class ShipOrderItem {
  int itemId;
  String? itemName;
  int? itemQTy;
  int? iQty;
  int? rQty;
  String? itemPrice;
  String? itemTotalPrice;
  String? itemname_id;
  bool? is_promo_item;
  bool? is_promo_gift;
  int? gift_cnt;
  int? order;
  int? product;
  ShipOrderItem(
      this.itemId,
      this.itemName,
      this.itemQTy,
      this.iQty,
      this.rQty,
      this.itemPrice,
      this.itemTotalPrice,
      this.itemname_id,
      this.is_promo_item,
      this.is_promo_gift,
      this.gift_cnt,
      this.order,
      this.product);
  factory ShipOrderItem.fromJson(Map<String, dynamic> json) {
    return ShipOrderItem(
      json['itemId'],
      json['itemName'].toString(),
      json['itemQty'],
      json['iQty'],
      json['rQty'],
      json['itemPrice'],
      json['itemTotalPrice'],
      json['itemname_id'],
      json['is_promo_item'],
      json['is_promo_gift'],
      json['gift_cnt'],
      json['order'],
      json['product'],
    );
  }
}
