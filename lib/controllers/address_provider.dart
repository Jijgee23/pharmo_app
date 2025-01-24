// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/models/address.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

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

  void reset() {
    provinces.clear();
    districts.clear();
    khoroos.clear();
    setProvinceId(0);
    setDistrictId(0);
    setKhorooId(0);
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
      final response = await apiGet('aimag_hot/');
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
      final response = await apiGet('sum_duureg/?aimag=$provId');
      if (response.statusCode == 200) {
        List res = jsonDecode(utf8.decode(response.bodyBytes));
        districts.clear();
        districts = res.map((e) => District.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      message('Алдаа гарлаа.');
    }
  }

  getKhoroo(int distId, BuildContext context) async {
    try {
      final response = await apiGet('bag_horoo/?sum=$distId');
      if (response.statusCode == 200) {
        List res = jsonDecode(utf8.decode(response.bodyBytes));
        khoroos = res.map((e) => Khoroo.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      message('Алдаа гарлаа.');
    }
  }
}
