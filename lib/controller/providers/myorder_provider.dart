import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/function/utilities/a_utils.dart';

class MyOrderProvider extends ChangeNotifier {
  List<MyOrderModel> _orders = <MyOrderModel>[];
  List<SellerOrderModel> sellerOrders = <SellerOrderModel>[];
  List<SellerOrderModel> filteredsellerOrders = <SellerOrderModel>[];
  List<MyOrderModel> get orders => _orders;

  List<MyOrderDetailModel> _orderDetails = <MyOrderDetailModel>[];
  List<MyOrderDetailModel> get orderDetails => _orderDetails;
  List<Supplier> suppliers = [];
  List<Branch> branches = [];

  void reset() {
    sellerOrders.clear();
    filteredsellerOrders.clear();
    orderDetails.clear();
    orders.clear();
    suppliers.clear();
    branches.clear();
    notifyListeners();
  }

  late MyOrderDetailModel fetchedDetail;
  Future<List<SellerOrderModel>> getSellerOrders() async {
    List<SellerOrderModel> rult = [];
    try {
      final r = await api(Api.get, 'seller/order/');
      if (r == null) return rult;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        rult = sellerOrders;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return rult;
  }

  deleteSellerOrders({required int orderId}) async {
    try {
      final r = await api(Api.delete, 'seller/order/$orderId/');
      if (r == null) return;
      if (r.statusCode == 204) {
        messageComplete('Захиалга устлаа');
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    getSellerOrders();
    notifyListeners();
  }

  Future filterOrder(String type, String query) async {
    try {
      final r = await api(Api.get, 'seller/order/?$type=$query');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
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
      final r =
          await api(Api.get, 'seller/order/?start=$startDate&end=$endDate');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
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
      final r = await api(Api.get, 'seller/order/?start=$date');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        List<dynamic> ords = data['results'];
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
      final r = await api(Api.get, 'pharmacy/orders/');
      if (r == null) return;
      if (r.statusCode == 200) {
        _orders.clear();
        final data = convertData(r);
        List<dynamic> ords = data['orders'];
        _orders = (ords).map((data) => MyOrderModel.fromJson(data)).toList();
        notifyListeners();
        return {
          'errorType': 1,
          'data': r,
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
      final r = await api(Api.get, 'pharmacy/orders/$orderId/items/');
      if (r == null) return;
      if (r.statusCode == 200) {
        _orderDetails.clear();
        final data = convertData(r);
        List<dynamic> dtls = data;
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
      final r = await api(Api.get, 'suppliers_list/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        suppliers = (data as List).map((k) => Supplier.fromJson(k)).toList();
        notifyListeners();
      }
    } catch (e) {
      messageWarning('Өгөгдөл татаж чадсангүй!');
    }
  }

  Future<dynamic> getBranches() async {
    try {
      final r = await api(Api.get, 'branch/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        branches = (data as List).map((r) => Branch.fromJson(r)).toList();
        notifyListeners();
      }
    } catch (e) {
      // return {'errorType': 3, 'data': e, 'message': e};\
      throw Exception(e);
    }
  }

  Future<dynamic> filterOrders(
      String selectedFilter, String selectedItem) async {
    try {
      Response? r;
      if (selectedFilter == '0') {
        r = await api(Api.get, 'pharmacy/orders/?process=$selectedItem');
      } else if (selectedFilter == '1') {
        r = await api(Api.get, 'pharmacy/orders/?status=$selectedItem');
      } else if (selectedFilter == '2') {
        r = await api(Api.get, 'pharmacy/orders/?payType=$selectedItem');
      } else if (selectedFilter == '3') {
        r = await api(Api.get, 'pharmacy/orders/?addrs=$selectedItem');
      } else if (selectedFilter == '4') {
        r = await api(Api.get, 'pharmacy/orders/?supplier=$selectedItem');
      } else {
        r = await api(Api.get, 'pharmacy/orders/');
      }
      if (r == null) return;
      if (r.statusCode == 200) {
        _orders.clear();
        final data = convertData(r);
        List<dynamic> ords = data['orders'];
        _orders = (ords).map((data) => MyOrderModel.fromJson(data)).toList();
        notifyListeners();
        return {
          'errorType': 1,
          'data': data,
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

  Future confirmOrder(int orderId) async {
    try {
      final r =
          await api(Api.patch, 'pharmacy/accept_order/', body: {"id": orderId});
      if (r == null) return;
      switch (r.statusCode) {
        case 200:
          await getMyorders();
          return buildResponse(1, null, 'Таны захиалга амжилттай баталгаажлаа.');

        case 400:
          return buildResponse(2, null, 'Захиалгын түгээлт эхлээгүй');
        default:
          return buildResponse(3, null, 'Түр хүлээгээд дахин оролдно уу!');
      }
    } catch (e) {
      return buildResponse(4, null, 'Түр хүлээгээд дахин оролдно уу!');
    }
  }
}

class SellerOrderModel {
  int id;
  int? orderNo;
  double totalPrice;
  double totalCount;
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
        totalPrice = parseDouble(json['totalPrice']),
        totalCount = parseDouble(json['totalCount']),
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
  String? addrs;
  String name;
  OrderBranch(this.id, this.addrs, this.name);
  OrderBranch.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        addrs = json['addrs'],
        name = json['name'];
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addrs': addrs,
      'name': name,
    };
  }
}
