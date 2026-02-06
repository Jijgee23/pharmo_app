import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';

enum TrackState {
  none(Colors.green, 'эхлүүлэх'),
  tracking(Colors.red, 'дуусгах'),
  paused(Colors.orange, 'үргэлжлүүлэх');

  final Color btnColor;
  final String name;
  const TrackState(this.btnColor, this.name);
}

class JaggerProvider extends ChangeNotifier {
  JaggerProvider() {
    initJagger();
  }

  bool isShowingTrackingInfo = true;
  void toggleShowing() {
    isShowingTrackingInfo = !isShowingTrackingInfo;
    notifyListeners();
  }

  Future initJagger() async {
    await tracking();
    if (Hive.isBoxOpen('track_box')) {
      trackBox = Hive.box('track_box');
      return;
    }
    trackBox = await Hive.openBox('track_box');
  }

  // TRACKING
  StreamSubscription? subscription;
  late final Box<TrackData> trackBox;

  Position? currentPosition;
  Delivery? delivery;
  List<Zone> zones = [];
  List<LatLng> routeCoords = [];
  List<Payment> payments = [];
  final LogService logService = LogService();

  LocationPermission? permission;
  LocationAccuracyStatus? accuracy;

  Future loadPermission() async {
    final value = await Geolocator.checkPermission();
    permission = value;
    if (value == LocationPermission.always ||
        value == LocationPermission.whileInUse) {
      final newAccuracy = await Geolocator.getLocationAccuracy();
      accuracy = newAccuracy;
    }
    notifyListeners();
  }

  TrackState trackState = TrackState.none;
  Future loadTrackState() async {
    bool hasTrack = await Authenticator.hasTrack();
    if (!hasTrack) {
      trackState = TrackState.none;
      notifyListeners();
      print('TRACK STATE LOADED: $trackState');
      return;
    }
    bool serviceRunning = await NativeChannel.isServiceRunning();

    if (!serviceRunning && subscription == null) {
      trackState = TrackState.paused;
      notifyListeners();
      print('TRACK STATE LOADED: $trackState');
      return;
    }
    trackState = TrackState.tracking;
    notifyListeners();
    print('TRACK STATE LOADED: $trackState');
  }

  String salerStartedOn = '';
  Future<int> checkSellerTrack() async {
    await Authenticator.initAuthenticator();
    final user = Authenticator.security;
    if (user == null) return 0;
    if (user.isSaler) {
      final r = await api(Api.get, 'sales/route/?active=1');
      if (r == null) return 0;
      if (r.statusCode == 200) {
        final data = convertData(r);
        if (data['count'] == 0) return 0;
        final isActive = (data['results'] as List).isNotEmpty;
        final delid = isActive ? data['results'][0]['id'] : 0;
        salerStartedOn = data['results'][0]['started_on'] ?? '';
        await Authenticator.saveTrackId(delid);
        notifyListeners();
        await loadTrackState();
        return delid;
      }
    }
    return 0;
  }

  Future toggleTracking() async {
    await loadTrackState();
    if (trackState == TrackState.tracking) {
      await endTrack();
      return;
    }
    if (trackState == TrackState.paused) {
      print('TRACK PAUSED,  RESUMING TRACK...');
      await tracking();
      return;
    }
    await startShipment();
  }

  Future<void> startShipment() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    currentPosition = await Geolocator.getCurrentPosition();
    if (currentPosition == null) {
      messageWarning(
        'Одоогийн байршил олдсонгүй!, Байршил тогтоогчоо асаарна уу!',
      );
      return;
    }
    final user = Authenticator.security;

    if (user == null) return;

    bool isDriver = user.isDriver;
    String url = isDriver ? 'delivery/start/' : 'sales/route/';
    String action = isDriver ? 'түгээлт' : 'борлуулалт';
    final shipmentId = await Authenticator.getTrackId();

    final confirmed = await confirmDialog(
      context: GlobalKeys.navigatorKey.currentContext!,
      title: '${action.capitalize} эхлүүлэх үү?',
      message:
          '${action.capitalize}-ийн үед таны байршлыг хянахыг анхаарна уу!',
    );

    if (!confirmed) return;

    setLoading(true);
    try {
      var body = isDriver
          ? {
              "delivery_id": shipmentId,
              "lat": truncateToSixDigits(currentPosition!.latitude),
              "lng": truncateToSixDigits(currentPosition!.longitude)
            }
          : {
              "locations": [
                {
                  "lat": truncateToSixDigits(currentPosition!.latitude),
                  "lng": truncateToSixDigits(currentPosition!.longitude),
                  "created": DateTime.now().toIso8601String(),
                }
              ]
            };

      final r = await api(Api.patch, url, body: body);
      if (r == null) return;
      if (r.statusCode == 200) {
        messageComplete('$action амжилттай эхлэлээ!');

        if (isDriver) {
          await getDeliveries();
        }
        if (!isDriver) {
          await checkSellerTrack();
        }

        await clearTrackData();
        await addPointToBox(
          TrackData(
            latitude: currentPosition!.latitude,
            longitude: currentPosition!.longitude,
            date: DateTime.now(),
            sended: true,
          ),
        );
        addMarker(
          AssetIcon.flag,
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
        );

        await Authenticator.saveTrackId(
                isDriver ? shipmentId : await checkSellerTrack())
            .whenComplete(
          () async {
            final trackId = await Authenticator.getTrackId();
            if (trackId == 0) {
              messageWarning('${{action.capitalize}} олдсонгүй!');
              return;
            }
            await tracking();
          },
        );
      } else if (r != null && r.statusCode == 400) {
        String data = convertData(r).toString();
        if (data.contains('already started')) {
          messageWarning('Түгээлт эхлэсэн байна!');
        }
      } else {
        messageWarning('Түр хүлээнэ үү!');
      }
    } catch (e) {
      messageWarning('Түр хүлээнэ үү!');
      print(e);
    } finally {
      setLoading(false);
    }
  }

  Future tracking() async {
    if (!await Authenticator.hasTrack()) return;
    await getTrackBox();
    if (Authenticator.security!.isSaler) {
      await checkSellerTrack();
    }
    try {
      subscription =
          NativeChannel.bgLocationChannel.receiveBroadcastStream().listen(
        (event) async {
          print("location changed: $event");
          final lat = parseDouble(event['lat']);
          final lng = parseDouble(event['lng']);
          await sendTobackend(lat, lng);
        },
      );
      await Future.delayed(Duration(milliseconds: 500));

      final started = await NativeChannel.startLocationService();
      if (!started) {
        messageError('Location service эхлүүлж чадсангүй');
        return;
      }
      timer = Timer.periodic(Duration(seconds: 1), (v) {
        now = DateTime.now();
        notifyListeners();
      });
      print("subscription started :${subscription != null}");
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await loadTrackState();
    }
  }

  Future<dynamic> endTrack() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    currentPosition = await Geolocator.getCurrentPosition();
    if (currentPosition == null) {
      messageWarning(
        'Одоогийн байршил олдсонгүй!, Байршил тогтоогчоо асаарна уу!',
      );
      return;
    }
    final user = Authenticator.security;

    if (user == null) return;

    bool isDriver = user.isDriver;
    String action = isDriver ? 'түгээлт' : 'борлуулалт';

    final confirmed = await confirmDialog(
      context: GlobalKeys.navigatorKey.currentContext!,
      title: '${action.capitalize} дуусгах үү?',
    );

    if (!confirmed) return;
    try {
      final current = await Geolocator.getCurrentPosition();
      final shipmentId = await Authenticator.getTrackId();
      var body = {
        if (isDriver) "delivery_id": shipmentId,
        "lat": truncateToSixDigits(current.latitude),
        "lng": truncateToSixDigits(current.longitude),
        "created": DateTime.now().toIso8601String(),
      };
      final trackUrl = isDriver ? 'delivery/end/' : 'sales/route/end/';

      final r = await api(Api.patch, trackUrl, body: body);
      if (r == null) {
        messageError('Сервертэй холбогдож чадсангүй!');
        return;
      }
      if (r.statusCode == 200) {
        if (isDriver) {
          await getDeliveries();
        }
        await stopTracking();
        messageComplete('Таны $shipmentId дугаартай $action дууслаа.');
        await logService.createLog(
          '${action.capitalize}',
          '${action.capitalize} дуусгасан',
        );
      } else {
        String data = r.body.toString();
        if (data.contains('UB!')) {
          messageWarning('Таний байршил Улаанбаатарт биш байна');
        } else {
          messageWarning('$action дуусгахад алдаа гарлаа.');
        }
      }
    } catch (e) {
      print("Error in endTrack: $e");
      return {'fail': e};
    }
    notifyListeners();
  }

  TrackData? lastPoint;

  void updateLastPoint(TrackData value) {
    lastPoint = value;
    notifyListeners();
  }

  late Timer timer;
  DateTime now = DateTime.now();

  Future stopTracking() async {
    try {
      await syncOffineTracks();
      await subscription!.cancel();
      await NativeChannel.stopLocationService();
      await Authenticator.clearTrackId();
      await loadTrackState();
      await clearTrackData();
      subscription = null;
      routeCoords.clear();
      polylines.clear();
      orderMarkers.clear();
      notifyListeners();
      if (subscription != null) {
        subscription = null;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      throw Exception(e);
    } finally {
      await loadTrackState();
    }
  }

  DateTime? _lastUploadTime;

  final int _uploadIntervalSeconds = 5;

  Future sendTobackend(double lat, double lng) async {
    await loadTrackState();
    double latitude = truncateToSixDigits(lat);
    double longitude = truncateToSixDigits(lng);
    final now = DateTime.now();

    await getTrackBox();

    if (lastPoint != null) {
      double distance = Geolocator.distanceBetween(
        lastPoint!.latitude,
        lastPoint!.longitude,
        lat,
        lng,
      );
      if (distance < 10) return;
    }

    TrackData locatioData(bool sended) {
      return TrackData(
        latitude: latitude,
        longitude: longitude,
        sended: sended,
        date: now,
      );
    }

    final hasInternet = await NetworkChecker.hasInternet();
    if (!hasInternet) {
      await addPointToBox(locatioData(false));
      return;
    }

    if (_lastUploadTime != null &&
        now.difference(_lastUploadTime!).inSeconds < _uploadIntervalSeconds) {
      return;
    }
    final isSeller = Authenticator.security!.isSaler;
    final trackUrl = isSeller ? 'sales/route/' : 'delivery/location/';
    var body = locationr(
      await Authenticator.getTrackId(),
      [locatioData(true)],
    );
    final r = await api(Api.patch, trackUrl, body: body);
    if (r != null && apiSucceess(r)) {
      _lastUploadTime = now;
      await addPointToBox(locatioData(true));
      await syncOffineTracks();
      if (!isSeller) {
        await getDeliveries();
      }
      return;
    }
    await addPointToBox(locatioData(false));
  }

  Future syncOffineTracks() async {
    await getTrackBox();
    final user = Authenticator.security;
    if (user == null) return;
    bool hasTrack = await Authenticator.hasTrack();
    // bool hasSellerTrack = await Authenticator.hasSellerTrack();
    if (!hasTrack) return;
    bool isSeller = user.isSaler;
    final trackUrl = isSeller ? 'sales/route/' : 'delivery/location/';
    if (trackDatas.isNotEmpty) {
      final unsended = trackDatas.where((e) => e.sended == false).toList();
      if (unsended.isEmpty) {
        return;
      }
      var b = locationr(await Authenticator.getTrackId(), unsended);
      final r = await api(Api.patch, trackUrl, body: b);
      if (apiSucceess(r)) {
        await updateDatasToSended();
      }
    }
  }

  Map<String, Object> locationr(int id, List<TrackData> locs) {
    final user = Authenticator.security;
    if (user == null) return {};
    bool isSeller = user.role == "S";
    if (isSeller) {
      return {
        "locations": [
          ...locs.toSet().map((e) {
            return {
              "lat": truncateToSixDigits(e.latitude),
              "lng": truncateToSixDigits(e.longitude),
              "created": DateTime.now().toIso8601String()
            };
          })
        ]
      };
    }
    return {
      "delivery_id": id,
      "locs": [
        ...locs.toSet().map(
              (e) => {
                "lat": truncateToSixDigits(e.latitude),
                "lng": truncateToSixDigits(e.longitude),
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

  Future addPointToBox(TrackData td) async {
    if (!Hive.isBoxOpen('track_box')) return;
    await trackBox.add(td);
    updateLastPoint(td);
    await getTrackBox();
    updatePolylines();
  }

  Future deletePointFromBox(TrackData td) async {
    if (!Hive.isBoxOpen('track_box')) return;
    await trackBox.delete(td);
    await getTrackBox();
    updatePolylines();
  }

  Future getTrackBox() async {
    if (!Hive.isBoxOpen('track_box')) return;
    trackDatas = trackBox.values.toList().cast<TrackData>();
    if (trackDatas.isNotEmpty) {
      updateLastPoint(trackDatas.last);
      addMarker(
        AssetIcon.flag,
        position: LatLng(
          trackDatas.first.latitude,
          trackDatas.first.longitude,
        ),
        infoWindow: InfoWindow(title: 'Эхлэлийн цэг'),
      );
    }
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

  Future<dynamic> getDeliveries() async {
    try {
      final r = await api(Api.get, 'delivery/delman_active/');
      if (r == null) {
        return;
      }
      if (r.statusCode == 200) {
        final data = jsonDecode(utf8.decode(r.bodyBytes)) as List;
        if (data.isEmpty) {
          delivery == null;
          notifyListeners();
          return;
        }

        delivery = Delivery.fromJson(data[0]);
        if (delivery == null) return;
        for (var order in delivery!.orders) {
          if (order.orderer != null && order.orderer!.lat != null) {
            addMarker(
              AssetIcon.box,
              position: LatLng(
                parseDouble(order.orderer!.lat),
                parseDouble(order.orderer!.lng),
              ),
              infoWindow: InfoWindow(
                title: order.orderer!.name,
                snippet: 'Захиалагч',
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
        zones = delivery!.zones;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  addCustomerPayment(String type, String amount, String customerId) async {
    try {
      final data = {
        "customer_id": int.parse(customerId),
        "pay_type": type,
        "amount": amount
      };
      final r = await api(Api.post, 'customer_payment/', body: data);
      if (r == null) return;
      if (r.statusCode == 201) {
        messageComplete('Амжилттай бүртгэлээ');
        await getCustomerPayment();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      messageWarning(wait);
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
      final r = await api(Api.patch, 'customer_payment/', body: data);
      if (r == null) return;
      if (r.statusCode == 200) {
        getCustomerPayment();
        messageComplete('Амжилттай хадгаллаа');
        await getCustomerPayment();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      messageWarning(wait);
      debugPrint(e.toString());
    }
  }

  getCustomerPayment() async {
    try {
      final r = await api(Api.get, 'customer_payment/');
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r);
        print(data);
        payments =
            (data as List).map((payment) => Payment.fromJson(payment)).toList();
        notifyListeners();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future registerAdditionalDelivery(String note) async {
    try {
      await Settings.checkWhenUseLocationPermission();
      final loc = await Geolocator.getCurrentPosition();
      if (loc == null) {
        messageWarning('Байршил тодорхойлж чадсангүй!');
        return;
      }
      final data = {
        "note": note,
        "visited_on": DateTime.now().toString(),
        "lat": loc.latitude,
        "lng": loc.longitude
      };
      final r = await api(Api.post, 'delivery/addition/', body: data);
      print(r!.statusCode);
      if (r == null) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Амжилттай бүртгэлээ');
        await getDeliveries();
      } else {
        messageWarning('Бүртгэл амжилтгүй');
      }
    } catch (e) {
      messageWarning(wait);
    }
  }

  editAdditionalDelivery(int id, String note) async {
    try {
      final data = {"note": note, 'item_id': id};
      final r = await api(Api.patch, 'delivery/addition/', body: data);
      if (r == null) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Амжилттай хадгаллаа');
        await getDeliveries();
      } else {
        messageWarning('Aмжилтгүй');
      }
    } catch (e) {
      messageWarning(wait);
    }
  }

  addPaymentToDeliveryOrder(int orderId, String payType, String value) async {
    final data = {"order_id": orderId, "pay_type": payType, "amount": value};
    try {
      final r = await api(Api.post, 'order_payment/', body: data);
      if (r == null) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Амжилттай хадгалагдлаа');
        await getDeliveries();
        notifyListeners();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //map settings
  late GoogleMapController mapController;
  double zoomIndex = 14;
  bool trafficEnabled = false;
  // Set<Marker> markers = {};
  Set<Marker> orderMarkers = {};

  void addMarker(String icon,
      {required LatLng position, InfoWindow? infoWindow}) async {
    final mid = DateTime.now().millisecondsSinceEpoch.toString();
    orderMarkers.add(
      Marker(
        markerId: MarkerId(icon + mid),
        infoWindow: infoWindow ?? InfoWindow(title: icon),
        position: position,
        icon: await readIcon(icon),
      ),
    );
    notifyListeners();
  }

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
    if (mapController != null) {
      goToMyLocation();
    }
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
    if (permission == null ||
        (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse)) {
      return;
    }
    if (mapController == null) {
      return;
    }
    final n = await Geolocator.getCurrentPosition();
    if (n != null) latLng = LatLng(n.latitude, n.longitude);
    notifyListeners();
    if (mapController == null) return;
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16),
      ),
    );
  }

  Future gotoWithNative(LatLng value) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: value, zoom: zoomIndex),
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

  Future reset() async {
    routeCoords.clear();
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
      notifyListeners();
    }
    zones.clear();
    currentPosition = null;
    delivery = null;
    payments.clear();
    notifyListeners();
  }

  Future<BitmapDescriptor> readIcon(String assetPath) async {
    final rult = await BitmapDescriptor.asset(
      ImageConfiguration.empty,
      assetPath,
      width: 30,
      height: 30,
    );
    return rult;
  }
}





















 // Future<dynamic> getDeliveryLocation() async {
  //   currentPosition = await Geolocator.getCurrentPosition();
  //   final security = await Authenticator.getSecurity();
  //   if (security == null) return;
  //   try {
  //     final r = await api(Api.get, 'delivery/locations/?with_routes=true');
  //     if (r!.statusCode == 200) {
  //       final data = convertData(r);
  //       final me = (data as List).firstWhere(
  //           (element) => element['delman']['id'] == security.id,
  //           orElse: () => null);
  //       if (me == null) {
  //         return;
  //       }
  //       routeCoords = (me['routes'] as List)
  //           .map((r) => LatLng(parseDouble(r['lat']), parseDouble(r['lng'])))
  //           .toList();
  //       notifyListeners();
  //       updatePolylines();
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     notifyListeners();
  //   }
  // }
    // final text = 'Өрг: $latitude Урт: $longitude';
      // final lastNotifDate = await logService.getLastNotifDate();
      // bool hasNotLastNotid = lastNotifDate == null;
      // if (hasNotLastNotid ||
      //     (lastNotifDate != null &&
      //         now.difference(lastNotifDate) > Duration(minutes: 3))) {
      //   await FirebaseApi.local('Байршил илгээсэн', text);
      //   await logService.saveLastNotif(now);
      // }