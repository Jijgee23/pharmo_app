import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

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
    List<SellerOrderModel> result = [];
    try {
      final res = await api(Api.get, 'seller/order/');
      if (res!.statusCode == 200) {
        final response = convertData(res);
        List<dynamic> ords = response['results'];
        sellerOrders.clear();
        sellerOrders =
            (ords).map((data) => SellerOrderModel.fromJson(data)).toList();
        result = sellerOrders;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  deleteSellerOrders({required int orderId}) async {
    try {
      final res = await api(Api.delete, 'seller/order/$orderId/');
      if (res!.statusCode == 204) {
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
      final res = await api(Api.get, 'seller/order/?$type=$query');
      if (res!.statusCode == 200) {
        final response = convertData(res);
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
      final res =
          await api(Api.get, 'seller/order/?start=$startDate&end=$endDate');
      if (res!.statusCode == 200) {
        final response = convertData(res);
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
      final res = await api(Api.get, 'seller/order/?start=$date');
      if (res!.statusCode == 200) {
        final response = convertData(res);
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
      final res = await api(Api.get, 'pharmacy/orders/');
      if (res!.statusCode == 200) {
        _orders.clear();
        final response = convertData(res);
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
      final res = await api(Api.get, 'pharmacy/orders/$orderId/items/');
      if (res!.statusCode == 200) {
        _orderDetails.clear();
        final response = convertData(res);
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
      final response = await api(Api.get, 'suppliers_list/');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        suppliers = (res as List).map((k) => Supplier.fromJson(k)).toList();
        notifyListeners();
      }
    } catch (e) {
      messageWarning('Өгөгдөл татаж чадсангүй!');
    }
  }

  Future<dynamic> getBranches() async {
    try {
      final response = await api(Api.get, 'branch/');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        branches = (res as List).map((r) => Branch.fromJson(r)).toList();
        notifyListeners();
        // return {
        //   'errorType': 1,
        //   'data': res,
        //   'message': 'Нийлүүлэгчидийг амжилттай авчирлаа.'
        // };
      }
      // else {
      //   return {
      //     'errorType': 2,
      //     'data': null,
      //     'message': 'Нийлүүлэгчидийг авчрахад алдаа гарлаа.'
      //   };
      // }
    } catch (e) {
      // return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> filterOrders(
      String selectedFilter, String selectedItem) async {
    try {
      Response? res;
      if (selectedFilter == '0') {
        res = await api(Api.get, 'pharmacy/orders/?process=$selectedItem');
      } else if (selectedFilter == '1') {
        res = await api(Api.get, 'pharmacy/orders/?status=$selectedItem');
      } else if (selectedFilter == '2') {
        res = await api(Api.get, 'pharmacy/orders/?payType=$selectedItem');
      } else if (selectedFilter == '3') {
        res = await api(Api.get, 'pharmacy/orders/?address=$selectedItem');
      } else if (selectedFilter == '4') {
        res = await api(Api.get, 'pharmacy/orders/?supplier=$selectedItem');
      } else {
        res = await api(Api.get, 'pharmacy/orders/');
      }
      if (res == null) return;
      if (res.statusCode == 200) {
        _orders.clear();
        final response = convertData(res);
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

  Future confirmOrder(int orderId) async {
    try {
      final res =
          await api(Api.patch, 'pharmacy/accept_order/', body: {"id": orderId});
      switch (res!.statusCode) {
        case 200:
          await getMyorders();
          return buildResponse(
              1, null, 'Таны захиалга амжилттай баталгаажлаа.');

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
