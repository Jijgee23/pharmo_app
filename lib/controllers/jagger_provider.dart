import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/database/loc_box.dart';
import 'package:pharmo_app/database/loc_model.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/services/log_service.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/models/a_models.dart';

const EventChannel bgLocationChannel = EventChannel('bg_location_stream');

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
    final security = await LocalBase.getSecurity();
    if (security == null) return;
    try {
      final r = await api(Api.get, 'delivery/locations/?with_routes=true');
      if (r!.statusCode == 200) {
        final data = convertData(r);
        final me = (data as List).firstWhere(
            (element) => element['delman']['id'] == security.id,
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

  void deleteFromLocalDb(LocModel model) async {
    await LocBox.deleteModel(model);
  }

  void addLocModelToLocalDb(LocModel model) async {
    await LocBox.addToList(model);
  }

  final LogService logService = LogService();

  Future sendTobackend(int id, double lat, double lng) async {
    var body = locationResponse(
      id,
      [LocModel(lat: lat, lng: lng, success: true)],
    );
    String url = 'delivery/location/';
    double latitude = truncateToDigits(lat, 6);
    double longitude = truncateToDigits(lng, 6);
    final res = await api(Api.patch, url, body: body);
    if (res!.statusCode == 200 || res.statusCode == 201) {
      final lastNotifDate = await logService.getLastNotifDate();
      final now = DateTime.now();
      if (lastNotifDate == null ||
          (lastNotifDate != null &&
              now.difference(lastNotifDate) > Duration(minutes: 3))) {
        await FirebaseApi.local(
          'Байршил илгээсэн',
          'Өрг: $latitude Урт: $longitude',
        );
        await logService.saveLastNotif(now);
      }
      await getDeliveryLocation();
      await getDeliveries();
      if (noSendedLocs.isNotEmpty) {
        final nosended = await LocBox.getList();
        var b = locationResponse(id, nosended);
        final r = await api(Api.patch, url, body: b);
        if (r != null && r.statusCode == 200) {
          noSendedLocs.clear();
          notifyListeners();
          await LocBox.clearAll();
        }
      }
    } else {
      await FirebaseApi.local('Илгээгдээгүй байршил хадгалагдлаа', '');
      addLocModelToLocalDb(
        LocModel(
          lat: latitude,
          lng: longitude,
          success: false,
          data: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Map<String, Object> locationResponse(int id, List<LocModel> locs) {
    return {
      "delivery_id": id,
      "locs": [
        ...locs.map(
          (e) => {
            "lat": e.lat,
            "lng": e.lng,
            "created": e.data ?? DateTime.now().toIso8601String(),
          },
        )
      ]
    };
  }

  // TRACKING
  StreamSubscription? positionSubscription;

  Future<dynamic> startShipment(int shipmentId) async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    var url = 'delivery/start/';
    currentPosition = await Geolocator.getCurrentPosition();
    var body = {
      "delivery_id": shipmentId,
      "lat": currentPosition!.latitude,
      "lng": currentPosition!.longitude
    };
    final res = await api(Api.patch, url, body: body);
    if (res!.statusCode == 200) {
      await LocalBase.saveDelmanTrack(shipmentId);
      await getDeliveries();
      tracking();
    } else if (res != null && res.statusCode == 400) {
      String data = convertData(res).toString();
      if (data.contains('already started')) {
        message('Түгээлт эхлэсэн байна!');
      }
    } else {
      message('Түр хүлээнэ үү!');
    }
  }

  Future tracking({bool force = false}) async {
    int shipmentId = await LocalBase.getDelmanTrackId();
    if (shipmentId == 0 && !force) {
      return;
    }
    if (force) {
      var current = await Geolocator.getCurrentPosition();
      sendTobackend(
        force ? delivery[0].id : shipmentId,
        parseDouble(current.latitude),
        parseDouble(current.longitude),
      );
    }
    try {
      positionSubscription = bgLocationChannel.receiveBroadcastStream().listen(
        (event) async {
          final data = event as Map<dynamic, dynamic>;
          debugPrint("data from native event: ${data.toString()}");
          await sendTobackend(
            force ? delivery[0].id : shipmentId,
            parseDouble(data['lat']),
            parseDouble(data['lng']),
          );
        },
        onError: (error) {
          FirebaseApi.local('Байршил дамжуулж чадсангүй', '');
          debugPrint('BG Location error: $error');
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void resumeTracking() {
    positionSubscription!.resume();
    notifyListeners();
  }

  List<Loc> noSendedLocs = [];

  void stopTracking() {
    positionSubscription?.cancel();
    positionSubscription = null;
    LocalBase.clearDelmanTrack();
    notifyListeners();
  } 

  Future<dynamic> endShipment(int shipmentId) async {
    try {
      var body = {"delivery_id": shipmentId};
      final res = await api(Api.patch, 'delivery/end/', body: body);
      if (res!.statusCode == 200) {
        await getDeliveries();
        await LocalBase.clearDelmanTrack();
        await FirebaseApi.local(
          'Түгээлт дууслаа',
          'Таны $shipmentId дугаартай түгээлт дууслаа.',
        );
        stopTracking();
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

  LatLng latLng = LatLng(47.90771, 106.88324);
  void updateLatLng(LatLng valeu) {
    latLng = valeu;
    notifyListeners();
  }

  MapType mapType = MapType.terrain;
  Future<void> goToMyLocation() async {
    if (mapController == null) {
      return;
    }

    final n = await Geolocator.getCurrentPosition();
    if (n != null) latLng = LatLng(n.latitude, n.longitude);
    notifyListeners();
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 16,
          bearing: 0,
          tilt: 150,
        ),
      ),
    );
  }

  ScrollController scrollController = ScrollController();

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
