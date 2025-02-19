class MyOrderModel {
  int id;
  int? orderNo;
  double? totalPrice;
  int? totalCount;
  String? status;
  String? process;
  String? payType;
  String? address;
  String? createdOn;
  String? supplier;

  MyOrderModel(
    this.id,
    this.orderNo,
    this.totalPrice,
    this.totalCount,
    this.status,
    this.process,
    this.payType,
    this.createdOn,
    this.supplier,
  );

  MyOrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        status = json['status'],
        process = json['process'],
        payType = json['payType'],
        createdOn = json['createdOn'],
        supplier = json['supplier'],
        address = json['address'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'status': status,
      'process': process,
      'payType': payType,
      'createdOn': createdOn,
      'supplier': supplier,
      'address': address,
    };
  }
}
