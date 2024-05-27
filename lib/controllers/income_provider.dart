// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IncomeProvider extends ChangeNotifier {
  List<Income> incomeList = <Income>[];

  getIncomeList(BuildContext context) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> resList = res['results'];
        incomeList.clear();
        incomeList = resList.map((item) => Income.fromJson(item)).toList();
      }
      notifyListeners();
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
    notifyListeners();
  }

  recordIncome(String note, String amount, BuildContext context) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'note': note,
          'amount': amount,
        }),
      );
      if (response.statusCode == 201) {
        showSuccessMessage(context: context, message: 'Амжилттай бүртгэгдлээ');
      }
      notifyListeners();
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
    notifyListeners();
  }

  updateIncome(int id, String note, String amount, BuildContext context) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'note': note,
            'amount': amount,
          },
        ),
      );
      if (response.statusCode == 200) {
        showSuccessMessage(context: context, message: 'Амжилттай');
      }
      notifyListeners();
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
    notifyListeners();
  }
}
