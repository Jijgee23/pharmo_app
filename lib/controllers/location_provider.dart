import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/loc_box.dart';
import 'package:pharmo_app/database/loc_model.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

const EventChannel bgLocationChannel = EventChannel('bg_location_stream');

double truncateToDigits(double value, int digits) {
  num mod = pow(10.0, digits);
  return ((value * mod).round().toDouble() / mod);
}

class LocationProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  bool _trafficEnabled = false;
  MapType _currentMapType = MapType.hybrid;

  GoogleMapController? get mapController => _mapController;
  bool get trafficEnabled => _trafficEnabled;
  MapType get currentMapType => _currentMapType;

  void onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    goToMyLocation();
  }

  void toggleTraffic() {
    _trafficEnabled = !_trafficEnabled;
    notifyListeners();
  }

  void changeMapType() {
    _currentMapType =
        MapType.values[(_currentMapType.index + 1) % MapType.values.length];
    notifyListeners();
  }

  Future<void> goToMyLocation() async {
    if (_mapController == null) {
      print("mapController is null");
      return;
    }

    final n = await Geolocator.getCurrentPosition();
    if (n != null) latLng = LatLng(n.latitude, n.longitude);
    notifyListeners();
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16),
      ),
    );
  }

  // from TrackProvider
  LatLng latLng = LatLng(47.90771, 106.88324);
  updateLatLng(LatLng valeu) {
    latLng = valeu;
    notifyListeners();
  }

  List<LatLng> data = [];

  void initTracking() async {
    bool hasTrack = await LocBox.hasSellerTrack();
    if (hasTrack) {
      startTracking();
    }
  }

  // List<LocModel> offlineLocs = [];

  // void getFromLocationDb() async {
  //   // List<LocModel> list = await LocBox.getList();
  //   // offlineLocs = list;
  //   notifyListeners();
  // }

  void deleteFromLocalDb(LocModel model) async {
    await LocBox.deleteModel(model);
    // getFromLocationDb();
  }

  void addLocModelToLocalDb(LocModel model) async {
    await LocBox.addToList(model);
  }

  StreamSubscription? positionSubscription;

  StreamSubscription<Position>? androidStream;
  void startTracking() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }

    if (Platform.isAndroid) {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      androidStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) async {
        sendTobacknd(
          position.latitude,
          position.longitude,
        );
      });
    } else {
      positionSubscription =
          bgLocationChannel.receiveBroadcastStream().listen((event) async {
        sendTobacknd(
          parseDouble((event as Map)['lat']),
          parseDouble((event)['lng']),
        );
      }, onError: (error) {
        print('BG Location error: $error');
      });

      print(positionSubscription == null);
    }
    message('Байршил илгээж эхлэлээ');
  }

  void sendTobacknd(double lat, double lng) async {
    String url = 'seller/location/track/';
    double latitude = truncateToDigits(lat, 6);
    double longitude = truncateToDigits(lng, 6);
    latLng = LatLng(latitude, longitude);
    data.add(latLng);
    notifyListeners();
    var body = {"lat": latitude, "lng": longitude};
    final res = await api(Api.patch, url, body: body);
    if (res == null || res.statusCode != 201) {
      message('Илгээгдээгүй байршил хадгалагдлаа');
      addLocModelToLocalDb(
        LocModel(lat: latitude, lng: longitude, success: false),
      );
    } else {
      Notify.local('Байршил илгээсэн', '');
      final nosended = await LocBox.getList();
      if (nosended.isNotEmpty) {
        for (var k in nosended) {
          var b = {"lat": k.lat, "lng": k.lng};
          final r = await api(Api.patch, url, body: b);
          if (r != null && r.statusCode == 201) {
            await LocBox.deleteModel(k);
          }
        }
      }
    }
  }

  Future<void> stopTracking() async {
    await LocBox.clearAll();
    if (Platform.isAndroid) {
      if (androidStream != null) {
        await androidStream!.cancel();
        androidStream = null;
      }
    } else {
      if (positionSubscription != null) {
        await positionSubscription!.cancel();
        positionSubscription = null;
        data.clear();
        notifyListeners();
      }
    }
    message('Байршил дамжуулах дууслаа');
    data.clear();
    await LocBox.clearAll();
    notifyListeners();
  }
}
