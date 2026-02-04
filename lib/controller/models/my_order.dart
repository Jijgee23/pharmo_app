import 'package:pharmo_app/application/application.dart';

class OrderModel {
  int id;
  String orderNo;
  double totalPrice;
  double totalCount;
  String status;
  String process;
  String payType;
  String? createdOn;
  String? customer;
  String? supplier;

  // MyOrderModel-д байсан талбарууд
  String? address;
  String? noteText; // String note
  List<dynamic> products;

  // SellerOrderModel-д байсан талбарууд
  bool? qp;
  String? endedOn;
  bool hasNote; // bool note

  OrderModel({
    required this.id,
    required this.orderNo,
    required this.totalPrice,
    required this.totalCount,
    required this.status,
    required this.process,
    required this.payType,
    this.createdOn,
    this.customer,
    this.supplier,
    this.address,
    this.noteText,
    required this.products,
    this.qp,
    this.endedOn,
    required this.hasNote,
  });

  OrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'].toString(),
        totalPrice = parseDouble(json['totalPrice']),
        totalCount = parseDouble(json['totalCount']),
        status = json['status'] ?? 'U',
        process = json['process'] ?? 'U',
        payType = json['payType'] ?? 'U',
        createdOn = json['createdOn'],
        customer = json['customer'],
        supplier = json['supplier'],
        address = json['address'],
        // JSON-оос ирэхдээ 'note' нь String эсвэл bool байж болзошгүй тул шалгах
        noteText = json['note'] is String ? json['note'] : null,
        hasNote = json['note'] is bool ? json['note'] : false,
        products =
            json['items'] != null ? List<dynamic>.from(json['items']) : [],
        qp = json['qp'],
        endedOn = json['endedOn'];

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
      'customer': customer,
      'supplier': supplier,
      'address': address,
      'note': noteText ?? hasNote,
      'items': products,
      'qp': qp,
      'endedOn': endedOn,
    };
  }

  OrderStatus get orderStatus => OrderStatus.fromName(status);
  OrderProcess get orderProcess => OrderProcess.fromName(process);
  PayType get payMethod => PayType.fromName(payType);

  bool get isAcceptable =>
      orderProcess == OrderProcess.onDelivery ||
      orderProcess == OrderProcess.packed;
}
