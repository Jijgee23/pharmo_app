import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class ReportProvider extends ChangeNotifier {
  DateTime currentDate = DateTime.now();
  DateTime currentDate2 = DateTime.now();
  List<dynamic> report = [];
  setReport(dynamic newReports) {
    report = newReports;
    notifyListeners();
  }

  Future getReports(String query) async {
    String e =
        'seller/report/?by=$query&year=${currentDate.year}&month=${currentDate.month}&year2=${currentDate2.year}&month2=${currentDate2.month}';
    try {
      final response = await api(Api.get, e);
      if (response == null) return;
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        print(convertData(response).runtimeType);
        List<dynamic> data = convertData(response);
        setReport(data);
        notifyListeners();
      } else {
        report.clear();
        notifyListeners();
        // message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
      message(wait);
    }
    notifyListeners();
  }

  setCurrentDate(DateTime newDate) {
    currentDate = newDate;
    notifyListeners();
  }

  setCurrentDate2(DateTime newDate) {
    currentDate2 = newDate;
    notifyListeners();
  }
}
