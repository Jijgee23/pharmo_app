import 'package:pharmo_app/application/utilities/utils.dart';

class Basket {
  int id;
  String? name;
  String? payType;
  double totalPrice;
  double totalCount;
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

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      parseInt(json['id']),
      json['name'],
      json['payType'],
      parseDouble(json['totalPrice']),
      parseDouble(json['totalCount']),
      parseInt(json['extra']),
      parseInt(json['branch']),
      json['supplier'],
      json['items'] as List<dynamic>?,
    );
  }

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
