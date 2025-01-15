// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/jagger.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/models/ship.dart';
import 'package:pharmo_app/models/shipment.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  final List<Jagger> _jaggers = <Jagger>[];
  List<Jagger> get jaggers => _jaggers;

  List<JaggerExpenseOrder> jaggerOrders = <JaggerExpenseOrder>[];

  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  TextEditingController amount = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController rQty = TextEditingController();
  TextEditingController feedback = TextEditingController();
  ValidationModel _noteVal = ValidationModel(null, null);
  ValidationModel get noteVal => _noteVal;
  ValidationModel _amountVal = ValidationModel(null, null);
  ValidationModel get amountVal => _amountVal;
  final ValidationModel _rqtyVal = ValidationModel(null, null);
  ValidationModel get rqtyVal => _rqtyVal;

  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _latitude = '';
  String _longitude = '';
  String get latitude => _latitude;
  String get longitude => _longitude;
  List<Shipment> shipments = <Shipment>[];
  bool isStartDate = true;
  void toggleIsStartDate() {
    isStartDate = !isStartDate;
    notifyListeners();
  }

  List<Ship> _ships = <Ship>[];
  List<Ship> get ships => _ships;

  final List<String> _operators = ['=', '=<', '=>'];
  List<String> get operators => _operators;
  String _operator = '=';
  String get operator => _operator;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  final List<String> _filters = [
    'Огноогоор',
    'Захиалгын тоогоор',
    'Явцын хувиар',
    'Зарлагын дүнгээр'
  ];
  List<String> get filters => _filters;
  String _filter = 'сонгох';
  String get filter => _filter;

  String _type = 'ordersCnt';
  String get type => _type;
  Widget _selecterFilter = const SizedBox();
  Widget get selecterFilter => _selecterFilter;

  void getFilter(Widget filter) {
    _selecterFilter = filter;
    notifyListeners();
  }

  void changeOperator(String opr) {
    _operator = opr;
    notifyListeners();
  }

  void changeType(String ty) {
    _type = ty;
    notifyListeners();
  }

  void changeFilter(String filt) {
    _filter = filt;
    notifyListeners();
  }

  fetchJaggers() async {
    await getJaggers();
    await getExpenses();
  }

  Future<dynamic> getJaggers() async {
    try {
      final res = await apiGet('shipment/');
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        ships.clear();
        _ships =
            (response['results'] as List).map((e) => Ship.fromJson(e)).toList();
        notifyListeners();
        return {
          'errorType': 1,
          'data': null,
          'message': 'Захиалгууд амжилттай татлаа!'
        };
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Дахин оролдоно уу!'};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future getExpenses() async {
    try {
      final res = await apiGet('shipment_expense/');
      if (res.statusCode == 200) {
        final response = convertData(res);
        jaggerOrders.clear();
        jaggerOrders = (response['results'] as List)
            .map((e) => JaggerExpenseOrder.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> startShipment(
      int shipmentId, double? lat, double? lng, BuildContext context) async {
    try {
      var body = {
        "shipmentId": shipmentId,
        "lat": (lat != null) ? lat : null,
        "lng": (lng != null) ? lng : null
      };
      await getLocation(context);
      await HomeProvider().getPosition();
      final res = await apiPatch('start_shipment/', body);
      notifyListeners();
      if (res.statusCode == 200) {
        final response = convertData(res);
        debugPrint(response);
        message('$response цагт түгээлт эхлэлээ');
      } else {
        message('Түгээлт эхлэхэд алдаа гарлаа');
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId, double? lat, double? lng,
      bool force, BuildContext context) async {
    try {
      var body = {
        "shipmentId": shipmentId,
        "lat": (lat != null) ? lat : null,
        "lng": (lng != null) ? lng : null,
        "force": force
      };
      await HomeProvider().getPosition();
      await getLocation(context);
      final res = await apiPatch('end_shipment/', body);
      notifyListeners();
      if (res.statusCode == 200) {
        message('Түгээлт дууслаа.');
      } else {
        message('Түгээлт дуусгахад алдаа гарлаа.');
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> addExpense(
      String note, String amount, BuildContext context) async {
    try {
      final res = await apiPost(
          'shipment_expense/', {"note": note, "amount": amount});
      if (res.statusCode == 201) {
        await getExpenses();
        return buildResponse(0, null, 'Түгээлтийн зарлага нэмэгдлээ.');
      } else {
        // final response = convertData(res);
        return buildResponse(1, null, 'Түгээлт эхлээгүй!');
      }
    } catch (e) {
      debugPrint(e.toString());
      return buildResponse(1, null, 'Түр хүлээгээд дахин оролдоно уу!');
    }
  }

  addnote(int shipId, int itemId, BuildContext context) async {
    try {
      var body = 
          {"shipId": shipId, "itemId": itemId, "note": feedback.text};
      final res = await apiPatch('shipment_add_note/', body);
      if (res.statusCode == 200) {
        message('Түгээлтийн тайлбар амжилттай нэмэгдлээ.');
        feedback.clear();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }

  Future<dynamic> setFeedback(int shipId, int itemId) async {
    try {
      var body =
          {"shipId": shipId, "itemId": itemId, "note": feedback.text};
      final res = await apiPatch('shipment_add_note/', body);
      if (res.statusCode == 200) {
        message('Түгээлтийн тайлбар амжилттай нэмэгдлээ.');
        feedback.text = '';
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> editExpenseAmount(int id) async {
    try {
      final res = await apiPatch('shipment_expense/$id/',
          {"note": note.text, "amount": amount.text});
      notifyListeners();
      if (res.statusCode == 200) {
        final response = convertData(res);
        await getExpenses();
        amount.text = '';
        note.text = '';
        return {
          'errorType': 1,
          'data': response,
          'message': 'Түгээлтийн зарлага амжилттай засагдлаа.'
        };
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Түгээлтийн зарлага засхад алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  updateQTY(int itemId, int qty) async {
    try {
      var res = await apiPatch(
          'update_item_qty/', {"itemId": itemId, "qty": qty});
      if (res.statusCode == 200) {
        await getJaggers();
        message('Амжилттай засагдлаа.');
      } else {
        message('Алдаа гарлаа.');
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  void validateNote(String? val) {
    if (val != null && val.isNotEmpty) {
      _noteVal = ValidationModel(val, null);
    } else {
      _noteVal = ValidationModel(null, 'Алдаатай имэйл хаяг байна.');
    }
    notifyListeners();
  }

  void validateAmount(String? val) {
    if (val != null && val.isNotEmpty) {
      _amountVal = ValidationModel(val, null);
    } else {
      _amountVal = ValidationModel(null, 'Алдаатай имэйл хаяг байна.');
    }
    notifyListeners();
  }

  void validateRqty(String? val) {
    if (val != null && val.isNotEmpty) {
      _amountVal = ValidationModel(val, null);
    } else {
      _amountVal = ValidationModel(null, 'Алдаатай имэйл хаяг байна.');
    }
    notifyListeners();
  }

  Future<Position> _getCurrentLocation(BuildContext context) async {
    servicePermission = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission) {
      message('Permission тохируулна уу');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  getLocation(BuildContext context) async {
    _currentLocation = await _getCurrentLocation(context);
    _latitude = _currentLocation!.latitude.toString().substring(0, 7);
    _longitude = _currentLocation!.longitude.toString().substring(0, 7);
    print('lat: $_latitude lng: $_longitude');
  }

  Future<dynamic> sendJaggerLocation(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _getCurrentLocation(context);
      if (prefs.getString('latitude') != latitude ||
          prefs.getString('longitude') != longitude) {
        await prefs.setString('latitude', latitude);
        await prefs.setString('longitude', longitude);
        final res = await apiPatch('update_shipment_location/',
            {"lat": latitude, "lon": longitude});
        if (res.statusCode == 200) {
          final response = convertData(res);
          return {
            'errorType': 1,
            'data': response,
            'message': 'Түгээгчийн байршлыг амжилттай илгээлээ.'
          };
        } else {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Түгээгчийн байршлыг илгээхэд алдаа гарлаа.'
          };
        }
      } else {
        return {
          'errorType': 1,
          'data': null,
          'message': 'Түгээгчийн байршил өөрчлөгдөөгүй байна.'
        };
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  bool isFetching = false;
  changeFetching() {
    isFetching = !isFetching;
    notifyListeners();
  }

  getShipmentHistory() async {
    try {
      changeFetching();
      final res = await apiGet('shipment/history/');
      if (res.statusCode == 200) {
        Map<String, dynamic> data = convertData(res);
        List<dynamic> ships = data['results'];
        shipments = (ships).map((e) => Shipment.fromJson(e)).toList();
        changeFetching();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }

  filterShipment(String type, String value) async {
    try {
      final res = await apiGet('shipment/history/?$type=$value');
      if (res.statusCode == 200) {
        Map<String, dynamic> data = convertData(res);
        shipments.clear();
        List<dynamic> ships = data['results'];
        debugPrint('ships: $data');
        shipments = (ships).map((e) => Shipment.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class ValidationModel {
  String? value;
  String? error;
  ValidationModel(this.value, this.error);
}
