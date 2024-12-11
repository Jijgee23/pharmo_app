// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class IncomeProvider extends ChangeNotifier {
  List<Income> incomeList = <Income>[];

  getIncomeList() async {
    try {
      final response = await apiGet('income_record/');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        List<dynamic> resList = res['results'];
        incomeList.clear();
        incomeList = resList.map((item) => Income.fromJson(item)).toList();
      }
      notifyListeners();
    } catch (e) {
      message('Алдаа гарлаа');
    }
    notifyListeners();
  }

  getIncomeListByDateSinlge(String date) async {
    try {
      final response = await apiGet('income_record/?createdOn__date=$date');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        List<dynamic> resList = res['results'];
        incomeList.clear();
        incomeList = resList.map((item) => Income.fromJson(item)).toList();
      }
      notifyListeners();
    } catch (e) {
      message('Алдаа гарлаа');
    }
    notifyListeners();
  }

  getIncomeListByDateRanged(
      String date1, String date2) async {
    try {
      final response = await apiGet(
          'income_record/?createdOn__date__gt=$date1&createdOn__date__lt=$date2');
      if (response.statusCode == 200) {
        Map res = convertData(response);
        List<dynamic> resList = res['results'];
        incomeList.clear();
        incomeList = resList.map((item) => Income.fromJson(item)).toList();
      }
      notifyListeners();
    } catch (e) {
      message('Алдаа гарлаа');
    }
    notifyListeners();
  }

  recordIncome(String note, String amount) async {
    try {
      final response = await apiPost(
          'income_record/',
          jsonEncode({
            'note': note,
            'amount': amount,
          }));
      if (response.statusCode == 201) {
        message('Амжилттай бүртгэгдлээ');
      }
      notifyListeners();
    } catch (e) {
      message('Алдаа гарлаа');
    }
    notifyListeners();
  }

  updateIncome(int id, String note, String amount) async {
    try {
      final response = await apiPatch(
          'income_record/$id/', jsonEncode({'note': note, 'amount': amount}));
      if (response.statusCode == 200) {
        message('Амжилттай');
      }
      notifyListeners();
    } catch (e) {
      message('Алдаа гарлаа');
    }
    notifyListeners();
  }
}
