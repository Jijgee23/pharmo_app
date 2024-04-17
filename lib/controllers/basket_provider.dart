import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/basket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  late Basket _basket;
  Basket get basket => _basket;

  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];

  void increment() {
    _count++;
    notifyListeners();
  }

  Future<dynamic> addBasket({int? product_id, int? qty}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/basket_item/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({'product': product_id, 'qty': qty}));
      if (response.statusCode == 201) {
        return {'success': 'Сагсанд амжилттай нэмэгдлээ.'};
      } else {
        return {'fail': 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  void getBasket() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";

      final resBasket = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/get_basket'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (resBasket.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(utf8.decode(resBasket.bodyBytes));
        _basket = Basket.fromJson(res);
        _count = _basket.items != null && _basket.items!.isNotEmpty ? _basket.items!.length : 0;
        _shoppingCarts = _basket.items!;
        notifyListeners();
        // return (_basket.items != null && _basket.items!.isNotEmpty ? _basket.items?.length.toString() : '0');
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    // return '0';
  }

  Future<String?> get getBasketCount async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? basketCount = prefs.getString("basket_count");
      return basketCount;
    } catch (e) {
      print(e);
    }
    return '0';
  }

  Future<dynamic> clearBasket({int? basket_id}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/clear_basket/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({'basketId': basket_id}));
      notifyListeners();
      if (response.statusCode == 200) {
        return {'success': 'Сагсан дахь бараа амжилттай устлаа.'};
      } else {
        return {'fail': 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }
}
