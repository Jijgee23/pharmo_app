class Basket {
  int id;
  String? name;
  String? payType;
  String? totalPrice;
  int? totalCount;
  int? extra;
  String? branch;
  Map<String,dynamic>? supplier;
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
      : id = json['id'],
        name = json['name'],
        payType = json['payType'],
        totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        extra = json['extra'],
        branch = json['branch'],
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
