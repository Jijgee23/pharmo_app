// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/address.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressProvider extends ChangeNotifier {
  List<Province> provinces = <Province>[];
  List<District> districts = <District>[];
  int _selectedProvince = 0;
  int get selectedProvince => _selectedProvince;
  int _selectedDistrict = 0;
  int get selectedDistrict => _selectedDistrict;
  int _selectedKhoroo = 0;
  int get selectedKhoroo => _selectedKhoroo;
  List<Khoroo> khoroos = <Khoroo>[];
  String _province = 'Аймаг/Хот';
  String get province => _province;
  String _district = 'Сум/Дүүрэг';
  String get district => _district;
  String _khoroo = 'Баг/Хороо';
  String get khoroo => _khoroo;
  setProvinceId(int id) {
    _selectedProvince = id;
    notifyListeners();
  }

  setDistrictId(int id) {
    _selectedDistrict = id;
    notifyListeners();
  }

  setKhorooId(int id) {
    _selectedKhoroo = id;
    notifyListeners();
  }

  setProvince(String province) {
    _province = province;
    notifyListeners();
  }

  setDistrict(String district) {
    _district = district;
    notifyListeners();
  }

  setKhoroo(String khoroo) {
    _khoroo = khoroo;
    notifyListeners();
  }

  getProvince() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}aimag_hot/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
      if (response.statusCode == 200) {
        List res = jsonDecode(utf8.decode(response.bodyBytes));
        provinces = res.map((e) => Province.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getDistrictId(int provId, BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}sum_duureg/?aimag=$provId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
      if (response.statusCode == 200) {
        List res = jsonDecode(utf8.decode(response.bodyBytes));
        districts.clear();
        districts = res.map((e) => District.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  getKhoroo(int distId, BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}bag_horoo/?sum=$distId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
      if (response.statusCode == 200) {
        List res = jsonDecode(utf8.decode(response.bodyBytes));
        khoroos = res.map((e) => Khoroo.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}
