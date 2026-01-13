import 'package:pharmo_app/application/utilities/utils.dart';

class MyOrderModel {
  int id;
  int? orderNo;
  double totalPrice;
  double totalCount;
  String? status;
  String? process;
  String? payType;
  String? address;
  String? createdOn;
  String? supplier;
  String? note;
  String? customer;
  List<dynamic>? products;

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
    this.address,
    this.note,
    this.customer,
    this.products,
  );

  MyOrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = parseDouble(json['totalPrice']),
        totalCount = parseDouble(json['totalCount']),
        status = json['status'],
        process = json['process'],
        payType = json['payType'],
        createdOn = json['createdOn'],
        supplier = json['supplier'],
        address = json['address'],
        note = json['note'],
        products =
            json['items'] != null ? List<dynamic>.from(json['items']) : [],
        customer = json['customer'];

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
