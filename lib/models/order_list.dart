class OrderList {
  int id;
  int orderNo;
  double totalPrice;
  int totalCount;
  String createdOn;

  OrderList({
    required this.id,
    required this.orderNo,
    required this.totalPrice,
    required this.totalCount,
    required this.createdOn,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      id: json['id'],
      orderNo: json['orderNo'],
      totalPrice: json['totalPrice'],
      totalCount: json['totalCount'],
      createdOn: json['createdOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'createdOn': createdOn,
    };
  }
}

class OrderItem {
  String itemName;
  double itemPrice;
  int itemQty;
  double itemTotalPrice;

  OrderItem({
    required this.itemName,
    required this.itemPrice,
    required this.itemQty,
    required this.itemTotalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemName: json['itemName'],
      itemPrice: json['itemPrice'],
      itemQty: json['itemQty'],
      itemTotalPrice: json['itemTotalPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemQty': itemQty,
      'itemTotalPrice': itemTotalPrice,
    };
  }
}
