import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BasketProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  Future<String> addBasket({int? product_id, int? qty}) async {
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
        _count++;
        notifyListeners();
        return 'success';
      }
    } catch (e) {
      print(e);
      notifyListeners();
    }
    return 'fail';
  }
}
