import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/jagger.dart';
import 'package:pharmo_app/models/jagger_order.dart';
import 'package:pharmo_app/models/jagger_order_item.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  final int _count = 0;
  int get count => _count;

  late Basket _basket;
  Basket get basket => _basket;

  // late Map<String, dynamic> _jaggers;
  // Map<String, dynamic> get jaggers => _jaggers;

  final List<Jagger> _jaggers = <Jagger>[];
  List<Jagger> get jaggers => _jaggers;

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;

  Future<dynamic> getJaggers() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/shipment/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        // _jaggers = (response['results']).map((data) => Jagger.fromJson(data)).toList();
        for (int i = 0; i < response['results'].length; i++) {
          Jagger jagger = Jagger.fromJson(response['results'][i]);
          if (jagger.inItems != null && jagger.inItems!.isNotEmpty) {
            jagger.jaggerOrders = (jagger.inItems)!.map((data) => JaggerOrder.fromJson(data)).toList();
          }
          if (jagger.jaggerOrders != null && jagger.jaggerOrders!.isNotEmpty) {
            for (int j = 0; j < jagger.jaggerOrders!.length; j++) {
              jagger.jaggerOrders![j].jaggerOrderItems = (jagger.jaggerOrders![j].items)!.map((d) => JaggerOrderItem.fromJson(d)).toList();
            }
          }
          _jaggers.add(jagger);
        }
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай авчирлаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  Future<dynamic> startShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('http://192.168.88.39:8000/api/v1/start_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай эхэллээ.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт эхлэхэд алдаа гарлаа.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('http://192.168.88.39:8000/api/v1/end_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай дууслаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт дуусгахад алдаа гарлаа.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  Future<dynamic> textShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('http://192.168.88.39:8000/api/v1/end_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай дууслаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт дуусгахад алдаа гарлаа.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}
