import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeProvider extends ChangeNotifier {
  int currentIndex = 0;
  bool invisible = false;
  String selectedCustomerName = '';
  int selectedCustomerId = 0;
  String? userEmail;
  String? userRole;
  int? basketId;
  changeIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  changeSelectedCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  changeSelectedCustomerName(String customerName) {
    selectedCustomerName = customerName;
    notifyListeners();
  }

  toggleInvisible() {
    invisible = !invisible;
    notifyListeners();
  }

  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userrole = prefs.getString('userrole');
    userEmail = useremail.toString();
    userRole = userrole.toString();
    notifyListeners();
  }

  getSelectedUser(int customerId, String customerName) {
    selectedCustomerId = customerId;
    selectedCustomerName = customerName;
    notifyListeners();
  }

  getBasketId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}get_basket/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      basketId = res['id'];
    }
  }
}
