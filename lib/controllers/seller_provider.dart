import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerProvider extends ChangeNotifier {
  Future<void> registerPharm(Pharmo pharmo) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/seller/reg_pharmacy/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'bearer $token',
        },
        body: jsonEncode(
          {
            'cName': pharmo.cName,
            'cRd': pharmo.cRd,
            'email': pharmo.email,
            'phone': pharmo.phone,
            'address': {
              'province': pharmo.address.province,
              'district': pharmo.address.district,
              'khoroo': pharmo.address.khoroo,
              'detailed': pharmo.address.detailed,
            },
          },
        ),
      );
      print(response.statusCode);
    } catch (e) {
      showFailedMessage(context: null, message: 'Алдаа гарлаа!');
    }
  }
}
