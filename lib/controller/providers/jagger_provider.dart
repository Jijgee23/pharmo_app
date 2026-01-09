import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/application/services/battery_service.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/services/log_service.dart';
import 'package:pharmo_app/controller/database/track_data.dart';
import 'package:pharmo_app/application/event/app_event.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'dart:math';

double truncateToDigits(double value, int digits) {
  num mod = pow(10.0, digits);
  return ((value * mod).round().toDouble() / mod);
}

const EventChannel bgLocationChannel = EventChannel('bg_location_stream');

class JaggerProvider extends ChangeNotifier implements WidgetsBindingObserver {
  final StreamController<AppEvent> _eventController =
      StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get mergedEvents => _eventController.stream;

  JaggerProvider() {
    timer = Timer.periodic(Duration(seconds: 1), (v) {
      now = DateTime.now();
      notifyListeners();
    });
    _setupStreams();
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _eventController.add(LifeCycleEvent(state));
  }

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() async => false;

  @override
  Future<bool> didPushRoute(String route) async => false;

  @override
  Future<bool> didPushRouteInformation(
          RouteInformation routeInformation) async =>
      false;

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _eventController.close();
  }

  void _setupStreams() {
    // locationSubscription =
    bgLocationChannel.receiveBroadcastStream().listen(
          (dynamic location) => _eventController.add(LocationEvent(location)),
        );
    // connectivitySubscription =
    Connectivity().onConnectivityChanged.listen(
          (List<ConnectivityResult> status) =>
              _eventController.add(NetworkEvent(status)),
        );
    // batterySubscription =
    Battery().onBatteryStateChanged.listen(
          (BatteryState state) => _eventController.add(BatteryEvent(state)),
        );
    AppLifecycleListener(
      onPause: () => _eventController.add(
        LifeCycleEvent(AppLifecycleState.paused),
      ),
      onResume: () => _eventController.add(
        LifeCycleEvent(AppLifecycleState.resumed),
      ),
    );
  }

  Future initJagger() async {
    if (Hive.isBoxOpen('track_box')) {
      trackBox = Hive.box('track_box');
      return;
    }
    trackBox = await Hive.openBox('track_box');
  }

  // TRACKING
  StreamSubscription? subscription;
  StreamSubscription? locationSubscription;
  StreamSubscription? connectivitySubscription;
  StreamSubscription? batterySubscription;
  late final Box<TrackData> trackBox;
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
  final LogService logService = LogService();
  final Battery battery = Battery();

  Future<void> startShipment(int shipmentId) async {
    setLoading(true);
    try {
      if (!await Settings.checkAlwaysLocationPermission()) {
        return;
      }
      var url = 'delivery/start/';
      currentPosition = await Geolocator.getCurrentPosition();
      if (currentPosition == null) return;
      var body = {
        "delivery_id": shipmentId,
        "lat": currentPosition!.latitude,
        "lng": currentPosition!.longitude
      };
      final res = await api(Api.patch, url, body: body);
      if (res == null) return;
      if (res.statusCode == 200) {
        addPointToBox(
          TrackData(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
            date: DateTime.now(),
          ),
        );
        await LocalBase.saveDelmanTrack(shipmentId).whenComplete(() async {
          final trackId = await LocalBase.getDelmanTrackId();
          if (trackId == 0) {
            message('Түгээлт олдсонгүй!');
            return;
          }
          await getDeliveries();
          await clearTrackData();
          await tracking();
        });
      } else if (res != null && res.statusCode == 400) {
        String data = convertData(res).toString();
        if (data.contains('already started')) {
          message('Түгээлт эхлэсэн байна!');
        }
      } else {
        message('Түр хүлээнэ үү!');
      }
    } catch (e) {
      message('Түр хүлээнэ үү!');
      print(e);
    } finally {
      setLoading(false);
    }
  }

  Future tracking() async {
    await getTrackBox();
    final user = LocalBase.security;
    if (user == null) return;
    bool isSeller = user.role == "S";
    bool hasDelmanTrack = await LocalBase.hasDelmanTrack();
    bool hasSellerTrack = await LocalBase.hasSellerTrack();
    if (isSeller && !hasSellerTrack) {
      return;
    }
    if (!isSeller && !hasDelmanTrack) {
      return;
    }
    int shipmentId = await LocalBase.getDelmanTrackId();
    try {
      subscription = mergedEvents.listen(
        (event) async {
          if (event is LocationEvent) {
            print("location changed: ${event.location}");
            final lat = parseDouble(event.location['lat']);
            final lng = parseDouble(event.location['lng']);
            await sendTobackend(isSeller, shipmentId, lat, lng);
          } else if (event is NetworkEvent) {
            final results = event.results;
            bool isMobile = results.contains(ConnectivityResult.mobile);
            bool isWifi = results.contains(ConnectivityResult.wifi);
            bool isEthernet = results.contains(ConnectivityResult.ethernet);
            if (isMobile || isWifi || isEthernet) {
              await logService.createLog(
                'Mobile',
                'Түгээлтийн явцад холболт сэргэсэн (${DateTime.now().toIso8601String()})',
              );
              await getTrackBox();
              syncOffineTracks();
            } else {
              await FirebaseApi.local(
                'Интернет тасарсан',
                'Интернет холболт тасарлаа. Холболтоо шалгана уу.',
              );
              await logService.createLog(
                'Mobile',
                'Түгээлтийн явцад холболт салсан  (${DateTime.now().toIso8601String()})',
              );
            }
          } else if (event is BatteryEvent) {
            print('Батерейны төлөв өөрчлөгдлөө: ${event.state}');
          } else if (event is LifeCycleEvent) {
            print('Аппликейшний төлөв өөрчлөгдлөө: ${event.state}');
            if (event.state == AppLifecycleState.paused) {
              await logService.createLog(
                'Mobile',
                'Түгээлтийн явцад бусад апп руу шилжсэн.  (${DateTime.now().toIso8601String()})',
              );
            }
          }
        },
      );
      if (subscription != null) {
        await BatteryService.startListenBattery();
      }
      timer = Timer.periodic(Duration(seconds: 1), (v) {
        now = DateTime.now();
        notifyListeners();
      });
      print("subscription started :${subscription != null}");
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void resumeTracking() {
    subscription!.resume();
    notifyListeners();
  }

  late Timer timer;
  DateTime now = DateTime.now();

  void stopTracking() async {
    subscription!.cancel();
    subscription = null;
    await locationSubscription?.cancel();
    locationSubscription = null;

    await connectivitySubscription?.cancel();
    connectivitySubscription = null;

    await batterySubscription?.cancel();
    batterySubscription = null;
    notifyListeners();
    await LocalBase.clearDelmanTrack();
    await LocalBase.removeSellerTrackId();
    await clearTrackData();
    await getTrackBox();
    routeCoords.clear();
    polylines.clear();
    orderMarkers.clear();
    markers.clear();
    notifyListeners();
  }

  Future sendTobackend(bool isSeller, int id, double lat, double lng) async {
    // String n_title, n_body = '';
    double latitude = truncateToDigits(lat, 6);
    double longitude = truncateToDigits(lng, 6);
    final now = DateTime.now();
    TrackData locatioData(bool sended) {
      return TrackData(
        latitude: latitude,
        longitude: longitude,
        sended: sended,
        date: now,
      );
    }

    Future notifyUnsend() async {
      await addPointToBox(locatioData(false));
    }

    Future handleSuccessSent() async {
      final text = 'Өрг: $latitude Урт: $longitude';
      final lastNotifDate = await logService.getLastNotifDate();
      bool hasNotLastNotid = lastNotifDate == null;
      if (hasNotLastNotid ||
          (lastNotifDate != null &&
              now.difference(lastNotifDate) > Duration(minutes: 3))) {
        await FirebaseApi.local('Байршил илгээсэн', text);
        await logService.saveLastNotif(now);
      }
      await addPointToBox(locatioData(true));
      await getDeliveries();
      await getDeliveryLocation();
      await syncOffineTracks();
    }

    final trackUrl = isSeller ? 'seller/location/' : 'delivery/location/';
    final apiMethod = isSeller ? Api.post : Api.patch;
    var body = locationResponse(id, [locatioData(true)]);
    final res = await api(apiMethod, trackUrl, body: body);
    final sended =
        res != null && (res.statusCode == 200 || res.statusCode == 201);
    // print(res!.body);
    print('sended: $sended');
    if (sended) {
      await handleSuccessSent();
      return;
    }
    await notifyUnsend();
  }

  Future syncOffineTracks() async {
    await getTrackBox();
    final user = LocalBase.security;
    if (user == null) return;
    bool hasDelmanTrack = await LocalBase.hasDelmanTrack();
    bool hasSellerTrack = await LocalBase.hasSellerTrack();
    if (!hasSellerTrack && !hasDelmanTrack) return;
    bool isSeller = user.role == "S";
    final trackUrl = isSeller ? 'seller/location/' : 'delivery/location/';
    final apiMethod = isSeller ? Api.post : Api.patch;
    if (trackDatas.isNotEmpty) {
      final unsended = trackDatas.where((e) => e.sended == false).toList();
      if (unsended.isEmpty) {
        print('no offline tracks');
        return;
      }
      var b = locationResponse(await LocalBase.getDelmanTrackId(), unsended);
      print('syncync offline data: $b');
      final r = await api(apiMethod, trackUrl, body: b);
      if (r != null && r.statusCode == 200) {
        await updateDatasToSended();
      }
    }
  }

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
        updatePolylines();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Map<String, Object> locationResponse(int id, List<TrackData> locs) {
    final user = LocalBase.security;
    if (user == null) return {};
    bool isSeller = user.role == "S";
    if (isSeller) {
      return {
        "locations": [
          ...locs.map((e) {
            return {
              "lat": truncateToDigits(e.latitude, 6),
              "lng": truncateToDigits(e.longitude, 6),
              "created": DateTime.now().toIso8601String()
            };
          })
        ]
      };
    }
    return {
      "delivery_id": id,
      "locs": [
        ...locs.map(
          (e) => {
            "lat": truncateToDigits(e.latitude, 6),
            "lng": truncateToDigits(e.longitude, 6),
            "created": e.date.toIso8601String(),
          },
        )
      ]
    };
  }

  // offline track datas
  List<TrackData> trackDatas = [];
  Set<Polyline> polylines = {};

  void updatePolylines() {
    polylines = {
      // Polyline(
      //   polylineId:
      //       PolylineId('sended_${DateTime.now().millisecondsSinceEpoch}'),
      //   points:
      //       routeCoords.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      //   color: Colors.blue,
      //   width: 5,
      //   zIndex: 10,
      // ),
      Polyline(
        polylineId:
            PolylineId('sended_${DateTime.now().millisecondsSinceEpoch}'),
        points: trackDatas
            .where((e) => e.sended)
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
        color: Colors.teal,
        width: 5,
      ),
      Polyline(
        polylineId:
            PolylineId('unsended_${DateTime.now().millisecondsSinceEpoch}'),
        points: trackDatas
            .where((e) => !e.sended)
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
        color: Colors.redAccent,
        width: 5,
      ),
    };
    notifyListeners();
  }

  bool followUser = true;

  Future addPointToBox(TrackData td) async {
    if (!Hive.isBoxOpen('track_box')) return;
    final newLoc = LatLng(td.latitude, td.longitude);
    await trackBox.add(td);
    await getTrackBox();
    updatePolylines();
    _updateBearing(newLoc);
  }

  Future getTrackBox() async {
    if (!Hive.isBoxOpen('track_box')) return;
    trackDatas = trackBox.values.toList().cast<TrackData>();
    notifyListeners();
  }

  _updateBearing(LatLng newLatLng) async {
    if (trackDatas.isEmpty) return 0.0;
    markers.clear();
    final last = trackDatas.last;
    final bear = calculateBearing(
      LatLng(last.latitude, last.longitude),
      newLatLng,
    );
    markers.add(
      Marker(
        markerId: MarkerId('myMarkerId'),
        position: newLatLng,
        icon: await readIcon(),
        rotation: bear,
      ),
    );
    notifyListeners();
  }

  Future clearTrackData() async {
    if (!Hive.isBoxOpen('track_box')) return;
    await trackBox.clear();
    await trackBox.flush();
    trackDatas.clear();
    notifyListeners();
    await getTrackBox();
  }

  Future updateDatasToSended() async {
    if (!Hive.isBoxOpen('track_box')) return;
    var list = trackBox.values;
    for (var d in list) {
      if (d.sended == false) {
        d.sended = true;
      }
    }
    await getTrackBox();
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
        await logService.createLog('end_shipment', 'Түгээлт дуусгасан');
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
        if (delivery.isNotEmpty) {
          final currentdelivery = delivery[0];
          for (var order in currentdelivery.orders) {
            if (order.orderer != null && order.orderer!.lat != null) {
              orderMarkers.add(
                Marker(
                  markerId: MarkerId(order.orderNo),
                  position: LatLng(
                    parseDouble(order.orderer!.lat),
                    parseDouble(order.orderer!.lng),
                  ),
                  infoWindow: InfoWindow(
                    title: order.orderer!.name,
                    snippet: 'Захиалагч',
                  ),
                  icon: await BitmapDescriptor.asset(
                    ImageConfiguration.empty,
                    'assets/box.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              );
              notifyListeners();
            }
            if (order.customer != null && order.customer!.lat != null) {
              orderMarkers.add(
                Marker(
                  markerId: MarkerId(order.orderNo),
                  position: LatLng(
                    parseDouble(order.customer!.lat),
                    parseDouble(order.customer!.lng),
                  ),
                  infoWindow: InfoWindow(
                    title: order.customer!.name,
                    snippet: 'Харилцагч',
                  ),
                  icon: await BitmapDescriptor.asset(
                    ImageConfiguration.empty,
                    'assets/box.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              );
              notifyListeners();
            }
          }
        }
        print(markers.length);

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

  Future addOrdersToDelivery(List<int> ords) async {
    try {
      if (ords.isEmpty) {
        message('Захиалга сонгоно уу!');
        return;
      }

      print('Orders being sent: $ords');
      final body = {"order_ids": ords.map((id) => id.toString()).toList()};
      final url = 'delivery/add_to_delivery/';
      final response = await api(Api.patch, url, body: body);
      if (response == null) {
        message('Сервертэй холбогдож чадсангүй!');
        return;
      }
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getOrders();
        HomeProvider home =
            Provider.of<HomeProvider>(Get.context!, listen: false);
        home.changeIndex(0);
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
  Set<Marker> orderMarkers = {};

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
    goToMyLocation();
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
    if (mapController == null) return;
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16, bearing: bearing, tilt: tilt),
      ),
    );
  }

  double tilt = 90;
  double bearing = 0;
  void updateTilt(double v) {
    tilt = v;
    notifyListeners();
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

  Future<BitmapDescriptor> readIcon() async {
    final result = await BitmapDescriptor.asset(
      ImageConfiguration.empty,
      'assets/car.png',
      width: 30,
      height: 30,
    );
    return result;
  }

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}

double calculateBearing(LatLng last, LatLng current) {
  return Geolocator.bearingBetween(
    last.latitude,
    last.longitude,
    current.latitude,
    current.longitude,
  );
}

double calculateTotalDistanceKm(List<TrackData> points) {
  if (points.length < 2) return 0;

  double totalMeters = 0;

  for (int i = 0; i < points.length - 1; i++) {
    totalMeters += Geolocator.distanceBetween(
      points[i].latitude,
      points[i].longitude,
      points[i + 1].latitude,
      points[i + 1].longitude,
    );
  }

  return totalMeters / 1000;
}

bool success(Response<dynamic>? response) {
  if (response == null) {
    return false;
  }
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  }
  return false;
}
