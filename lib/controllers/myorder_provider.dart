import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrderProvider extends ChangeNotifier {
  List<MyOrderModel> _orders = <MyOrderModel>[];
  List<SellerOrderModel> sellerOrders = <SellerOrderModel>[];
  List<SellerOrderModel> filteredsellerOrders = <SellerOrderModel>[];
  List<MyOrderModel> get orders => _orders;

  List<MyOrderDetailModel> _orderDetails = <MyOrderDetailModel>[];
  List<MyOrderDetailModel> get orderDetails => _orderDetails;
  getSellerOrders() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}order/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
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
      String bearerToken = await getAccessToken();
      final res = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}order/?start=$startDate&end=$endDate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
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
      String bearerToken = await getAccessToken();
      final res = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}order/?start=$date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
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
      String bearerToken = await getAccessToken();
      final res = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
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

  Future<dynamic> getMyorderDetail(int orderId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}pharmacy/orders/$orderId/items/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (res.statusCode == 200) {
        _orderDetails.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> dtls = response;
        _orderDetails =
            (dtls).map((data) => MyOrderDetailModel.fromJson(data)).toList();
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

  Future<dynamic> getSuppliers() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}suppliers'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': bearerToken,
          });
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
      String bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}branch'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': bearerToken,
          });
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
      String bearerToken = await getAccessToken();
      dynamic res;
      if (selectedFilter == '0') {
        res = await http.get(
            Uri.parse(
                '${dotenv.env['SERVER_URL']}pharmacy/orders/?process=$selectedItem'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
      } else if (selectedFilter == '1') {
        res = await http.get(
            Uri.parse(
                '${dotenv.env['SERVER_URL']}pharmacy/orders/?status=$selectedItem'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
      } else if (selectedFilter == '2') {
        res = await http.get(
            Uri.parse(
                '${dotenv.env['SERVER_URL']}pharmacy/orders/?payType=$selectedItem'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
      } else if (selectedFilter == '3') {
        res = await http.get(
            Uri.parse(
                '${dotenv.env['SERVER_URL']}pharmacy/orders/?address=$selectedItem'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
      } else if (selectedFilter == '4') {
        res = await http.get(
            Uri.parse(
                '${dotenv.env['SERVER_URL']}pharmacy/orders/?supplier=$selectedItem'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
      } else {
        res = await http.get(
            Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': bearerToken,
            });
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

  Future<dynamic> confirmOrder(int orderId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/accept_order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"id": orderId}));

      if (res.statusCode == 200) {
        notifyListeners();
        return {
          'errorType': 1,
          'data': null,
          'message': 'Таны захиалга амжилттай баталгаажлаа.'
        };
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

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}

class SellerOrderModel {
  int id;
  int? orderNo;
  String? totalPrice;
  int? totalCount;
  String? status;
  String? process;
  String? payType;
  bool? qp;
  String? createdOn;
  String? endedOn;
  bool? note;
  String? user;
  OrderBranch? branch;
  int? seller;
  int? delman;
  int? packer;

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
      this.user,
      this.branch,
      this.seller,
      this.delman,
      this.packer);

  SellerOrderModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNo = json['orderNo'],
        totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        status = json['status'],
        process = json['process'],
        payType = json['payType'],
        qp = json['qp'],
        createdOn = json['createdOn'],
        endedOn = json['endedOn'],
        user = json['user'],
        branch = json['branch'] != null
            ? OrderBranch.fromJson(json['branch'])
            : null,
        seller = json['seller'],
        delman = json['delman'],
        packer = json['packer'];
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'status': status,
      'process': process,
      'payType': payType,
      'qp': qp,
      'createdOn': createdOn,
      'endedOn': endedOn,
      'supplier': user,
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
