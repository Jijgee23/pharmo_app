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
  List<MyOrderModel> get orders => _orders;

  List<MyOrderDetailModel> _orderDetails = <MyOrderDetailModel>[];
  List<MyOrderDetailModel> get orderDetails => _orderDetails;

  Future<dynamic> getMyorders() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (res.statusCode == 200) {
        _orders.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ords = response['orders'];
        _orders = (ords).map((data) => MyOrderModel.fromJson(data)).toList();
        notifyListeners();
        return {'errorType': 1, 'data': response, 'message': 'Захиалгуудыг амжилттай авчирлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> getMyorderDetail(int orderId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/$orderId/items/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (res.statusCode == 200) {
        _orderDetails.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> dtls = response;
        _orderDetails = (dtls).map((data) => MyOrderDetailModel.fromJson(data)).toList();
        notifyListeners();
        return {'errorType': 1, 'data': response, 'message': 'Захиалгуудыг амжилттай авчирлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> getSuppliers() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}suppliers'), headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        return {'errorType': 1, 'data': res, 'message': 'Нийлүүлэгчидийг амжилттай авчирлаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Нийлүүлэгчидийг авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> getBranches() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}branch'), headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        return {'errorType': 1, 'data': res, 'message': 'Нийлүүлэгчидийг амжилттай авчирлаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Нийлүүлэгчидийг авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> filterOrders(String selectedFilter, String selectedItem) async {
    try {
      String bearerToken = await getAccessToken();
      dynamic res;
      if (selectedFilter == '0') {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/?process=$selectedItem'), headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': bearerToken,
        });
      } else if (selectedFilter == '1') {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/?status=$selectedItem'), headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': bearerToken,
        });
      } else if (selectedFilter == '2') {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/?payType=$selectedItem'), headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': bearerToken,
        });
      } else if (selectedFilter == '3') {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/?address=$selectedItem'), headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': bearerToken,
        });
      } else if (selectedFilter == '4') {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/?supplier=$selectedItem'), headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': bearerToken,
        });
      } else {
        res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/orders/'), headers: <String, String>{
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
        return {'errorType': 1, 'data': response, 'message': 'Захиалгуудыг амжилттай авчирлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Захиалгуудыг авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<dynamic> confirmOrder(int orderId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/accept_order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"id": orderId}));

      if (res.statusCode == 200) {
        notifyListeners();
        return {'errorType': 1, 'data': null, 'message': 'Таны захиалга амжилттай баталгаажлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Захиалга баталгаажуулах үед алдаа гарлаа.'};
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
