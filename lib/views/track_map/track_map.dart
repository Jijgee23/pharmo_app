import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/track_map/driver_button.dart';
import 'package:pharmo_app/views/track_map/map_buttons.dart';
import 'package:pharmo_app/views/track_map/map_heading.dart';
import 'package:pharmo_app/views/track_map/seller_track_button.dart';
import 'package:pharmo_app/views/track_map/track_permission_page.dart';
import 'package:pharmo_app/views/track_map/tracking_status_card.dart';

class TrackMap extends StatefulWidget {
  const TrackMap({super.key});

  @override
  State<TrackMap> createState() => _TrackMapState();
}

class _TrackMapState extends State<TrackMap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await init(),
    );
  }

  Future<void> init() async {
    final user = Authenticator.security;
    final jag = context.read<JaggerProvider>();
    if (user == null) return;

    await LoadingService.run(() async {
      await jag.loadPermission();
      await jag.loadTrackState();

      if (user.isDriver) {
        await jag.getDeliveries();
      }
      if (user.isSaler) {
        await jag.checkSellerTrack();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Authenticator.security;
    if (user == null) return Scaffold();
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool isSeller = user.isSaler;
        LocationPermission? per = jagger.permission;
        LocationAccuracyStatus? accuracy = jagger.accuracy;
        bool backgrounEnabled = per != null && per == LocationPermission.always;
        bool isPrecise =
            accuracy != null && accuracy == LocationAccuracyStatus.precise;
        final showMap = backgrounEnabled && isPrecise;
        final showTracking =
            jagger.subscription != null && !jagger.subscription!.isPaused;
        if (showMap) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => jagger.onMapCreated(controller),
                markers: {...jagger.orderMarkers},
                trafficEnabled: jagger.trafficEnabled,
                mapType: jagger.mapType,
                compassEnabled: true,
                mapToolbarEnabled: true,
                myLocationEnabled: true,
                buildingsEnabled: false,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  bearing: jagger.bearing,
                  tilt: jagger.tilt,
                  target: jagger.latLng,
                  zoom: jagger.zoomIndex,
                ),
                tiltGesturesEnabled: true,
                polylines: jagger.polylines,
              ),
              MapButtons(),
              MapHeading(isSeller: isSeller, showTracking: showTracking),
              if (showTracking) const TrackingStatusCard(),
              // if (!isSeller) const DeliveryInfoCard(),
              DriverButton(),
              SellerTrackButton(),
            ],
          );
        }
        return TrackPermissionPage();
      },
    );
  }

  // void handleTap({bool isStart = true}) async {
  //   bool confirmed = await confirmDialog(
  //     context: context,
  //     title: 'Борлуулалт ${isStart ? 'эхлэх үү' : 'дуусгах уу'} ?',
  //     message:
  //         isStart ? 'Борлуулалтын үед таны байршил хянахыг анхаарна уу!' : '',
  //   );
  //   if (!confirmed) return;
  //   if (isStart) {
  //     await startSellerTrack();
  //     return;
  //   }
  //   await endSellerTrack();
  //   return;
  // }

  // Future startSellerTrack({bool isStart = true}) async {
  //   final tracker = context.read<JaggerProvider>();
  //   final current = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.bestForNavigation,
  //     locationSettings: LocationSettings(
  //       accuracy: LocationAccuracy.bestForNavigation,
  //     ),
  //   );
  //   if (current == null) {
  //     messageWarning('Одоогийн байршил олдсонгүй!');
  //     return;
  //   }
  //   final data = TrackData(
  //     latitude: truncateToSixDigits(current.latitude),
  //     longitude: truncateToSixDigits(current.longitude),
  //     date: DateTime.now(),
  //     sended: true,
  //   );
  //   print(current.latitude);
  //   final body = {
  //     "locations": [
  //       {
  //         "lat": data.latitude,
  //         "lng": data.longitude,
  //         "created": data.date.toIso8601String(),
  //       }
  //     ]
  //   };
  //   String url = isStart ? 'sales/route/' : 'sales/route/end/';
  //   String action = isStart ? 'эхлэлээ' : 'дууслаа';
  //   final r = await api(Api.patch, url, body: body);
  //   if (r != null && apiSucceess(r)) {
  //     messageComplete('Борлуулалт амжилттай $action!');
  //     print("SELLER TRACK ${convertData(r)}");
  //     if (isStart) {
  //       tracker.addMarker(
  //         AssetIcon.flag,
  //         position: LatLng(data.latitude, data.longitude),
  //       );
  //       await tracker.clearTrackData();
  //       await tracker.addPointToBox(data);
  //       await tracker.checkSellerTrack();
  //       final bool sellerTID = await Authenticator.hasTrack();
  //       if (sellerTID) {
  //         await tracker.tracking();
  //       }
  //       return;
  //     }
  //     await tracker.clearTrackData();
  //     await tracker.stopTracking();
  //   }
  //   bool notInUb = convertData(r!).toString().contains('Ulaanbaatar');
  //   if (notInUb) {
  //     messageWarning('Байршил Улаанбаатарт биш байна');
  //     return;
  //   }
  //   message('Түр хүлээнэ үү');
  // }

  // Future endSellerTrack() async {
  //   final tracker = context.read<JaggerProvider>();
  //   if (tracker.permission != LocationPermission.always) {
  //     await Settings.checkAlwaysLocationPermission();
  //     return;
  //   }
  //   final current = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.bestForNavigation,
  //     locationSettings: LocationSettings(
  //       accuracy: LocationAccuracy.bestForNavigation,
  //     ),
  //   );

  //   if (current == null) {
  //     messageWarning('Одоогийн байршил олдсонгүй!');
  //     return;
  //   }
  //   final data = TrackData(
  //     latitude: truncateToSixDigits(current.latitude),
  //     longitude: truncateToSixDigits(current.longitude),
  //     date: DateTime.now(),
  //     sended: true,
  //   );
  //   final body = {
  //     "lat": data.latitude,
  //     "lng": data.longitude,
  //     "created": data.date.toIso8601String(),
  //   };
  //   final r = await api(Api.patch, 'sales/route/end/', body: body);
  //   if (r != null && apiSucceess(r)) {
  //     await tracker.clearTrackData();
  //     await LogService().createLog(
  //       'Борлуулалт дууслаа',
  //       DateTime.now().toIso8601String(),
  //     );
  //     messageComplete('Борлуулалт амжилттай дууслаа!');
  //     await tracker.stopTracking();
  //     return;
  //   }
  //   if (convertData(r!).toString().contains('ulaanbaatar')) {
  //     messageWarning('Борлуулалт дуусгах байршил Улаанбаатарт биш байна.');
  //     return;
  //   }
  //   messageWarning('Түх хүлээгээл дахин оролдоно уу!');
  // }
}
