import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class MyOrderProvider extends ChangeNotifier {
  List<MyOrderModel> _orders = <MyOrderModel>[];
  List<SellerOrderModel> sellerOrders = <SellerOrderModel>[];
  List<SellerOrderModel> filteredsellerOrders = <SellerOrderModel>[];
  List<MyOrderModel> get orders => _orders;

  List<MyOrderDetailModel> _orderDetails = <MyOrderDetailModel>[];
  List<MyOrderDetailModel> get orderDetails => _orderDetails;
  late MyOrderDetailModel fetchedDetail;
  getSellerOrders() async {
    try {
      final res = await apiGet('seller/order/');
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  filterOrder(String type, String query) async {
    try {
      final res = await apiGet('seller/order/?$type=$query');
      print(jsonDecode(utf8.decode(res.bodyBytes)));
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getSellerOrdersByDateRanged(String startDate, String endDate) async {
    try {
      final res = await apiGet('order/?start=$startDate&end=$endDate');
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getSellerOrdersByDateSingle(String date) async {
    try {
      final res = await apiGet('order/?start=$date');
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getMyorders() async {
    try {
      final res = await apiGet('pharmacy/orders/');
      if (res.statusCode == 200) {
        _orders.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['orders'];
        _orders = (ords).map((data) => MyOrderModel.fromJson(data)).toList();
        notifyListeners();
        return {
          'errorType': 1,
          'data': response,
          'message': 'Захиалгуудыг амжилттай авчирлаа.'
        };
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  getMyorderDetail(int orderId) async {
    try {
      final res = await apiGet('pharmacy/orders/$orderId/items/');
      if (res.statusCode == 200) {
        _orderDetails.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> dtls = response;
        _orderDetails =
            (dtls).map((data) => MyOrderDetailModel.fromJson(data)).toList();
        notifyListeners();
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'
        };
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getSuppliers() async {
    try {
      final response = await apiGet('suppliers');
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'errorType': 1,
          'data': res,
          'message': 'Нийлүүлэгчидийг амжилттай авчирлаа.'
        };
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Нийлүүлэгчидийг авчрахад алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> getBranches() async {
    try {
      final response = await apiGet('branch');
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'errorType': 1,
          'data': res,
          'message': 'Нийлүүлэгчидийг амжилттай авчирлаа.'
        };
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Нийлүүлэгчидийг авчрахад алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> filterOrders(
      String selectedFilter, String selectedItem) async {
    try {
      dynamic res;
      if (selectedFilter == '0') {
        res = await apiGet('pharmacy/orders/?process=$selectedItem');
      } else if (selectedFilter == '1') {
        res = await apiGet('pharmacy/orders/?status=$selectedItem');
      } else if (selectedFilter == '2') {
        res = await apiGet('pharmacy/orders/?payType=$selectedItem');
      } else if (selectedFilter == '3') {
        res = await apiGet('pharmacy/orders/?address=$selectedItem');
      } else if (selectedFilter == '4') {
        res = await apiGet('pharmacy/orders/?supplier=$selectedItem');
      } else {
        res = await apiGet('pharmacy/orders/');
      }
      if (res.statusCode == 200) {
        _orders.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['orders'];
        _orders = (ords).map((data) => MyOrderModel.fromJson(data)).toList();
        notifyListeners();
        return {
          'errorType': 1,
          'data': response,
          'message': 'Захиалгуудыг амжилттай авчирлаа.'
        };
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'
        };
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> confirmOrder(int orderId, BuildContext context) async {
    try {
      final res = await apiPatch('pharmacy/accept_order/', jsonEncode({"id": orderId}));
      final response = jsonDecode(utf8.decode(res.bodyBytes));
      print('response: $response ConfirmOrderStatus: ${res.statusCode}');
      if (res.statusCode == 200) {
        message(
            message: 'Таны захиалга амжилттай баталгаажлаа.', context: context);
        notifyListeners();
      } else if (res.statusCode == 400) {
        message(message: 'Захиалгын түгээлт эхлээгүй', context: context);
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Захиалга баталгаажуулах үед алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }
}

class SellerOrderModel {
  int id;
  int? orderNo;
  double? totalPrice;
  int? totalCount;
  String? status;
  String? process;
  String? payType;
  bool? qp;
  String? createdOn;
  String? endedOn;
  bool? note;
  String? customer;

  SellerOrderModel(
    this.id,
    this.orderNo,
    this.totalPrice,
    this.totalCount,
    this.status,
    this.process,
    this.payType,
    this.qp,
    this.createdOn,
    this.endedOn,
    this.note,
    this.customer,
  );

  SellerOrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        status = json['status'],
        process = json['process'],
        payType = json['payType'],
        qp = json['qp'],
        customer = json['customer'],
        createdOn = json['createdOn'],
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
      'customer': customer,
      'qp': qp,
      'createdOn': createdOn,
      'endedOn': endedOn,
    };
  }
}

class OrderBranch {
  int id;
  String? address;
  String name;
  OrderBranch(this.id, this.address, this.name);
  OrderBranch.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        address = json['address'],
        name = json['name'];
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'name': name,
    };
  }
}
