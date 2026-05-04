import 'package:pharmo_app/application/function/utilities/utils.dart';

class Basket {
  int id;
  String? name;
  String? payType;
  double totalPrice;
  double totalCount;
  int? extra;
  int? branch;
  Map<String, dynamic>? supplier;
  // List<dynamic>? items;
  List<CartItemModel> items = [];

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
      (json['items'] as List).map((e) => CartItemModel.fromJson(e)).toList(),
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

class CartItemModel {
  // {"id":68427,"product_id":13914,"name":"Пензал Кү №10 шахмал","price":8900.0,"qty":1.0}
  final int id;
  final int productId;
  final String name;
  final double price;
  final double qty;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['product_id'],
      name: json['name'].toString(),
      price: parseDouble(json['price']),
      qty: parseDouble(json['qty']),
    );
  }
}
