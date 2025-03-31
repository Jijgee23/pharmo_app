import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/controllers/models/delman.dart';
import 'package:pharmo_app/controllers/models/payment.dart';
import 'package:pharmo_app/main.dart';
import 'package:pharmo_app/utilities/location_service.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerProvider extends ChangeNotifier {
  late bool servicePermission = false;
  late LocationPermission permission;
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
        orders.sort((a, b) => a.orderer!.name.compareTo(b.orderer!.name));

        notifyListeners();
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
      final body = {"order_ids": ords, "delman_id": delId};

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
      final response = await apiRequest('GET',
          endPoint: 'delivery/order_detail/?order_id=$id');
      final data = jsonDecode(utf8.decode(response!.bodyBytes));
      print(data);
      if (response.statusCode == 200) {}
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<dynamic> getDeliveryLocation(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');
    print(userId);
    try {
      final response = await apiRequest('GET',
          endPoint: 'delivery/locations/?with_routes=true');
      final data = jsonDecode(utf8.decode(response!.bodyBytes));
      // print(data);
      if (response.statusCode == 200) {
        final myRoutes = (data as List).firstWhere(
            (element) => element['delman']['id'] == userId,
            orElse: () => null);
        print(myRoutes);
        List<LatLng> d = (myRoutes['routes'] as List)
            .map((r) => LatLng(parseDouble(r['lat']), parseDouble(r['lng'])))
            .toList();
        routeCoords.addAll(d);
        notifyListeners();
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

  Future<dynamic> startShipment(int shipmentId) async {
    try {
      final s = await Geolocator.checkPermission();
      await Geolocator.requestPermission();
      bool location = await Geolocator.isLocationServiceEnabled();
      if (!location) {
        await Geolocator.requestPermission();
        if (s == LocationPermission.deniedForever) {
          getMessage();
        }
      } else {
        if (s == LocationPermission.always) {
          _currentPosition = await _getCurrentLocation();
          final pref = await SharedPreferences.getInstance();
          var body = {
            "delivery_id": shipmentId,
            "lat": _currentPosition!.latitude,
            "lng": _currentPosition!.longitude
          };
          final res = await apiRequest('PATCH',
              endPoint: 'delivery/start/', body: body);
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
        } else {
          getMessage();
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

  getShipmentHistory({DateTimeRange? range}) async {
    try {
      String url;

      if (range != null) {
        String date1 = range.start.toString().substring(0, 10);
        String date2 = range.end.toString().substring(0, 10);
        url = 'delivery/history/?start=$date1&end=$date2';
      } else {
        url = "delivery/history/";
      }

      final res = await apiRequest('GET', endPoint: url);

      print(res!.body);

      if (res.statusCode == 200) {
        final data = convertData(res);
        print(data);
        List<dynamic> ships = data['results'];
        history = (ships).map((e) => Delivery.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Алдаа гарлаа: ${e.toString()}');
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

  reset() {
    _routeCoords.clear();
    lastPosition = null;
    delivery.clear();
    zones.clear();
    orders.clear();
    delmans.clear();
    history.clear();
    payments.clear();
    delivery.clear();
    notifyListeners();
  }
}
