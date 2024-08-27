import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/utilities/utils.dart';

class ProductProvider extends ChangeNotifier {
  Map data = {};
  void getProductDetail(int productID) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}products/$productID/'),
        headers: getHeader(bearerToken),
      );
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
