class MyOrderDetailModel {
  int itemId;
  String? itemName;
  String? itemPrice;
  String? itemTotalPrice;
  int? itemQty;
  int? rQty;
  int? iQty;
  int? product;

  MyOrderDetailModel(
    this.itemId,
    this.itemName,
    this.itemPrice,
    this.itemTotalPrice,
    this.itemQty,
    this.rQty,
    this.iQty,
    this.product,
  );

  MyOrderDetailModel.fromJson(Map<String, dynamic> json)
      : itemId = json['itemId'],
        itemName = json['itemName'],
        itemPrice = json['itemPrice'],
        itemTotalPrice = json['itemTotalPrice'],
        itemQty = json['itemQty'],
        rQty = json['rQty'],
        iQty = json['iQty'],
        product = json['product'];

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemTotalPrice': itemTotalPrice,
      'itemQty': itemQty,
      'rQty': rQty,
      'iQty': iQty,
      'product': product,
    };
  }
}
