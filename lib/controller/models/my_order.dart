import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/application/function/utilities/utils.dart';

class OrderModel {
  int id;
  int? orderNo;
  double totalPrice;
  double totalCount;
  String? status;
  String? process;
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
  bool? hasNote; // bool note

  OrderModel({
    required this.id,
    this.orderNo,
    required this.totalPrice,
    required this.totalCount,
    this.status,
    this.process,
    required this.payType,
    this.createdOn,
    this.customer,
    this.supplier,
    this.address,
    this.noteText,
    required this.products,
    this.qp,
    this.endedOn,
    this.hasNote,
  });

  OrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = parseDouble(json['totalPrice']),
        totalCount = parseDouble(json['totalCount']),
        status = json['status'],
        process = json['process'],
        payType = json['payType'] ?? 'U',
        createdOn = json['createdOn'],
        customer = json['customer'],
        supplier = json['supplier'],
        address = json['address'],
        // JSON-оос ирэхдээ 'note' нь String эсвэл bool байж болзошгүй тул шалгах
        noteText = json['note'] is String ? json['note'] : null,
        hasNote = json['note'] is bool ? json['note'] : null,
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
      'note': noteText ?? hasNote, // Аль нэгийг нь илгээнэ
      'items': products,
      'qp': qp,
      'endedOn': endedOn,
    };
  }

  PayType get payMethod => PayType.fromName(payType);
}
