import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/utils.dart';

class ProductProvider extends ChangeNotifier {
  Map data = {};
  void getProductDetail(int productID) async {
    try {
      final response = await apiGet('products/$productID/');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        this.data = data;
        debugPrint(data.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
