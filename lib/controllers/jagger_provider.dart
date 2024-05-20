import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/jagger.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/models/jagger_order.dart';
import 'package:pharmo_app/models/jagger_order_item.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  final int _count = 0;
  int get count => _count;

  late Basket _basket;
  Basket get basket => _basket;

  final List<Jagger> _jaggers = <Jagger>[];
  List<Jagger> get jaggers => _jaggers;

  final List<JaggerExpenseOrder> _jaggerOrders = <JaggerExpenseOrder>[];
  List<JaggerExpenseOrder> get jaggerOrders => _jaggerOrders;

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

  Future<dynamic> getJaggers() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}shipment/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (res.statusCode == 200) {
        _jaggers.clear();
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        for (int i = 0; i < response['results'].length; i++) {
          Jagger jagger = Jagger.fromJson(response['results'][i]);
          if (jagger.inItems != null && jagger.inItems!.isNotEmpty) {
            jagger.jaggerOrders = (jagger.inItems)!.map((data) => JaggerOrder.fromJson(data)).toList();
          }
          if (jagger.jaggerOrders != null && jagger.jaggerOrders!.isNotEmpty) {
            for (int j = 0; j < jagger.jaggerOrders!.length; j++) {
              jagger.jaggerOrders![j].jaggerOrderItems = (jagger.jaggerOrders![j].items)!.map((d) => JaggerOrderItem.fromJson(d)).toList();
            }
          }
          _jaggers.add(jagger);
        }
        notifyListeners();
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай авчирлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> getJaggerOrders() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}shipment_expense/'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      _jaggerOrders.clear();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        for (int i = 0; i < response['results'].length; i++) {
          JaggerExpenseOrder jagger = JaggerExpenseOrder.fromJson(response['results'][i]);
          _jaggerOrders.add(jagger);
        }
        notifyListeners();
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай авчирлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт авчрахад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'fail': e};
    }
  }

  Future<dynamic> startShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}start_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай эхэллээ.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт эхлэхэд алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}end_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай дууслаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт дуусгахад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'fail': e};
    }
  }

  Future<dynamic> textShipment(int shipmentId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}end_shipment/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipmentId": shipmentId}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        return {'errorType': 1, 'data': response, 'message': 'Түгээлт амжилттай дууслаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлт дуусгахад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'fail': e};
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }

  Future<dynamic> addExpenseAmount() async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.post(Uri.parse('${dotenv.env['SERVER_URL']}shipment_expense/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"note": note.text, "amount": amount.text}));
      notifyListeners();
      if (res.statusCode == 201) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        amount.text = '';
        note.text = '';
        return {'errorType': 1, 'data': response, 'message': 'Түгээлтийн зарлага амжилттай нэмэгдлээ.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлтийн зарлага нэмхэд алдаа гарлаа.'};
      }
    } catch (e) {
      print(e);
      return {'fail': e};
    }
  }

  Future<dynamic> setFeedback(int shipId, int itemId) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}shipment_add_note/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"shipId": shipId, "itemId": itemId, "note": feedback.text}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        feedback.text = '';
        return {'errorType': 1, 'data': response, 'message': 'Түгээлтийн тайлбар амжилттай нэмэгдлээ.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': res.body};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> editExpenseAmount(int id) async {
    try {
      String bearerToken = await getAccessToken();
      final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}shipment_expense/$id/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"note": note.text, "amount": amount.text}));
      notifyListeners();
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        await getJaggerOrders();
        amount.text = '';
        note.text = '';
        return {'errorType': 1, 'data': response, 'message': 'Түгээлтийн зарлага амжилттай засагдлаа.'};
      } else {
        return {'errorType': 2, 'data': null, 'message': 'Түгээлтийн зарлага засхад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {'fail': e};
    }
  }

  Future<dynamic> updateItemQTY(int itemId, bool add) async {
    try {
      String bearerToken = await getAccessToken();
      final http.Response res;
      if (add) {
        res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}update_item_qty/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
            body: jsonEncode({"itemId": itemId, "rQty": rQty.text, "add": add}));
      } else {
        res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}update_item_qty/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
            body: jsonEncode({"itemId": itemId, "rQty": rQty.text}));
      }
      if (res.statusCode == 200) {
        final response = jsonDecode(utf8.decode(res.bodyBytes));
        await getJaggers();
        rQty.text = '';
        notifyListeners();
        return {'errorType': 1, 'data': response, 'message': 'Түгээлтийн зарлага амжилттай засагдлаа.'};
      } else {
        notifyListeners();
        return {'errorType': 2, 'data': null, 'message': 'Түгээлтийн зарлага засхад алдаа гарлаа.'};
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();

    if (!servicePermission) {
      showFailedMessage(message: 'Permission тохируулна уу');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  getLocation() async {
    _currentLocation = await _getCurrentLocation();
    _latitude = _currentLocation!.latitude.toString().substring(0, 7);
    _longitude = _currentLocation!.longitude.toString().substring(0, 7);
  }

  Future<dynamic> sendJaggerLocation() async {
    try {
      String bearerToken = await getAccessToken();
      // print('lat: $latitude, long: $longitude');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (prefs.getString('latitude') != latitude || prefs.getString('longitude') != longitude) {
        await prefs.setString('latitude', latitude);
        await prefs.setString('longitude', longitude);
        final res = await http.patch(Uri.parse('${dotenv.env['SERVER_URL']}update_shipment_location/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
            body: jsonEncode({"lat": latitude, "lon": longitude}));
        notifyListeners();
        if (res.statusCode == 200) {
          final response = jsonDecode(utf8.decode(res.bodyBytes));
          return {'errorType': 1, 'data': response, 'message': 'Түгээгчийн байршлыг амжилттай илгээлээ.'};
        } else {
          return {'errorType': 2, 'data': null, 'message': 'Түгээгчийн байршлыг илгээхэд алдаа гарлаа.'};
        }
      } else {
        return {'errorType': 1, 'data': null, 'message': 'Түгээгчийн байршил өөрчлөгдөөгүй байна.'};
      }
    } catch (e) {
      return {'fail': e};
    }
  }
}

class ValidationModel {
  String? value;
  String? error;
  ValidationModel(this.value, this.error);
}
