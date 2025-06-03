import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/models/delman.dart';
import 'package:pharmo_app/models/payment.dart';
import 'package:pharmo_app/services/network_service.dart';
import 'package:pharmo_app/services/notification_service.dart';
import 'package:pharmo_app/services/settings.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class JaggerProvider extends ChangeNotifier {
  late bool servicePermission = false;
  late LocationPermission permission;
  Position? currentPosition;
  List<Delivery> delivery = [];
  List<Zone> zones = [];
  List<Order> orders = [];
  List<LatLng> routeCoords = [];
  List<Delman> delmans = [];
  List<Delivery> history = <Delivery>[];
  List<Payment> payments = [];
  bool isTracking = false;

  Future<dynamic> getDeliveryLocation() async {
    currentPosition = await Geolocator.getCurrentPosition();
    final pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');
    try {
      final response =
          await api(Api.get, 'delivery/locations/?with_routes=true');
      final data = convertData(response!);
      if (response.statusCode == 200) {
        final me = (data as List).firstWhere(
            (element) => element['delman']['id'] == userId,
            orElse: () => null);
        if (me == null) {
          return;
        }
        routeCoords = (me['routes'] as List)
            .map((r) => LatLng(parseDouble(r['lat']), parseDouble(r['lng'])))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  // TRACKING

  Future<dynamic> startShipment(int shipmentId) async {
    String mes = '';
    Box db = await Hive.openBox('track');
    try {
      if (!await Settings.checkAlwaysLocationPermission()) {
        return;
      }
      var body = {
        "delivery_id": shipmentId,
        "lat": currentPosition!.latitude,
        "lng": currentPosition!.longitude
      };
      final res = await api(Api.patch, 'delivery/start/', body: body);
      if (res!.statusCode == 200) {
        await db.delete('onDeliveryId');
        isTracking = true;
        mes = 'Түгээлт эхлэлээ';
        await startTracking();
      } else {
        isTracking = false;
        if (res.body.contains('Delivery already started!')) {
          mes =
              'Түгээлт аль хэдийн эхлэсэн байна!, Байршил дамжуулах дарна уу!';
        } else {
          mes = wait;
        }
      }
    } catch (e) {
      mes = wait;
      return {'fail as start': e};
    } finally {
      await db.put('onDeliveryId', shipmentId);
      message(mes);
    }
  }

  startTracking() async {
    Box db = await Hive.openBox('track');
    final onDeliveryId = await db.get('onDeliveryId');
    if (onDeliveryId == null) {
      return;
    }
    bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.ACTIVITY_TYPE_OTHER_NAVIGATION,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      ),
    );
    bg.BackgroundGeolocation.onLocation((pos) async {
      shareLocation(pos.coords.latitude, pos.coords.longitude);
    });
    await bg.BackgroundGeolocation.start().then((c) {
      print(c);

      if (c.enabled) {
        message('Байршил дамжуулж эхлэлээ!');
      }
    });
  }

  List<Loc> noSendedLocs = [];

  shareLocation(double lat, double lng) async {
    NMSG msg = NMSG(title: '', text: '');
    try {
      int? useIt;
      Box db = await Hive.openBox('track');
      final onDeliveryId = await db.get('onDeliveryId');
      if (useIt == null) {
        useIt = delivery[0].id;
      } else {
        useIt = onDeliveryId;
      }
      notifyListeners();
      print('sharing location');

      if (!await ConnectivityService.netWorkConnected()) {
        msg = NMSG(
            title: '📡 Сүлжээ тасарсан байна',
            text:
                'Интернет холболтоо шалгана уу. Байршлын дамжуулалт түр зогссон.');
        noSendedLocs.add(
          Loc(lat: lat, lng: lng, created: DateTime.now()),
        );
        notifyListeners();
        return;
      }

      final body = {
        "delivery_id": useIt,
        "locs": [
          if (noSendedLocs.isNotEmpty) ...noSendedLocs.map((l) => l.toJson(l)),
          {
            "lat": lat,
            "lng": lng,
            "created": DateTime.now().toIso8601String(),
          }
        ]
      };
      final res = await api(Api.patch, 'delivery/location/', body: body);
      print(res!.body);
      if (res != null && res.statusCode == 200) {
        getDeliveryLocation();
        msg = NMSG(
            title: 'Байршил дамжуулж байна',
            text:
                'Таны байршлыг арын төлөвт дамжуулж байна. өргөрөг: $lat уртраг: $lng');
        noSendedLocs.clear();
        notifyListeners();
      } else {
        msg = NMSG(
            title: 'Байршил дамжуулаагүй!',
            text: 'Байршил дамжуулах дарна уу!');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Notify.local(msg.title, msg.text);
    }
  }

  void stopTracking() {
    bg.BackgroundGeolocation.stop();
    isTracking = false;
    notifyListeners();
  }

  Future<dynamic> endShipment(int shipmentId) async {
    try {
      Box db = await Hive.openBox('track');
      final onDeliveryId = await db.get('onDeliveryId');
      print(onDeliveryId);
      var body = {"delivery_id": shipmentId};
      final res = await api(Api.patch, 'delivery/end/', body: body);
      if (res!.statusCode == 200) {
        Box db = await Hive.openBox('track');
        await db.delete('onDeliveryId');
        await getDeliveries();
        stopTracking();
        Notify.local(
            'Түгээлт дууслаа', 'Таны $shipmentId дугаартай түгээлт дууслаа.');
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

  Future<dynamic> getDeliveries() async {
    try {
      final response = await api(Api.get, 'delivery/delman_active/');
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
      final response = await api(Api.get, 'delivery/allocation/');
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

      final response =
          await api(Api.patch, 'delivery/add_to_delivery/', body: body);

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

      final response = await api(Api.patch, 'delivery/pass_drops/', body: body);

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
      final response = await api(Api.get, 'delivery/delmans/');
      if (response!.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        delmans = (data as List).map((del) => Delman.fromJson(del)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getDeliveryDetail(int id) async {
    try {
      final response =
          await api(Api.get, 'delivery/order_detail/?order_id=$id');
      final data = jsonDecode(utf8.decode(response!.bodyBytes));
      print(data);
      if (response.statusCode == 200) {}
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
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
      final res = await api(Api.get, url);
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
      final res = await api(Api.post, 'customer_payment/', body: data);
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
      final res = await api(Api.patch, 'customer_payment/', body: data);
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
      final res = await api(Api.get, 'customer_payment/');
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

  registerAdditionalDelivery(String note) async {
    try {
      await Settings.checkWhenUseLocationPermission();
      final data = {
        "note": note,
        "visited_on": DateTime.now().toString(),
        "lat": currentPosition!.latitude,
        "lng": currentPosition!.longitude
      };
      final response = await api(Api.post, 'delivery/addition/', body: data);
      if (response!.statusCode == 200 || response.statusCode == 201) {
        message('Амжилттай бүртгэлээ');
        await getDeliveries();
        await getDeliveryLocation();
      } else {
        message('Бүртгэл амжилтгүй');
      }
    } catch (e) {
      message(wait);
    }
  }

  editAdditionalDelivery(int id, String note) async {
    try {
      final data = {"note": note, 'item_id': id};
      final response = await api(Api.patch, 'delivery/addition/', body: data);
      if (response!.statusCode == 200 || response.statusCode == 201) {
        message('Амжилттай хадгаллаа');
        await getDeliveries();
      } else {
        message('Aмжилтгүй');
      }
    } catch (e) {
      message(wait);
    }
  }

  addPaymentToDeliveryOrder(int orderId, String payType, String value) async {
    final data = {"order_id": orderId, "pay_type": payType, "amount": value};
    try {
      final res = await api(Api.post, 'order_payment/', body: data);
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

  //map settings
  late GoogleMapController mapController;
  double zoomIndex = 14;
  bool trafficEnabled = false;
  Set<Marker> markers = {};
  zoomIn() {
    zoomIndex = zoomIndex + 1.0;
    mapController.animateCamera(CameraUpdate.zoomTo(zoomIndex));
    notifyListeners();
  }

  zoomOut() {
    zoomIndex = zoomIndex - 1.0;
    mapController.animateCamera(CameraUpdate.zoomTo(zoomIndex));
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void toggleTraffic() {
    trafficEnabled = !trafficEnabled;
    notifyListeners();
  }

  MapType mapType = MapType.terrain;

  void toggleView() {
    const mapTypes = [
      MapType.terrain,
      MapType.satellite,
      MapType.hybrid,
      MapType.normal
    ];
    mapType = mapTypes[(mapTypes.indexOf(mapType) + 1) % mapTypes.length];
    notifyListeners();
  }

  ScrollController scrollController = ScrollController();
  ScrollPhysics physics = AlwaysScrollableScrollPhysics();
  double aspectRatio = 3 / 2;
  toggleZoom() {
    if (aspectRatio == 3 / 2) {
      aspectRatio = 2.3 / 4;
      physics = NeverScrollableScrollPhysics();
    } else {
      aspectRatio = 3 / 2;
      physics = AlwaysScrollableScrollPhysics();
    }
    notifyListeners();
  }

  bool loading = false;
  setLoading(bool n) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loading = n;
      notifyListeners();
    });
  }

  reset() {
    routeCoords.clear();
    currentPosition = null;
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

class Loc {
  final double lat;
  final double lng;
  final DateTime created;
  Loc({
    required this.lat,
    required this.lng,
    required this.created,
  });

  toJson(Loc loc) {
    return {
      "lat": loc.lat,
      "lng": loc.lng,
      "created": loc.created.toIso8601String()
    };
  }
}

class NMSG {
  final String title;
  final String text;
  NMSG({
    required this.title,
    required this.text,
  });
}
