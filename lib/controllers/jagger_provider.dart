import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/controllers/models/jagger.dart';
import 'package:pharmo_app/controllers/models/jagger_expense_order.dart';
import 'package:pharmo_app/controllers/models/ship.dart';
import 'package:pharmo_app/controllers/models/shipment.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  final List<Jagger> _jaggers = <Jagger>[];
  List<Jagger> get jaggers => _jaggers;

  List<JaggerExpenseOrder> expenses = <JaggerExpenseOrder>[];

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

  List<Shipment> shipments = <Shipment>[];
  bool isStartDate = true;
  void toggleIsStartDate() {
    isStartDate = !isStartDate;
    notifyListeners();
  }

  bool sending = false;
  setSending(bool n) {
    sending = n;
    notifyListeners();
  }

  final List<Ship> _ships = <Ship>[];
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

  Timer? timer;

  Future start(int id, BuildContext context) async {
    // final pref = await SharedPreferences.getInstance();
    if (timer != null && timer!.isActive) {
      print("Timer is already active. Skipping start...");
      return;
    }

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        // int? id = pref.getInt('onDeliveryId');
        print("Sending location...");
        getLocation(context);
        await sendJaggerLocation(id, context);
        setSending(true);
      },
    );

    print("Timer started.");
    notifyListeners();
  }

  void stop() {
    if (timer != null && timer!.isActive) {
      print("Timer is active. Canceling it now...");
      timer!.cancel();
      timer = null;
      setSending(true);
    } else {
      print("Timer was already null or inactive.");
    }
    notifyListeners();
  }

  List<Delivery> delivery = [];
  List<Zone> zones = [];

  Future<dynamic> getDeliveries() async {
    try {
      http.Response response = await apiGet('delivery/delman_active/');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        delivery = (data as List).map((d) => Delivery.fromJson(d)).toList();
        for (final d in delivery) {
          zones = d.zones;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future getExpenses() async {
    try {
      final res = await apiGet('shipment_expense/');
      if (res.statusCode == 200) {
        final response = convertData(res);
        expenses.clear();
        expenses =
            (response['results'] as List).map((e) => JaggerExpenseOrder.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> startShipment(int shipmentId, BuildContext context) async {
    try {
      await getLocation(context);
      await Provider.of<HomeProvider>(context, listen: false).getPosition();
      await getLocation(context);
      final pref = await SharedPreferences.getInstance();
      var body = {"delivery_id": shipmentId, "lat": latitude, "lng": longitude};
      http.Response res = await apiPatch('delivery/start/', jsonEncode(body));
      print(res.body);
      if (res.statusCode == 200) {
        // final response = convertData(res);
        pref.setInt('onDeliveryId', shipmentId);
        await getDeliveries();
        setSending(true);
        start(shipmentId, context);
        message('Түгээлт эхлэлээ');
      } else {
        dynamic send = sendJaggerLocation(shipmentId, context);
        message(send['message']);
        message('Түгээлт эхлэхэд алдаа гарлаа');
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId, BuildContext context) async {
    try {
      var body = jsonEncode({"delivery_id": shipmentId});

      http.Response res = await apiPatch('delivery/end/', body);
      print(res.body);
      if (res.statusCode == 200) {
        final pref = await SharedPreferences.getInstance();
        print("Status code 200 received. Stopping the timer...");
        pref.remove('onDeliveryId');
        stop();
        await getDeliveries();
        message('Түгээлт дууслаа.');
        notifyListeners();
      } else {
        String data = res.body.toString();
        if (data.contains('UB!')) {
          message('Таний байршил Улаанбаатарт биш байна');
        } else {
          message('Түгээлт дуусгахад алдаа гарлаа.');
        }
      }
    } catch (e) {
      print("Error in endShipment: $e");
      return {'fail': e};
    }
    notifyListeners();
  }

  Future<dynamic> addExpense(String note, String amount, BuildContext context) async {
    try {
      final res = await apiPost('shipment_expense/', {"note": note, "amount": amount});
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
      var body = jsonEncode({"shipId": shipId, "itemId": itemId, "note": feedback.text});
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
      var body = jsonEncode({"shipId": shipId, "itemId": itemId, "note": feedback.text});
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
      final res = await apiPatch(
          'shipment_expense/$id/', jsonEncode({"note": note.text, "amount": amount.text}));
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
        return {'errorType': 2, 'data': null, 'message': 'Түгээлтийн зарлага засхад алдаа гарлаа.'};
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  updateQTY(int itemId, int qty) async {
    try {
      http.Response res =
          await apiPatch('update_item_qty/', jsonEncode({"itemId": itemId, "qty": qty}));
      print(res.body);
      if (res.statusCode == 200) {
        await getDeliveries();
        message('Амжилттай засагдлаа.');
      } else {
        if (res.body.contains('accepted')) {
          message('Хүлээн авсан захиалгыг өөрчлөх боломжгүй!');
        } else {
          message('Алдаа гарлаа.');
        }
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

  String _latitude = '';
  String _longitude = '';
  String get latitude => _latitude;
  String get longitude => _longitude;

  getLocation(BuildContext context) async {
    _currentLocation = await _getCurrentLocation(context);
    _latitude = _currentLocation!.latitude.toString().substring(0, 7);
    _longitude = _currentLocation!.longitude.toString().substring(0, 7);
    print('lat: $_latitude lng: $_longitude');
    print("haha");
  }

  sendJaggerLocation(int deliveryId, BuildContext context) async {
    try {
      getLocation(context);
      http.Response res = await apiPatch('delivery/location/',
          jsonEncode({"delivery_id": deliveryId, "lat": _latitude, "lng": _longitude}));
      print(res.body);
      if (res.statusCode == 200) {
        return {'errorType': 1, 'data': null, 'message': 'Түгээгчийн байршлыг амжилттай илгээлээ.'};
      } else if (res.statusCode == 400) {
        if (res.body.toString().contains('not found!')) {
          return {'errorType': 2, 'data': null, 'message': 'Түгээлт олдсонгүй!'};
        } else if (res.body.toString().contains('not started!')) {
          return {
            'errorType': 4,
            'data': null,
            'message': 'Түгээгчийн байршлыг илгээхэд алдаа гарлаа.'
          };
        }
      } else {
        return {
          'errorType': 4,
          'data': null,
          'message': 'Түгээгчийн байршлыг илгээхэд алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {
        'errorType': 4,
        'data': null,
        'message': 'Түгээгчийн байршлыг илгээхэд алдаа гарлаа.'
      };
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

getLatOrLng(double p) {
  return p.toString().substring(0, 7);
}


//seller/get_delivery_zones/