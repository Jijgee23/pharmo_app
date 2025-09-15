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
    final s = await Geolocator.getCurrentPosition();
    latLng = LatLng(s.latitude, s.longitude);
    notifyListeners();
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

  List<LocModel> offlineLocs = [];

  void getFromLocationDb() async {
    List<LocModel> list = await LocBox.getList();
    offlineLocs = list;
    notifyListeners();
  }

  void deleteFromLocalDb(LocModel model) async {
    await LocBox.deleteModel(model);
    getFromLocationDb();
  }

  void addLocModelToLocalDb(LocModel model) async {
    await LocBox.addToList(model);
    getFromLocationDb();
  }

  StreamSubscription? positionSubscription;
  bool _isSyncingOffline = false;

  void _syncOfflineLocations() async {
    if (_isSyncingOffline) {
      return;
    }
    _isSyncingOffline = true;

    try {
      var locationsToSync =
          List<LocModel>.from(offlineLocs.where((item) => !item.success));

      for (var item in locationsToSync) {
        var body = {"lat": item.lat, "lng": item.lng};
        var res = await api(Api.patch, 'seller/location/track/', body: body);
        if (res != null && res.statusCode == 201) {
          item.success = true;
        }
      }
    } finally {
      _isSyncingOffline = false;
    }
  }

  void startTracking() async {
    positionSubscription =
        bgLocationChannel.receiveBroadcastStream().listen((event) async {
      if (event is Map) {
        print('${event['lat']}. :  ${event['lng']}');
        data.add(LatLng(event['lat'], event['lng']));
        print(event['lat'].runtimeType);
        double latitude = truncateToDigits(parseDouble(event['lat']), 6);
        double longitude = truncateToDigits(parseDouble(event['lng']), 6);
        latLng = LatLng(latitude, longitude);
        var body = {"lat": latitude, "lng": longitude};
        final res = await api(Api.patch, 'seller/location/track/', body: body);
        if (res == null || res.statusCode != 201) {
          message('Илгээгдээгүй байршил хадгалашдлаа');
          await LocBox.addToList(
            LocModel(lat: latitude, lng: longitude, success: false),
          );
        } else {
          Notify.local('Байршил илгээсэн', '');
        }
        notifyListeners();
      }
    }, onError: (error) {
      print('BG Location error: $error');
    });

    message('Байршил илгээж эхлэлээ');
  }

  void stopListening() {
    positionSubscription?.cancel();
    positionSubscription = null;
  }

  Future<void> stopTracking() async {
    await LocBox.clearAll();
    if (positionSubscription != null) {
      await positionSubscription!.cancel();
      positionSubscription = null;
      notifyListeners();
    }
    message('Байршил дамжуулах дууслаа');
  }
}
