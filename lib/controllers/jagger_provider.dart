import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  late Basket _basket;
  Basket get basket => _basket;

  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;

  Future<dynamic> getJaggers() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/clear_basket/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      notifyListeners();
      if (response.statusCode == 200) {
        return {'errorType': 1, 'data': response, 'message': 'Сагсан дахь бараа амжилттай устлаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.'};
      }
    } catch (e) {
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
