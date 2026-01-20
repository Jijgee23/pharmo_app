import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';

class SellerTracking extends StatefulWidget {
  const SellerTracking({super.key});
  @override
  State<SellerTracking> createState() => _SellerTrackingState();
}

class _SellerTrackingState extends State<SellerTracking>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
  }

  Future<void> init() async {
    await LoadingService.run(
      () async {
        final jag = context.read<JaggerProvider>();
        await jag.loadPermission();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool deniedOrNotGranted = jagger.permission == null ||
            jagger.permission == LocationPermission.denied ||
            jagger.permission == LocationPermission.deniedForever;
        bool unableToDetermine = jagger.permission != null &&
            jagger.permission == LocationPermission.unableToDetermine;
        return Scaffold(
          body: Builder(builder: (context) {
            if (deniedOrNotGranted || unableToDetermine) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Таны байршил авах зөвшөөрөл байхгүй байна.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 350),
                        child: Text(
                          'Төхөөрөмжийнхөө тохиргооноос байршлын зөвшөөрөл олгоогүй бол та түгээлт хийх боломжгүй.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      CustomButton(
                        text: 'Шалгах',
                        ontap: () async {
                          await Settings.checkAlwaysLocationPermission()
                              .whenComplete(() => init());
                        },
                      )
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: jagger.latLng,
                    zoom: jagger.zoomIndex,
                    bearing: jagger.bearing,
                    tilt: jagger.tilt,
                  ),
                  onMapCreated: (controller) => jagger.onMapCreated(controller),
                  onTap: (argument) {},
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  mapType: MapType.terrain,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  trafficEnabled: jagger.trafficEnabled,
                  polylines: jagger.polylines,
                ),
                Positioned(
                  top: 0,
                  left: 25,
                  child: SafeArea(
                    child: Row(
                      spacing: 20,
                      children: [
                        FloatingActionButton(
                          heroTag: 'backST',
                          // mini: true,
                          onPressed: () => Navigator.of(context).pop(),
                          backgroundColor: white,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                        if (jagger.subscription != null &&
                            !jagger.subscription!.isPaused)
                          FloatingActionButton.extended(
                            heroTag: 'hasTrackST',
                            onPressed: () async {
                              await jagger.updateDatasToSended();
                              // await nativeSettingsChannel
                              //     .invokeMethod('requestLocationPermissions');
                            },
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
                Positioned(
                  bottom: 100,
                  right: 15,
                  child: SafeArea(
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoomInST',
                          elevation: 20,
                          onPressed: () {
                            jagger.zoomIn();
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: 'zoomOutST',
                          elevation: 20,
                          onPressed: () {
                            jagger.zoomOut();
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: 'myLocationST',
                          elevation: 20,
                          onPressed: jagger.goToMyLocation,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.my_location,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          heroTag: 'toggleTrafficST',
                          elevation: 20,
                          onPressed: jagger.toggleTraffic,
                          backgroundColor: jagger.trafficEnabled
                              ? Colors.blue
                              : Colors.white,
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
                  bottom: 20,
                  left: 15,
                  right: 15,
                  child: SafeArea(
                    child: Row(
                      spacing: 20,
                      children: [
                        if (jagger.subscription == null ||
                            (jagger.subscription != null &&
                                jagger.subscription!.isPaused))
                          button(tracker: jagger),
                        if (jagger.subscription != null &&
                            !jagger.subscription!.isPaused)
                          button(tracker: jagger, isStart: false),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future startSellerTrack() async {
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
      latitude: truncateToDigits(current.latitude, 6),
      longitude: truncateToDigits(current.longitude, 6),
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
    final r = await api(Api.post, 'seller/location/', body: body);
    if (r != null && apiSucceess(r)) {
      await tracker.clearTrackData();
      await tracker.addPointToBox(data);
      await LocalBase.saveSellerTrackId();
      final bool sellerTID = await LocalBase.hasSellerTrack();
      if (sellerTID) {
        await LogService().createLog(
          'Борлуулалт эхлэх',
          DateTime.now().toIso8601String(),
        );
        await tracker.tracking();
      }
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
      latitude: truncateToDigits(current.latitude, 6),
      longitude: truncateToDigits(current.longitude, 6),
      date: DateTime.now(),
      sended: true,
    );
    final body = {
      "locations": [
        {
          "lat": data.latitude,
          "lng": data.longitude,
          "created": data.date.toIso8601String(),
        }
      ]
    };
    final r = await api(Api.post, 'seller/location/', body: body);
    if (r != null && apiSucceess(r)) {
      await tracker.clearTrackData();
      await LogService().createLog(
        'Борлуулалт дууслаа',
        DateTime.now().toIso8601String(),
      );
      await tracker.stopTracking();
    }
  }

  Widget button({required JaggerProvider tracker, bool isStart = true}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          bool confirmed = await confirmDialog(
            context: context,
            title:
                'Байршлыг ${isStart ? ' дамжуулж  эхлэх үү' : 'дамжуулалт дуусгах уу'} ?',
            message: isStart
                ? 'Борлуулалтын үед таны байршил хянахыг анхаарна уу!'
                : '',
          );
          if (!confirmed) return;
          if (isStart) {
            await startSellerTrack();
            return;
          }
          await endSellerTrack();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isStart ? Colors.green : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Icon(
              isStart ? Icons.gps_fixed : Icons.gps_off,
              color: isStart ? white : Colors.white,
            ),
            Text(
              "Борлуулалт ${isStart ? 'эхлэх' : 'дуусгах'}",
              style: TextStyle(
                color: isStart ? white : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
