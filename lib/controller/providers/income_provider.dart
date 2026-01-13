// import 'package:flutter/material.dart';
// import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
// import 'package:pharmo_app/controller/models/a_models.dart';
// import 'package:pharmo_app/application/utilities/a_utils.dart';

// class IncomeProvider extends ChangeNotifier {
//   List<Income> incomeList = <Income>[];

  // getIncomeList() async {
  //   try {
  //     final response = await api(Api.get, 'income_record/');
  //     if (response!.statusCode == 200) {
  //       Map res = convertData(response);
  //       List<dynamic> resList = res['results'];
  //       incomeList.clear();
  //       incomeList = resList.map((item) => Income.fromJson(item)).toList();
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     messageWarning('Алдаа гарлаа');
  //   }
  //   notifyListeners();
  // }

  // getIncomeListByDateSinlge(String date) async {
  //   try {
  //     final response =
  //         await api(Api.get, 'income_record/?createdOn__date=$date');
  //     if (response!.statusCode == 200) {
  //       Map res = convertData(response);
  //       List<dynamic> resList = res['results'];
  //       incomeList.clear();
  //       incomeList = resList.map((item) => Income.fromJson(item)).toList();
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     messageWarning('Алдаа гарлаа');
  //   }
  //   notifyListeners();
  // }

  // getIncomeListByDateRanged(String date1, String date2) async {
  //   try {
  //     final response = await api(Api.get,
  //         'income_record/?createdOn__date__gt=$date1&createdOn__date__lt=$date2');
  //     if (response!.statusCode == 200) {
  //       Map res = convertData(response);
  //       List<dynamic> resList = res['results'];
  //       incomeList.clear();
  //       incomeList = resList.map((item) => Income.fromJson(item)).toList();
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     messageWarning('Алдаа гарлаа');
  //   }
  //   notifyListeners();
  // }

  // recordIncome(String note, String amount) async {
  //   try {
  //     final response = await api(Api.post, 'income_record/', body: {
  //       'note': note,
  //       'amount': amount,
  //     });
  //     if (response!.statusCode == 201) {
  //       messageComplete('Амжилттай бүртгэгдлээ');
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     messageWarning('Алдаа гарлаа');
  //   }
  //   notifyListeners();
  // }

  // updateIncome(int id, String note, String amount) async {
  //   try {
  //     final response = await api(Api.patch, 'income_record/$id/',
  //         body: {'note': note, 'amount': amount});
  //     if (response!.statusCode == 200) {
  //       messageComplete('Амжилттай');
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     messageWarning('Алдаа гарлаа');
  //   }
  //   notifyListeners();
  // }
// }
