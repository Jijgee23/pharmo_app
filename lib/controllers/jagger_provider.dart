// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/jagger.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:pharmo_app/models/ship.dart';
import 'package:pharmo_app/models/shipment.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  final int _count = 0;
  int get count => _count;

  late Basket _basket;
  Basket get basket => _basket;

  final List<Jagger> _jaggers = <Jagger>[];
  List<Jagger> get jaggers => _jaggers;

  List<JaggerExpenseOrder> jaggerOrders = <JaggerExpenseOrder>[];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;

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

  Future<dynamic> getJaggers(BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final res =
          await http.get(setUrl('shipment/'), headers: getHeader(bearerToken));
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        ships.clear();
        _ships =
            (response['results'] as List).map((e) => Ship.fromJson(e)).toList();
      } else {
        message(message: 'Алдаа гарлаа.', context: context);
      }
    } catch (e) {
      debugPrint(e.toString());
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future getExpenses() async {
    try {
      final res = await http.get(setUrl('shipment_expense/'),
          headers: getHeader(await getAccessToken()));
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        jaggerOrders.clear();
        jaggerOrders = (response['results'] as List)
            .map((e) => JaggerExpenseOrder.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> startShipment(
      int shipmentId, double? lat, double? lng, BuildContext context) async {
    try {
      await HomeProvider().getPosition();
      final res = await http.patch(setUrl('start_shipment/'),
          headers: getHeader(await getAccessToken()),
          body: jsonEncode({
            "shipmentId": shipmentId,
            "lat": (lat != null) ? lat : null,
            "lng": (lng != null) ? lng : null
          }));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        debugPrint(response);
        message(message: '$response цагт түгээлт эхлэлээ', context: context);
      } else {
        message(message: 'Түгээлт эхлэхэд алдаа гарлаа', context: context);
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId, double? lat, double? lng,
      bool force, BuildContext context) async {
    try {
      await HomeProvider().getPosition();
      final res = await http.patch(setUrl('end_shipment/'),
          headers: getHeader(await getAccessToken()),
          body: jsonEncode({
            "shipmentId": shipmentId,
            "lat": (lat != null) ? lat : null,
            "lng": (lng != null) ? lng : null,
            "force": force
          }));
      notifyListeners();
      if (res.statusCode == 200) {
        message(message: 'Түгээлт дууслаа.', context: context);
      } else {
        message(message: 'Түгээлт дуусгахад алдаа гарлаа.', context: context);
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> addExpense(
      String note, String amount, BuildContext context) async {
    try {
      final res = await http.post(setUrl('shipment_expense/'),
          headers: getHeader(await getAccessToken()),
          body: jsonEncode({"note": note, "amount": amount}));
      if (res.statusCode == 201) {
        await getExpenses();
        message(message: 'Түгээлтийн зарлага нэмэгдлээ.', context: context);
      } else {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        message(message: response['message'], context: context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  addnote(int shipId, int itemId, BuildContext context) async {
    try {
      final res = await http.patch(setUrl('shipment_add_note/'),
          headers: getHeader(await getAccessToken()),
          body: jsonEncode(
              {"shipId": shipId, "itemId": itemId, "note": feedback.text}));

      if (res.statusCode == 200) {
        message(
            message: 'Түгээлтийн тайлбар амжилттай нэмэгдлээ.',
            context: context);
        feedback.clear();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }

  Future<dynamic> setFeedback(
      int shipId, int itemId, BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}shipment_add_note/'),
          headers: getHeader(bearerToken),
          body: jsonEncode(
              {"shipId": shipId, "itemId": itemId, "note": feedback.text}));
      notifyListeners();
      if (res.statusCode == 200) {
        message(
            message: 'Түгээлтийн тайлбар амжилттай нэмэгдлээ.',
            context: context);
        feedback.text = '';
        // return {
        //   'errorType': 1,
        //   'data': response,
        //   'message': 'Түгээлтийн тайлбар амжилттай нэмэгдлээ.'
        // };
      } else {
        // return {'errorType': 2, 'data': null, 'message': res.body};
      }
    } catch (e) {
      debugPrint(e.toString());
      //  return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> editExpenseAmount(int id) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}shipment_expense/$id/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({"note": note.text, "amount": amount.text}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
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

  updateQTY(int itemId, int qty, BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      var res = await http.patch(setUrl('update_item_qty/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({"itemId": itemId, "qty": qty}));
      if (res.statusCode == 200) {
        await getJaggers(context);
        message(message: 'Амжилттай засагдлаа.', context: context);
      } else {
        message(message: 'Алдаа гарлаа.', context: context);
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
      message(message: 'Permission тохируулна уу', context: context);
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
  }

  Future<dynamic> sendJaggerLocation(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _getCurrentLocation(context);
      if (prefs.getString('latitude') != latitude ||
          prefs.getString('longitude') != longitude) {
        await prefs.setString('latitude', latitude);
        await prefs.setString('longitude', longitude);
        final res = await http.patch(setUrl('update_shipment_location/'),
            headers: getHeader(await getAccessToken()),
            body: jsonEncode({"lat": latitude, "lon": longitude}));
        notifyListeners();
        if (res.statusCode == 200) {
          final response = jsonDecode(utf8.decode(res.bodyBytes));
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
      final res = await http.get(
        setUrl('shipment/history/'),
        headers: getHeader(await getAccessToken()),
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> ships = data['results'];
        // debugPrint('ships: ${ships[0]}');
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
      final res = await http.get(
        setUrl('shipment/history/?$type=$value'),
        headers: getHeader(await getAccessToken()),
      );
      debugPrint(res.statusCode.toString());
      if (res.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
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
