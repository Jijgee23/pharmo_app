import 'package:flutter/material.dart';
import 'package:pharmo_app/models/seller_report.dart';
import 'package:pharmo_app/utilities/utils.dart';

class ReportProvider extends ChangeNotifier {
  List<SellerReport> sellerReport = [];
  DateTime currentDate = DateTime.now();
  DateTime currentDate2 = DateTime.now();
  List<dynamic> report = [];

  String query = 'month';
  double total = 0;
  int count = 0;
  String date = DateTime.now().toString().substring(0, 10);
  setTotal(double d) {
    total = d;
    notifyListeners();
  }

  setDate(dynamic d) {
    date = d.toString();
    notifyListeners();
  }

  setCount(int d) {
    count = d;
    notifyListeners();
  }

  setQuery(String n) {
    query = n;
    notifyListeners();
  }

  // setReport(dynamic n) {
  //   report = n;
  //   notifyListeners();
  // }

  Future getReports() async {
    String e =
        'seller/report/?by=day&year=${currentDate.year}&month=${currentDate.month}&year2=${currentDate2.year}&month2=${currentDate2.month}';
    try {
      final response = await apiGet(e);
      if (response.statusCode == 200) {
        final data = convertData(response);
        sellerReport =
            (data as List).map((d) => SellerReport.fromJson(d)).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future getReportsByQuery() async {
    try {
      final response = await apiGet(
        'seller/report/?by=$query&year=${currentDate.year}&month=${currentDate.month}&year2=${currentDate2.year}&month2=${currentDate2.month}',
      );
      if (response.statusCode == 200) {
        dynamic data = convertData(response);
        final p1 = (data as List)[0];
        print('p1 $p1');
        print('count: ${p1['count']}');
        setCount(p1['count']);
        setTotal(p1['total']);
        setDate(p1[query]);
        // report = (data as List).map((d) => d).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
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
