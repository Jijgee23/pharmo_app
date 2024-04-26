class SellerOrder {
  int id;
  int orderNo;
  double totalPrice;
  int totalCount;
  String status;
  String process;
  bool isChanging;
  bool isBilled;
  String payType;
  bool qp;
  String createdOn;
  String? extra;
  User? user;
  String supplier;
  Address address;
  Seller? seller;
  String? delman;
  String? packer;

  SellerOrder(
    this.id,
    this.orderNo,
    this.totalPrice,
    this.totalCount,
    this.process,
    this.isChanging,
    this.isBilled,
    this.payType,
    this.qp,
    this.user,
    this.supplier,
    this.address,
    this.seller,
    this.delman,
    this.packer,
    this.createdOn,
    this.extra,
    this.status,
  );

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    return SellerOrder(
      json['id'],
      json['orderNo'],
      json['totalPrice'].toDouble(),
      json['totalCount'],
      json['process'],
      json['isChanging'],
      json['isBilled'],
      json['payType'],
      json['qp'],
      json['user'] != null ? User.fromJson(json['user']) : null,
      json['supplier'],
      Address.fromJson(json['address']),
      json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      json['delman'],
      json['packer'],
      json['createdOn'],
      json['extra'],
      json['status'],
    );
  }
}

class User {
  String name;
  String rd;

  User(this.name, this.rd);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['name'],
      json['rd'],
    );
  }
}

class Address {
  int id;
  String address;
  String branchName;

  Address(this.id, this.address, this.branchName);

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      json['id'],
      json['address'],
      json['branchName'],
    );
  }
}

class Seller {
  int id;
  String phone;

  Seller(this.id, this.phone);

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      json['id'],
      json['phone'],
    );
  }
}
