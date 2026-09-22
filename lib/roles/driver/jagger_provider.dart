import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/application/application.dart';

enum TrackState {
  none(Colors.green, 'эхлүүлэх', Icons.play_arrow_rounded),
  tracking(Colors.red, 'дуусгах', Icons.stop_rounded),
  paused(Colors.orange, 'үргэлжлүүлэх', Icons.play_arrow_rounded);

  final Color btnColor;
  final String label;
  final IconData icon;
  const TrackState(this.btnColor, this.label, this.icon);
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
    if (Hive.isBoxOpen('track_box')) {
      trackBox = Hive.box('track_box');
    } else {
      trackBox = await Hive.openBox('track_box');
    }
    await tracking();
  }

  // TRACKING
  StreamSubscription? subscription;
  Timer? _permissionCheckTimer;
  late final Box<TrackData> trackBox;

  Position? currentPosition;
  Delivery? delivery;
  List<Zone> zones = [];
  List<LatLng> routeCoords = [];
  List<Payment> payments = [];
  final LogService logService = LogService();

  LocationPermission? permission;
  LocationAccuracyStatus? accuracy;

  bool _isGrantedPermission(LocationPermission? value) =>
      value == LocationPermission.always || value == LocationPermission.whileInUse;

  Future loadPermission() async {
    final previous = permission;
    final value = await Geolocator.checkPermission();
    permission = value;
    if (_isGrantedPermission(value)) {
      final newAccuracy = await Geolocator.getLocationAccuracy();
      accuracy = newAccuracy;
    }

    // A user can revoke location permission from system Settings while a
    // tracking session stays active in the background — the app never
    // observes that unless something diffs old vs. new permission here.
    if (_isGrantedPermission(previous) &&
        !_isGrantedPermission(value) &&
        trackState == TrackState.tracking) {
      final isSeller = Authenticator.security?.isSaler ?? false;
      await logService.createLog(
        isSeller ? 'Борлуулалт' : 'Түгээлт',
        'Байршлын зөвшөөрөл цуцлагдсан. (${DateTime.now().toIso8601String()})',
      );
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
        if (!isActive) return 0;
        final delid = data['results'][0]['id'];
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
      await resumeTracking();
      return;
    }
    await startShipment();
  }

  // Native tracking filters every point against MAX_ACCURACY_METERS=25, but
  // these Dart-side entry/exit fixes bypass that filter entirely — a bad
  // seed fix here becomes the trip's origin (lastPoint), skewing every
  // later distance-floor decision in sendTobackend(). Retries a couple of
  // times for a fix at least as accurate as the native threshold, falling
  // back to the best one seen rather than blocking the flow indefinitely.
  Future<Position> _getAccuratePosition({
    double maxAccuracyMeters = 25,
    int retries = 2,
  }) async {
    Position? best;
    for (var i = 0; i <= retries; i++) {
      try {
        final p = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 5),
          ),
        );
        if (best == null || p.accuracy < best.accuracy) best = p;
        if (p.accuracy <= maxAccuracyMeters) return p;
      } on TimeoutException {
        // GPS hasn't resolved within 5s (indoors, cold start) — try again,
        // or fall through to the unbounded-time fallback below once retries
        // are exhausted. Previously uncaught: this exception propagated
        // straight out of goToMyLocation()/startShipment()/endTrack(),
        // crashing the flow instead of just taking longer to get a fix.
        continue;
      }
    }
    if (best != null) return best;
    // Every attempt timed out and we never got a single fix — one last
    // call with no time limit rather than giving up, matching the
    // unbounded behavior the raw Geolocator.getCurrentPosition() calls
    // this helper replaced always had.
    return Geolocator.getCurrentPosition();
  }

  Future<void> startShipment() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    currentPosition = await _getAccuratePosition();
    if (currentPosition == null) {
      messageWarning(
        'Одоогийн байршил олдсонгүй!, Байршил тогтоогчоо асаарна уу!',
      );
      return;
    }
    final user = Authenticator.security;

    if (user == null) return;

    bool isDriver = user.isDeliveryCapable;
    String url = isDriver ? 'delivery/start/' : 'sales/route/';
    String action = isDriver ? 'түгээлт' : 'борлуулалт';
    final shipmentId = await Authenticator.getTrackId();

    final confirmed = await confirmDialog(
      title: '${action.capitalize} эхлүүлэх үү?',
      message: '${action.capitalize}-ийн үед таны байршлыг хянахыг анхаарна уу!',
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

        int sellerTrackId = 0;
        if (isDriver) {
          await getDeliveries();
        } else {
          sellerTrackId = await checkSellerTrack();
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
          infoWindow: InfoWindow(title: 'Эхлэл'),
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
        );

        await Authenticator.saveTrackId(isDriver ? shipmentId : sellerTrackId).whenComplete(
          () async {
            final trackId = await Authenticator.getTrackId();
            if (trackId == 0) {
              messageWarning('${action.capitalize} олдсонгүй!');
              return;
            }
            await tracking();
          },
        );
      } else if (r.statusCode == 400) {
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

  Future<void> resumeTracking() async {
    bool confirmed = await confirmDialog(
      title: 'Байршил хянах үйлчилгээг үргэлжлүүлэх үү?',
      message: 'Таны байршлыг хянах үйлчилгээг үргэлжлүүлэх үү?',
    );
    if (!confirmed) return;
    await tracking();
    await loadTrackState();
    final user = Authenticator.security;
    if (user == null) return;
    if (user.isSaler) {
      await checkSellerTrack();
    }
    if (user.isDeliveryCapable) {
      await getDeliveries();
    }
  }

  Future tracking() async {
    if (!await Authenticator.hasTrack()) return;
    await getTrackBox();
    final user = Authenticator.security;
    if (user == null) return;
    if (user.isSaler) {
      await checkSellerTrack();
    }
    try {
      subscription = NativeChannel.bgLocationChannel.receiveBroadcastStream().listen(
        (event) async {
          print("location changed: $event");
          final lat = parseDouble(event['lat']);
          final lng = parseDouble(event['lng']);
          await sendTobackend(lat, lng);
        },
        onError: (Object e) async {
          debugPrint('location stream error: $e');
          if (e is PlatformException && e.code == 'permission_denied') {
            final isSeller = Authenticator.security?.isSaler ?? false;
            await logService.createLog(
              isSeller ? 'Борлуулалт' : 'Түгээлт',
              'Байршлын зөвшөөрөл татгалзсан: ${e.message} (${DateTime.now().toIso8601String()})',
            );
          }
        },
      );

      final started = await NativeChannel.startLocationService();
      if (!started) {
        messageError('Location service эхлүүлж чадсангүй');
        await subscription?.cancel();
        subscription = null;
        return;
      }
      _permissionCheckTimer?.cancel();
      _permissionCheckTimer = Timer.periodic(
        const Duration(seconds: 20),
        (_) => loadPermission(),
      );
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
    currentPosition = await _getAccuratePosition();
    if (currentPosition == null) {
      messageWarning(
        'Одоогийн байршил олдсонгүй!, Байршил тогтоогчоо асаарна уу!',
      );
      return;
    }
    final user = Authenticator.security;

    if (user == null) return;

    bool isDriver = user.isDeliveryCapable;
    String action = isDriver ? 'түгээлт' : 'борлуулалт';
    // List<DeliveryOrder>? orders = delivery?.orders;
    List<DeliveryOrder> unDeliveredOrders = [];
    if (isDriver && delivery != null) {
      unDeliveredOrders = delivery!.orders.where((t) => t.isOnDelivery).toList();
    }

    final confirmed = await confirmDialog(
      title: '${action.capitalize} дуусгах үү?',
      message:
          '${action.capitalize} дуусах үед таны байршлыг хянахыг зогсооно. ${isDriver && unDeliveredOrders.isNotEmpty ? 'Мөн ${unDeliveredOrders.length} захиалга хүргэгдээгүй байна!' : ''}',
    );

    if (!confirmed) return;
    try {
      final current = await _getAccuratePosition();
      final shipmentId = await Authenticator.getTrackId();
      var body = {
        if (isDriver) "delivery_id": delivery != null ? delivery!.id : shipmentId,
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
        String data = convertData(r).toString();
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

  // late Timer timer;
  DateTime now = DateTime.now();

  Future stopTracking() async {
    try {
      await syncOffineTracks();
      await subscription?.cancel();
      subscription = null;
      _permissionCheckTimer?.cancel();
      _permissionCheckTimer = null;
      await NativeChannel.stopLocationService();
      await Authenticator.clearTrackId();
      await clearTrackData();
      routeCoords.clear();
      polylines.clear();
      orderMarkers.clear();
      notifyListeners();
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
    // await loadTrackState();
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
      // Deliberately not queued (unlike every other rejection path below):
      // this is near-duplicate noise suppression mirroring the native
      // filter's own distance floor, not a deferred send — persisting it
      // would reintroduce the clutter this check exists to prevent.
      if (distance < 6) return;
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
      await addPointToBox(locatioData(false));
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

  bool _isSyncing = false;
  static const int _syncChunkSize = 200;

  // A snapshot-then-mark-only-that-snapshot design: unlike marking "every
  // currently unsent record" as sent, this can't flag a point that was
  // inserted concurrently (e.g. from a native stream event arriving mid
  // network round-trip) as sent when it was never actually part of the
  // PATCH that succeeded. `_isSyncing` also prevents two of the three
  // callers of this method (sendTobackend's success path, ConnectionProvider
  // on reconnect, stopTracking) from racing each other in the first place.
  Future syncOffineTracks() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await getTrackBox();
      final user = Authenticator.security;
      if (user == null) return;
      bool hasTrack = await Authenticator.hasTrack();
      if (!hasTrack) return;
      bool isSeller = user.isSaler;
      final trackUrl = isSeller ? 'sales/route/' : 'delivery/location/';
      final unsended = trackDatas.where((e) => e.sended == false).toList();
      if (unsended.isEmpty) return;

      for (var i = 0; i < unsended.length; i += _syncChunkSize) {
        final end = (i + _syncChunkSize < unsended.length) ? i + _syncChunkSize : unsended.length;
        final chunk = unsended.sublist(i, end);
        final b = locationr(await Authenticator.getTrackId(), chunk);
        final r = await api(Api.patch, trackUrl, body: b);
        if (!apiSucceess(r)) break; // stop; the rest retries on the next trigger
        await updateDatasToSended(chunk);
      }
    } finally {
      _isSyncing = false;
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
              "created": e.date.toIso8601String()
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
        polylineId: PolylineId('sended_${DateTime.now().millisecondsSinceEpoch}'),
        points:
            trackDatas.where((e) => e.sended).map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color: Colors.teal,
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
      Polyline(
        polylineId: PolylineId('unsended_${DateTime.now().millisecondsSinceEpoch}'),
        points:
            trackDatas.where((e) => !e.sended).map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color: Colors.redAccent,
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
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

  bool _startMarkerAdded = false;

  Future getTrackBox() async {
    if (!Hive.isBoxOpen('track_box')) return;
    trackDatas = trackBox.values.toList().cast<TrackData>();
    if (trackDatas.isNotEmpty) {
      updateLastPoint(trackDatas.last);
      // getTrackBox() runs on every accepted point (via addPointToBox), so
      // without this guard the start-flag marker would be re-added once per
      // point for the whole session instead of once per trip.
      if (!_startMarkerAdded) {
        _startMarkerAdded = true;
        addMarker(
          AssetIcon.flag,
          position: LatLng(
            trackDatas.first.latitude,
            trackDatas.first.longitude,
          ),
          infoWindow: InfoWindow(title: 'Эхлэлийн цэг'),
        );
      }
    }
    notifyListeners();
  }

  Future clearTrackData() async {
    if (!Hive.isBoxOpen('track_box')) return;
    await trackBox.clear();
    await trackBox.flush();
    trackDatas.clear();
    _startMarkerAdded = false;
    notifyListeners();
    await getTrackBox();
  }

  Future updateDatasToSended(List<TrackData> confirmed) async {
    if (!Hive.isBoxOpen('track_box')) return;
    for (var d in confirmed) {
      d.sended = true;
      await d.save();
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
        final data = convertData(r) as List;
        if (data.isEmpty) {
          print('No active deliveries found for the driver.');
          delivery = null;
          notifyListeners();
          print(delivery?.created);
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
      final data = {"customer_id": int.parse(customerId), "pay_type": type, "amount": amount};
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

  editCustomerPayment(String customerId, int payId, String payType, String amount) async {
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
        payments = (data as List).map((payment) => Payment.fromJson(payment)).toList();
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
      if (r == null) return;
      print(r.statusCode);
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
  GoogleMapController? mapController;
  double zoomIndex = 14;
  bool trafficEnabled = false;
  // Set<Marker> markers = {};
  Set<Marker> orderMarkers = {};

  void addMarker(String icon, {required LatLng position, InfoWindow? infoWindow}) async {
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
    mapController?.animateCamera(CameraUpdate.zoomTo(zoomIndex));
    notifyListeners();
  }

  zoomOut() {
    zoomIndex = zoomIndex - 1.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(zoomIndex));
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
    goToMyLocation();
  }

  /// Call from the GoogleMap-hosting widget's dispose() — the platform
  /// view (and this controller) dies with it, so any later use (an
  /// in-flight goToMyLocation()'s Geolocator await resuming after the
  /// user switched tabs, a background location tick, ...) would
  /// otherwise throw "used after disposed".
  void clearMapController() {
    mapController = null;
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
        (permission != LocationPermission.always && permission != LocationPermission.whileInUse)) {
      return;
    }
    if (mapController == null) {
      return;
    }
    final n = await _getAccuratePosition();
    latLng = LatLng(n.latitude, n.longitude);
    notifyListeners();
    if (mapController == null) return;
    await mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16),
      ),
    );
  }

  Future gotoWithNative(LatLng value) async {
    if (mapController == null) return;
    await mapController!.animateCamera(
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
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = null;
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
