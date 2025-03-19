import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/controllers/models/delman.dart';
import 'package:pharmo_app/controllers/models/jagger_expense_order.dart';
import 'package:pharmo_app/controllers/models/payment.dart';
import 'package:pharmo_app/controllers/models/shipment.dart';
import 'package:pharmo_app/main.dart';
import 'package:pharmo_app/utilities/location_service.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  List<JaggerExpenseOrder> expenses = <JaggerExpenseOrder>[];
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;
  TextEditingController amount = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController rQty = TextEditingController();
  TextEditingController feedback = TextEditingController();
  late bool servicePermission = false;
  late LocationPermission permission;
  List<Shipment> shipments = <Shipment>[];
  Position? _currentPosition;
  List<Delivery> delivery = [];
  List<Zone> zones = [];
  List<Order> orders = [];
  final List<LatLng> _routeCoords = [];
  LatLng? lastPosition;
  List<LatLng> get routeCoords => _routeCoords;
  List<Delman> delmans = [];
  List<Delivery> history = <Delivery>[];
  List<Payment> payments = [];

  Future<dynamic> getDeliveries() async {
    try {
      final response =
          await apiRequest('GET', endPoint: 'delivery/delman_active/');
      if (response!.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();

        print(data);
        delivery = (data as List).map((d) => Delivery.fromJson(d)).toList();
        for (final d in delivery) {
          zones = d.zones;
        }
        if (delivery.isNotEmpty) {
          await prefs.setInt('onDeliveryId', delivery[0].id);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<dynamic> getOrders() async {
    try {
      final response =
          await apiRequest('GET', endPoint: 'delivery/allocation/');
      if (response!.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        orders = (data as List).map((e) => Order.fromJson(e)).toList();
        orders.sort((a, b) =>
            a.orderer!.name.compareTo(b.orderer!.name)); // Sort by date

        notifyListeners();
        print(data);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<dynamic> addOrdersToDelivery(List<int> ords) async {
    try {
      if (ords.isEmpty) {
        message('Захиалга сонгоно уу!');
        return;
      }

      print('Orders being sent: $ords');
      final body = {"order_ids": ords.map((id) => id.toString()).toList()};

      final response = await apiRequest('PATCH',
          endPoint: 'delivery/add_to_delivery/', body: body);

      if (response == null) {
        message('Сервертэй холбогдож чадсангүй!');
        return;
      }

      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getOrders();
        message('Амжилттай нэмэгдлээ');
      } else {
        message('Захиалгуудыг түгээлтэд нэмэхэд алдаа гарлаа!');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      message('Сервертэй холбогдоход алдаа гарлаа!');
    }
    notifyListeners();
  }

  Future<dynamic> passOrdersToDelman(List<int> ords, int delId) async {
    try {
      if (ords.isEmpty) {
        message('Захиалга сонгоно уу!');
        return;
      }
      print('delivery man id: $delId');

      print('Orders being sent: $ords');
      final body = {
        "order_ids": ords.map((id) => id.toString()).toList(),
        "delman_id": delId
      };

      final response = await apiRequest('PATCH',
          endPoint: 'delivery/pass_drops/', body: body);

      if (response == null) {
        message('Сервертэй холбогдож чадсангүй!');
        return;
      }

      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getOrders();
        message('Амжилттай нэмэгдлээ');
      } else {
        print(ords.length);
        message(
            '${ords.length == 1 ? 'Захиалгыг' : 'Захиалгуудыг'} дамжуулахад алдаа гарлаа!');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      message('Сервертэй холбогдоход алдаа гарлаа!');
    }
    notifyListeners();
  }

  getDelmans() async {
    try {
      final response = await apiRequest('GET', endPoint: 'delivery/delmans/');
      if (response!.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        delmans = (data as List).map((del) => Delman.fromJson(del)).toList();
        notifyListeners();
        print(data);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getDeliveryDetail(int id) async {
    try {
      final response = await apiRequest('GET', endPoint: 'order/$id/');
      if (response!.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print(data);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  addPaymentToDeliveryOrder(int orderId, String payType, String value) async {
    final data = {"order_id": orderId, "pay_type": payType, "amount": value};
    try {
      final res =
          await apiRequest('POST', endPoint: 'order_payment/', body: data);
      if (res!.statusCode == 200 || res.statusCode == 201) {
        message('Амжилттай хадгалагдлаа');
        await getDeliveries();
        notifyListeners();
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future getExpenses() async {
    try {
      final res = await apiRequest("GET", endPoint: 'shipment_expense/');
      if (res!.statusCode == 200) {
        final response = convertData(res);
        expenses.clear();
        expenses = (response['results'] as List)
            .map((e) => JaggerExpenseOrder.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> startShipment(int shipmentId) async {
    try {
      servicePermission = await Geolocator.isLocationServiceEnabled();

      if (!servicePermission) {
        message('Permission тохируулна уу');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else if (permission == LocationPermission.deniedForever) {
        message('Permission тохируулна уу');
      } else {
        _currentPosition = await _getCurrentLocation();
        final pref = await SharedPreferences.getInstance();
        var body = {
          "delivery_id": shipmentId,
          "lat": _currentPosition!.latitude,
          "lng": _currentPosition!.longitude
        };
        final res =
            await apiRequest('PATCH', endPoint: 'delivery/start/', body: body);
        if (res!.statusCode == 200) {
          pref.setInt('onDeliveryId', shipmentId);
          await getDeliveries();
          LocationService().startTracking(shipmentId);
          message('Түгээлт эхлэлээ');
        } else {
          dynamic send = sendJaggerLocation(shipmentId);
          message(send['message']);
          message('Түгээлт эхлэхэд алдаа гарлаа');
        }
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> endShipment(int shipmentId) async {
    try {
      var body = {"delivery_id": shipmentId};
      final res =
          await apiRequest('PATCH', endPoint: 'delivery/end/', body: body);
      if (res!.statusCode == 200) {
        final pref = await SharedPreferences.getInstance();
        pref.remove('onDeliveryId');
        await getDeliveries();
        LocationService().stopTracking();
        flutterLocalNotificationsPlugin.show(
          0,
          'Түгээлт дууслаа',
          'Таны $shipmentId дугаартай түгээлт дууслаа.',
          platformChannelSpecifics,
        );
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

  Future<dynamic> addExpense(
      String note, String amount, BuildContext context) async {
    try {
      final res = await apiRequest('POST',
          endPoint: 'shipment_expense/',
          body: {"note": note, "amount": amount});
      if (res!.statusCode == 201) {
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
      var body = {"shipId": shipId, "itemId": itemId, "note": feedback.text};
      final res =
          await apiRequest('PATCH', endPoint: 'shipment_add_note/', body: body);
      if (res!.statusCode == 200) {
        message('Түгээлтийн тайлбар амжилттай нэмэгдлээ.');
        feedback.clear();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }

  Future<dynamic> setFeedback(int shipId, int itemId) async {
    try {
      var body = {"shipId": shipId, "itemId": itemId, "note": feedback.text};
      final res =
          await apiRequest('PATCH', endPoint: 'shipment_add_note/', body: body);
      if (res!.statusCode == 200) {
        message('Түгээлтийн тайлбар амжилттай нэмэгдлээ.');
        feedback.text = '';
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> editExpenseAmount(int id) async {
    try {
      final res = await apiRequest('PATCH',
          endPoint: 'shipment_expense/$id/',
          body: {"note": note.text, "amount": amount.text});

      if (res!.statusCode == 200) {
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
      final res = await apiRequest('PATCH',
          endPoint: 'update_item_qty/', body: {"itemId": itemId, "qty": qty});
      if (res!.statusCode == 200) {
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

  Future<Position> _getCurrentLocation() async {
    //servicePermission = await Geolocator.isLocationServiceEnabled();
    PermissionStatus servicePermission =
        await Permission.locationWhenInUse.request();
    if (!servicePermission.isGranted) {
      message('Permission тохируулна уу');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      Permission.locationWhenInUse.request();
      //permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  sendJaggerLocation(int deliveryId) async {
    try {
      final res =
          await apiRequest('PATCH', endPoint: 'delivery/location/', body: {
        "delivery_id": deliveryId,
        "lat": _currentPosition!.latitude,
        "lng": _currentPosition!.longitude
      });
      if (res!.statusCode == 200) {
        return {
          'errorType': 1,
          'data': null,
          'message': 'Түгээгчийн байршлыг амжилттай илгээлээ.'
        };
      } else if (res.statusCode == 400) {
        if (res.body.toString().contains('not found!')) {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Түгээлт олдсонгүй!'
          };
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

  getShipmentHistory() async {
    try {
      final res = await apiRequest('GET', endPoint: 'shipment/history/');
      if (res!.statusCode == 200) {
        final data = convertData(res);
        print(data);
        List<dynamic> ships = data['results'];
        history = (ships).map((e) => Delivery.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
    }
  }

  filterShipment(String type, String value) async {
    try {
      final res =
          await apiRequest('GET', endPoint: 'shipment/history/?$type=$value');
      if (res!.statusCode == 200) {
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

  addCustomerPayment(String type, String amount, String customerId) async {
    try {
      final data = {
        "customer_id": int.parse(customerId),
        "pay_type": type,
        "amount": amount
      };
      final res =
          await apiRequest('POST', endPoint: 'customer_payment/', body: data);
      if (res!.statusCode == 201) {
        message('Амжилттай бүртгэлээ');
        await getCustomerPayment();
      } else {
        message(wait);
      }
    } catch (e) {
      message(wait);
      debugPrint(e.toString());
    }
  }

  editCustomerPayment(
      String customerId, int payId, String payType, String amount) async {
    try {
      print(amount);
      final data = {
        "customer_id": int.parse(customerId),
        "payment_id": payId,
        "pay_type": payType,
        "amount": amount
      };
      final res =
          await apiRequest('PATCH', endPoint: 'customer_payment/', body: data);
      if (res!.statusCode == 200) {
        getCustomerPayment();
        message('Амжилттай хадгаллаа');
        await getCustomerPayment();
      } else {
        message(wait);
      }
    } catch (e) {
      message(wait);
      debugPrint(e.toString());
    }
  }

  getCustomerPayment() async {
    try {
      final res = await apiRequest('GET', endPoint: 'customer_payment/');
      if (res!.statusCode == 200) {
        final data = convertData(res);
        payments =
            (data as List).map((payment) => Payment.fromJson(payment)).toList();
        notifyListeners();
      } else {
        message(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      LatLng newPoint = LatLng(position.latitude, position.longitude);

      // Анхны байрлал эсвэл өмнөх цэгээс 10 метрээс хол бол шинэ цэг нэмэх
      if (lastPosition == null ||
          Geolocator.distanceBetween(
                  lastPosition!.latitude,
                  lastPosition!.longitude,
                  newPoint.latitude,
                  newPoint.longitude) >=
              10) {
        _routeCoords.add(newPoint);
        lastPosition = newPoint;
        notifyListeners();
      }
    });
  }
}
