import 'package:pharmo_app/application/utilities/a_utils.dart';

class MyOrderDetailModel {
  int itemId;
  String? itemName;
  double itemPrice;
  double itemTotalPrice;
  double itemQty;
  double rQty;
  double iQty;
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
        itemPrice = parseDouble(json['itemPrice']),
        itemTotalPrice = parseDouble(json['itemTotalPrice']),
        itemQty = parseDouble(json['itemQty']),
        rQty = parseDouble(json['rQty']),
        iQty = parseDouble(json['iQty']),
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
