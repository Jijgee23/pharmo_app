import 'package:pharmo_app/application/utilities/utils.dart';

class Basket {
  int id;
  String? name;
  String? payType;
  String? totalPrice;
  int? totalCount;
  int? extra;
  int? branch;
  Map<String, dynamic>? supplier;
  List<dynamic>? items;

  Basket(
    this.id,
    this.name,
    this.payType,
    this.totalPrice,
    this.totalCount,
    this.extra,
    this.branch,
    this.supplier,
    this.items,
  );

  Basket.fromJson(Map<String, dynamic> json)
      : id = parseInt(json['id']),
        name = json['name'],
        payType = json['payType'],
        totalPrice = json['totalPrice'],
        totalCount = parseInt(json['totalCount']),
        extra = parseInt(json['extra']),
        branch = parseInt(json['branch']),
        supplier = json['supplier'],
        items = json['items'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'payType': payType,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'extra': extra,
      'branch': branch,
      'supplier': supplier,
      'items': items,
    };
  }
}
