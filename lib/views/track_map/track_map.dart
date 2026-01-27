import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
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
              Positioned(
                bottom: 20,
                right: 15,
                child: SafeArea(
                  child: Column(
                    spacing: 10,
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomInDMANMAP',
                        elevation: 20,
                        onPressed: () {
                          jagger.mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      FloatingActionButton(
                        heroTag: 'zoomOutDMANMAP',
                        elevation: 20,
                        onPressed: () {
                          jagger.mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      FloatingActionButton(
                        heroTag: 'myLocationDMANMAP',
                        elevation: 20,
                        onPressed: jagger.goToMyLocation,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'toggleTrafficDMANMAP',
                        elevation: 20,
                        onPressed: jagger.toggleTraffic,
                        backgroundColor:
                            jagger.trafficEnabled ? Colors.blue : Colors.white,
                        child: const Icon(
                          Icons.traffic,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 20,
                left: 20,
                child: SafeArea(
                  child: SizedBox(
                    width: ContextX(context).width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 20,
                      children: [
                        if (isSeller)
                          FloatingActionButton(
                            heroTag: 'backST',
                            onPressed: () => Navigator.of(context).pop(),
                            backgroundColor: white,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        if (showTracking)
                          FloatingActionButton.extended(
                            heroTag: 'hasTrack2DMANMAPjk',
                            onPressed: () async {},
                            backgroundColor: Colors.teal,
                            label: Text(
                              'Байршил дамжуулж байна...',
                              style: TextStyle(color: white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: SafeArea(
                  child: SizedBox(
                    width: ContextX(context).width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FloatingActionButton.extended(
                          elevation: 10,
                          heroTag: 'trackingDeliveries',
                          onPressed: () => handleTap(
                            isSeller,
                            isStart: isStart,
                          ),
                          backgroundColor: isSeller
                              ? (isStart ? Colors.green : Colors.red)
                              : Colors.white,
                          label: user.role == 'D'
                              ? Column(
                                  children: [
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Text(
                                          'Идэвхитэй түгээлтүүд',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Icon(
                                          Icons.shopping_bag,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    if (jagger.delivery.isNotEmpty &&
                                        jagger.delivery[0].startedOn != null)
                                      Row(
                                        spacing: 10,
                                        children: [
                                          Text(
                                            '${jagger.delivery[0].startedOn!.substring(11, 16)}-с эхэлсэн',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 20,
                                  children: [
                                    Icon(
                                      isStart ? Icons.gps_fixed : Icons.gps_off,
                                      color: white,
                                    ),
                                    Text(
                                      "Борлуулалт ${isStart ? 'эхлэх' : 'дуусгах'}",
                                      style: TextStyle(
                                        color: white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return TrackPermissionPage();
      },
    );
  }

  void handleTap(bool isSeller, {bool isStart = true}) async {
    if (isSeller) {
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
    await goto(Deliveries());
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
      final bool notInUb = convertData(r!).toString().contains('Ulaanbaatar');
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
