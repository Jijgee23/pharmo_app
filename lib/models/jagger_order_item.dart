import 'dart:ffi';

class JaggerOrderItem {
  int itemId;
  String? itemName;
  String? itemPrice;
  String? itemTotalPrice;
  int? itemQty;

  JaggerOrderItem(
    this.itemId,
    this.itemName,
    this.itemPrice,
    this.itemTotalPrice,
    this.itemQty,
  );

  JaggerOrderItem.fromJson(Map<String, dynamic> json)
      : itemId = json['itemId'],
        itemName = json['itemName'],
        itemPrice = json['itemPrice'],
        itemTotalPrice = json['itemTotalPrice'],
        itemQty = json['itemQty'];

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemTotalPrice': itemTotalPrice,
      'itemQty': itemQty,
    };
  }
}
