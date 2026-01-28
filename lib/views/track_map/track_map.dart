import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/track_map/driver_button.dart';
import 'package:pharmo_app/views/track_map/map_buttons.dart';
import 'package:pharmo_app/views/track_map/map_heading.dart';
import 'package:pharmo_app/views/track_map/seller_track_button.dart';
import 'package:pharmo_app/views/track_map/track_permission_page.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/deliveries.dart';

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
    final jag = context.read<JaggerProvider>();

    LoadingService.run(() async {
      await jag.loadPermission();
      await jag.checkSellerTrack();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalBase.security;
    if (user == null) return Scaffold();
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool isSeller = user.role == 'S';
        final isStart = jagger.subscription == null ||
            (jagger.subscription != null && jagger.subscription!.isPaused);
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
              DriverButton(),
              SellerTrackButton(
                onPressed: () => handleTap(isStart: isStart),
                isStart: isStart,
              )
            ],
          );
        }
        return TrackPermissionPage();
      },
    );
  }

  void handlerDelmanButton() {
    goto(Deliveries());
  }

  void handleTap({bool isStart = true}) async {
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Борлуулалт ${isStart ? 'эхлэх үү' : 'дуусгах уу'} ?',
      message:
          isStart ? 'Борлуулалтын үед таны байршил хянахыг анхаарна уу!' : '',
    );
    if (!confirmed) return;
    if (isStart) {
      await startSellerTrack();
      return;
    }
    await endSellerTrack();
    return;
  }

  Future startSellerTrack() async {
    final tracker = context.read<JaggerProvider>();
    final current = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
    if (current == null) {
      messageWarning('Одоогийн байршил олдсонгүй!');
      return;
    }
    final data = TrackData(
      latitude: truncateToSixDigits(current.latitude),
      longitude: truncateToSixDigits(current.longitude),
      date: DateTime.now(),
      sended: true,
    );
    print(current.latitude);
    final body = {
      "locations": [
        {
          "lat": data.latitude,
          "lng": data.longitude,
          "created": data.date.toIso8601String(),
        }
      ]
    };
    final r = await api(Api.patch, 'sales/route/', body: body);
    if (r != null && apiSucceess(r)) {
      await tracker.clearTrackData();
      await tracker.addPointToBox(data);
      await LocalBase.saveSellerTrackId();
      final bool sellerTID = await LocalBase.hasSellerTrack();
      if (sellerTID) {
        messageComplete('Борлуулалт амжилттай эхлэлээ!');
        await LogService().createLog(
          'Борлуулалт эхлэх',
          DateTime.now().toIso8601String(),
        );
        await tracker.tracking();
        return;
      }
    } else {
      bool notInUb = convertData(r!).toString().contains('Ulaanbaatar');
      if (notInUb) {
        messageWarning('Байршил Улаанбаатарт биш байна');
        return;
      }
      message('Түр хүлээнэ үү');
    }
  }

  Future endSellerTrack() async {
    final tracker = context.read<JaggerProvider>();
    if (tracker.permission != LocationPermission.always) {
      await Settings.checkAlwaysLocationPermission();
      return;
    }
    final current = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    if (current == null) {
      messageWarning('Одоогийн байршил олдсонгүй!');
      return;
    }
    final data = TrackData(
      latitude: truncateToSixDigits(current.latitude),
      longitude: truncateToSixDigits(current.longitude),
      date: DateTime.now(),
      sended: true,
    );
    final body = {
      "lat": data.latitude,
      "lng": data.longitude,
      "created": data.date.toIso8601String(),
    };
    final r = await api(Api.patch, 'sales/route/end/', body: body);
    if (r != null && apiSucceess(r)) {
      await tracker.clearTrackData();
      await LogService().createLog(
        'Борлуулалт дууслаа',
        DateTime.now().toIso8601String(),
      );
      messageComplete('Борлуулалт амжилттай дууслаа!');
      await tracker.stopTracking();
      return;
    }
    if (convertData(r!).toString().contains('ulaanbaatar')) {
      messageWarning('Борлуулалт дуусгах байршил Улаанбаатарт биш байна.');
      return;
    }
    messageWarning('Түх хүлээгээл дахин оролдоно уу!');
  }
}
