import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/temperature_log/reading_reminder.dart';

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

  /// Location is being sent right now (not stopped or paused).
  bool get isTracking => subscription != null && !subscription!.isPaused;

  /// A start, resume or end is under way. They wait for a GPS fix first,
  /// which can take a while, so their buttons show it.
  bool busy = false;

  Future<void> _whileBusy(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future loadTrackState() async {
    bool hasTrack = await Authenticator.hasTrack();
    if (!hasTrack) {
      trackState = TrackState.none;
      notifyListeners();
      debugPrint('TRACK STATE LOADED: $trackState');
      return;
    }
    bool serviceRunning = await NativeChannel.isServiceRunning();

    if (!serviceRunning && subscription == null) {
      trackState = TrackState.paused;
      notifyListeners();
      debugPrint('TRACK STATE LOADED: $trackState');
      return;
    }
    trackState = TrackState.tracking;
    notifyListeners();
    debugPrint('TRACK STATE LOADED: $trackState');
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
      debugPrint('TRACK PAUSED,  RESUMING TRACK...');
      await resumeTracking();
      return;
    }
    await startShipment();
  }

  /// Starts the caller's delivery [deliveryId].
  Future<void> startDelivery(int deliveryId) => _whileBusy(() => _startShipment(deliveryId));

  Future<void> startShipment() => _whileBusy(() => _startShipment(null));

  // Native tracking filters every point against MAX_ACCURACY_METERS=25, but
  // these Dart-side entry/exit fixes bypass that filter entirely — a bad
  // seed fix here becomes the trip's origin (lastPoint), skewing every
  // later distance-floor decision in sendTobackend(). Retries a couple of
  // times for a fix at least as accurate as the native threshold, falling
  // back to the best one seen rather than blocking the flow indefinitely.
  // Null when no fix came at all.
  Future<Position?> _getAccuratePosition({
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
        // or fall through to the longer fallback below once retries are
        // exhausted. Previously uncaught: this exception propagated
        // straight out of goToMyLocation()/startShipment()/endTrack(),
        // crashing the flow instead of just taking longer to get a fix.
        continue;
      }
    }
    if (best != null) return best;
    // Every attempt timed out and we never got a single fix — one last,
    // longer wait rather than giving up at once. Bounded: with no time
    // limit a phone that never gets a fix left the button spinning for
    // good with nothing said.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 30)),
      );
    } on TimeoutException {
      return null;
    }
  }

  // [deliveryId] is the delivery a D/VS starts; null for a seller's route,
  // or to take the saved track id.
  Future<void> _startShipment(int? deliveryId) async {
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
    final shipmentId = deliveryId ?? await Authenticator.getTrackId();

    final confirmed = await confirmDialog(
      title: '${action.capitalize} эхлүүлэх үү?',
      message: '${action.capitalize}-ийн үед таны байршлыг хянахыг анхаарна уу!',
    );

    if (!confirmed) return;

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
          // Only a reminder: never holds up the start.
          unawaited(remindReading(LogSlot.start));
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
        _addTripMarker(
          'start',
          AssetIcon.flag,
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          'Эхлэл',
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
      debugPrint('startShipment: $e');
    }
  }

  Future<void> resumeTracking() => _whileBusy(_resumeTracking);

  Future<void> _resumeTracking() async {
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
          debugPrint("location changed: $event");
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
      debugPrint("subscription started :${subscription != null}");
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await loadTrackState();
    }
  }

  Future<void> endTrack() => _whileBusy(_endTrack);

  Future<void> _endTrack() async {
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
    // Not yet delivered, returned or closed.
    List<DeliveryOrder> unDeliveredOrders = [];
    if (isDriver && delivery != null) {
      unDeliveredOrders = delivery!.orders.where((t) => !t.isHandled).toList();
    }

    final confirmed = await confirmDialog(
      title: '${action.capitalize} дуусгах үү?',
      message:
          '${action.capitalize} дуусах үед таны байршлыг хянахыг зогсооно. ${isDriver && unDeliveredOrders.isNotEmpty ? 'Мөн ${unDeliveredOrders.length} захиалга хүргэгдээгүй байна!' : ''}',
    );

    if (!confirmed) return;
    try {
      // The fix just taken above if a fresh one doesn't come.
      final current = await _getAccuratePosition() ?? currentPosition!;
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
          // The history tab keeps its list; this delivery belongs on it.
          Get.context?.read<DriverProvider>().refreshHistory();
          unawaited(remindReading(LogSlot.end));
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
      debugPrint('endTrack: $e');
      messageWarning('$action дуусгахад алдаа гарлаа.');
    }
    notifyListeners();
  }

  TrackData? lastPoint;

  void updateLastPoint(TrackData value) {
    lastPoint = value;
    notifyListeners();
  }

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
      polylines.clear();
      _tripMarkers.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('stopTracking: $e');
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
        _addTripMarker(
          'start',
          AssetIcon.flag,
          LatLng(trackDatas.first.latitude, trackDatas.first.longitude),
          'Эхлэл',
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

  /// The first fetch of the active delivery has come back (either way).
  bool deliveriesLoaded = false;

  /// The last fetch failed, so [delivery] may be out of date or missing.
  bool deliveriesFailed = false;

  /// A refresh someone asked for is under way. The quiet ones (every few
  /// seconds while tracking, after each change) don't set it.
  bool deliveriesRefreshing = false;

  /// [getDeliveries], shown as loading while it runs; true once done.
  Future<bool> refreshDeliveries() async {
    if (deliveriesRefreshing) return false;
    deliveriesRefreshing = true;
    notifyListeners();
    try {
      return await getDeliveries();
    } finally {
      deliveriesRefreshing = false;
      notifyListeners();
    }
  }

  /// Fetches the caller's active delivery (GET delivery/delman_active/).
  /// True once it is known, even when there is none.
  Future<bool> getDeliveries() async {
    try {
      final r = await api(Api.get, 'delivery/delman_active/');
      if (r == null || r.statusCode != 200) {
        deliveriesFailed = true;
        return false;
      }
      final data = convertData(r) as List;
      delivery = data.isEmpty ? null : Delivery.fromJson(data[0]);
      if (delivery != null) zones = delivery!.zones;
      deliveriesFailed = false;
      frameDelivery();
      return true;
    } catch (e) {
      debugPrint('getDeliveries: $e');
      deliveriesFailed = true;
      return false;
    } finally {
      deliveriesLoaded = true;
      notifyListeners();
    }
  }

  /// Sets [order]'s delivery state (PATCH delivery/order/) and refreshes
  /// the delivery. True once it is set.
  Future<bool> setOrderProcess(DeliveryOrder order, OrderProcess process) async {
    try {
      final r = await api(Api.patch, 'delivery/order/', body: {
        'delivery_id': order.deliveryId != 0 ? order.deliveryId : delivery?.id,
        'order_id': order.id,
        'process': process.code,
      });
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return false;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await getDeliveries();
        messageComplete('Төлөв өөрчлөгдлөө');
        return true;
      }
      final body = apiBody(r);
      messageWarning(
        body.toString().contains('Delivery not started!')
            ? 'Түгээлт эхлээгүй байна!'
            : apiErrorMessage(body) ?? 'Төлөв өөрчлөхөд алдаа гарлаа!',
      );
    } catch (e) {
      debugPrint('setOrderProcess: $e');
      messageWarning('Сервертэй холбогдоход алдаа гарлаа!');
    }
    return false;
  }

  /// Records a payment from customer [customerId] (POST customer_payment/).
  /// True once it is recorded.
  Future<bool> addCustomerPayment(String type, String amount, int customerId) async {
    try {
      final data = {"customer_id": customerId, "pay_type": type, "amount": amount};
      final r = await api(Api.post, 'customer_payment/', body: data);
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return false;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Төлбөр бүртгэгдлээ');
        await getCustomerPayment();
        return true;
      }
      messageWarning(apiErrorMessage(apiBody(r)) ?? wait);
    } catch (e) {
      messageWarning(wait);
      debugPrint(e.toString());
    }
    return false;
  }

  editCustomerPayment(String customerId, int payId, String payType, String amount) async {
    try {
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
        payments = (data as List).map((payment) => Payment.fromJson(payment)).toList();
        notifyListeners();
      } else {
        messageWarning(wait);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Logs a visit at the caller's current spot (POST delivery/addition/).
  /// True once it is logged.
  Future<bool> registerAdditionalDelivery(String note) async {
    try {
      await Settings.checkWhenUseLocationPermission();
      final loc = await Geolocator.getCurrentPosition();
      final data = {
        "note": note,
        "visited_on": DateTime.now().toString(),
        "lat": loc.latitude,
        "lng": loc.longitude
      };
      final r = await api(Api.post, 'delivery/addition/', body: data);
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return false;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Амжилттай бүртгэлээ');
        await getDeliveries();
        return true;
      }
      messageWarning(apiErrorMessage(apiBody(r)) ?? 'Бүртгэл амжилтгүй');
    } catch (e) {
      debugPrint('registerAdditionalDelivery: $e');
      messageWarning('Байршил тодорхойлж чадсангүй!');
    }
    return false;
  }

  /// Changes a logged visit's note (PATCH delivery/addition/). True once
  /// it is saved.
  Future<bool> editAdditionalDelivery(int id, String note) async {
    try {
      final data = {"note": note, 'item_id': id};
      final r = await api(Api.patch, 'delivery/addition/', body: data);
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return false;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        messageComplete('Амжилттай хадгаллаа');
        await getDeliveries();
        return true;
      }
      messageWarning(apiErrorMessage(apiBody(r)) ?? 'Хадгалахад алдаа гарлаа');
    } catch (e) {
      messageWarning(wait);
    }
    return false;
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

  // Trip markers (the start flag), by id so adding one again replaces it.
  // The delivery's stops are drawn from [delivery] by the map itself.
  final Map<String, Marker> _tripMarkers = {};
  Set<Marker> get tripMarkers => _tripMarkers.values.toSet();

  Future<void> _addTripMarker(String id, String icon, LatLng position, String title) async {
    _tripMarkers[id] = Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: await readIcon(icon),
    );
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _framedDeliveryId = null;
    notifyListeners();
    frameDelivery();
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

  void setMapType(MapType type) {
    mapType = type;
    notifyListeners();
  }

  LatLng latLng = LatLng(47.90771, 106.88324);

  MapType mapType = MapType.normal;

  Future<void> goToMyLocation() async {
    if (permission == null ||
        (permission != LocationPermission.always && permission != LocationPermission.whileInUse)) {
      return;
    }
    if (mapController == null) {
      return;
    }
    final n = await _getAccuratePosition();
    if (n == null) return;
    latLng = LatLng(n.latitude, n.longitude);
    notifyListeners();
    if (mapController == null) return;
    await mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16),
      ),
    );
  }

  // The delivery the camera last framed, so refreshes (every few seconds
  // while tracking) don't keep moving it; -1 once it went to the caller.
  int? _framedDeliveryId;

  /// Frames the active delivery's stops and the caller, once per delivery
  /// and map unless [force]d; goes to the caller when there are no stops.
  Future<void> frameDelivery({bool force = false}) async {
    if (mapController == null) return;
    final d = delivery;
    final points = <LatLng>[
      if (d != null)
        for (final stop in d.stops)
          if (stop.coordinates case final c?) LatLng(c.$1, c.$2),
    ];
    if (d == null || points.isEmpty) {
      if (_framedDeliveryId != null && !force) return;
      _framedDeliveryId = -1;
      await goToMyLocation();
      return;
    }
    if (_framedDeliveryId == d.id && !force) return;
    _framedDeliveryId = d.id;
    final me = currentPosition;
    if (me != null) points.add(LatLng(me.latitude, me.longitude));
    await _fitTo(points);
  }

  Future<void> _fitTo(List<LatLng> points) async {
    final controller = mapController;
    if (controller == null || points.isEmpty) return;
    try {
      if (points.length == 1) {
        await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 15));
        return;
      }
      var south = points.first.latitude, north = south;
      var west = points.first.longitude, east = west;
      for (final p in points) {
        if (p.latitude < south) south = p.latitude;
        if (p.latitude > north) north = p.latitude;
        if (p.longitude < west) west = p.longitude;
        if (p.longitude > east) east = p.longitude;
      }
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
          56,
        ),
      );
    } catch (e) {
      // Before the map has a size, bounds can't be fitted; nothing lost.
      debugPrint('fitTo: $e');
    }
  }

  double tilt = 0;
  double bearing = 0;

  Future reset() async {
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
    deliveriesLoaded = false;
    deliveriesFailed = false;
    deliveriesRefreshing = false;
    _tripMarkers.clear();
    _framedDeliveryId = null;
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
