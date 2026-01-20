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

  void reset() {
    currentDate = DateTime.now();
    currentDate2 = DateTime.now();
    report.clear();
    notifyListeners();
  }

  Future getReports(String query) async {
    String e =
        'seller/report/?by=$query&year=${currentDate.year}&month=${currentDate.month}&year2=${currentDate2.year}&month2=${currentDate2.month}';
    try {
      final r = await api(Api.get, e);
      if (r == null) return;
      print(r.statusCode);
      print(r.body);
      if (r.statusCode == 200) {
        print(convertData(r).runtimeType);
        List<dynamic> data = convertData(r);
        setReport(data);
        notifyListeners();
      } else {
        report.clear();
        notifyListeners();
        // message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
      messageError(wait);
    }
    notifyListeners();
  }

  setCurrentDate(DateTime newDate, {bool isStart = true}) {
    final now = DateTime.now();
    if (newDate.isAfter(now)) {
      messageWarning('Огноо зөв сонгоно уу!');
      return;
    }
    if (isStart) {
      if (newDate.isAfter(currentDate2)) {
        messageWarning('Огноо зөв сонгоно уу!');
        return;
      }
      currentDate = newDate;
      notifyListeners();
      return;
    }
    if (newDate.isBefore(currentDate)) {
      messageWarning('Огноо зөв сонгоно уу!');
      return;
    }
    currentDate2 = newDate;
    notifyListeners();
  }
}
