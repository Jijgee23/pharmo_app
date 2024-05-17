import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
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
  int selectedBranchId = -1;
  String payType = '';
  String? note;
  List<Branch> branchList = <Branch>[];
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

  getCustomerBranch() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'customerId': selectedCustomerId}));
      branchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < res.length; i++) {
          branchList.add(Branch.fromJson(res[i]));
        }
        await prefs.setInt('branchId', res[0]['id']);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
