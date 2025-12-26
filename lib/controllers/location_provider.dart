import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/loc_box.dart';
import 'package:pharmo_app/database/loc_model.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

double truncateToDigits(double value, int digits) {
  num mod = pow(10.0, digits);
  return ((value * mod).round().toDouble() / mod);
}

class LocationProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  bool _trafficEnabled = false;

  GoogleMapController? get mapController => _mapController;
  bool get trafficEnabled => _trafficEnabled;

  void onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    goToMyLocation();
  }

  void toggleTraffic() {
    _trafficEnabled = !_trafficEnabled;
    notifyListeners();
  }

  Future<void> goToMyLocation() async {
    if (_mapController == null) {
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
  void updateLatLng(LatLng valeu) {
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

  void deleteFromLocalDb(LocModel model) async {
    await LocBox.deleteModel(model);
  }

  void addLocModelToLocalDb(LocModel model) async {
    await LocBox.addToList(model);
  }

  StreamSubscription? positionSubscription;

  void startTracking() async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    final r = await Geolocator.getCurrentPosition();
    if (r != null) {
      final p = await api(
        Api.post,
        'seller/location/',
        body: {
          "locations": [
            {
              "lat": truncateToDigits(r.latitude, 6),
              "lng": truncateToDigits(r.longitude, 6),
              "created": DateTime.now().toIso8601String(),
            }
          ]
        },
      );
      if (p!.statusCode == 200 || p.statusCode == 201) {
        debugPrint(
          "sended lat: ${truncateToDigits(r.latitude, 6)}, lng: ${truncateToDigits(r.longitude, 6)}",
        );
        await LocalBase.saveSellerTrackId();
        positionSubscription =
            bgLocationChannel.receiveBroadcastStream().listen(
          (event) async {
            final data = event as Map<dynamic, dynamic>;
            sendTobacknd(data['lat'], data['lng']);
          },
          onError: (error) {
            FirebaseApi.local('Байршил дамжуулж чадсангүй', '');
            print('BG Location error: $error');
          },
        );
        notifyListeners();
        if (positionSubscription != null) message('Борлуулалт эхлэлээ');
      }
    }
  }

  void sendTobacknd(double lat, double lng) async {
    String url = 'seller/location/';
    double latitude = truncateToDigits(lat, 6);
    double longitude = truncateToDigits(lng, 6);
    latLng = LatLng(latitude, longitude);
    data.add(latLng);
    notifyListeners();

    var body = {
      "locations": [
        {
          "lat": latitude,
          "lng": longitude,
          "created": DateTime.now().toIso8601String()
        },
      ],
    };

    final res = await api(Api.post, url, body: body);
    if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
      debugPrint("sended lat: $latitude, lng: $longitude");
      await FirebaseApi.local(
        'Байршил илгээсэн',
        'Өрг: $latitude Урт: $longitude',
      );
      final nosended = await LocBox.getList();
      if (nosended.isNotEmpty) {
        for (var k in nosended) {
          var b = {
            "locations": [
              {
                "lat": k.lat,
                "lng": k.lng,
                "created": k.data ?? DateTime.now().toIso8601String()
              },
            ],
          };
          final r = await api(Api.patch, url, body: b);
          if (r != null && r.statusCode == 201) {
            await LocBox.deleteModel(k);
          }
        }
      }
    } else {
      message('Илгээгдээгүй байршил хадгалагдлаа');
      var m = LocModel(lat: latitude, lng: longitude, success: false);
      addLocModelToLocalDb(m);
    }
  }

  Future<void> stopTracking() async {
    await positionSubscription!.cancel();
    positionSubscription = null;
    data.clear();
    notifyListeners();
    await LocalBase.removeSellerTrackId();
    await LocBox.clearAll();
  }
}
