// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class IncomeProvider extends ChangeNotifier {
  List<Income> incomeList = <Income>[];

  getIncomeList(BuildContext context) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: getHeader(bearerToken),
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

  getIncomeListByDateSinlge(BuildContext context, String date) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}income_record/?createdOn__date=$date'),
        headers: getHeader(bearerToken),
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

  getIncomeListByDateRanged(
      BuildContext context, String date1, String date2) async {
    try {
      final bearerToken = await getAccessToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}income_record/?createdOn__date__gt=$date1&createdOn__date__lt=$date2'),
        headers: getHeader(bearerToken),
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
      final bearerToken = await getAccessToken();
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: getHeader(bearerToken),
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
      final bearerToken = await getAccessToken();
      final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/$id/'),
        headers: getHeader(bearerToken),
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
