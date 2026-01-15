import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
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
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
  }

  Future<void> init() async {
    final jag = context.read<JaggerProvider>();
    LoadingService.run(() async {
      if (jag.permission != LocationPermission.always) {
        final value = await Geolocator.checkPermission();
        jag.setPermission(value);
      }
      await jag.getCurrentLocation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      init();
    }
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
                        ontap: () async =>
                            await Settings.checkAlwaysLocationPermission()
                                .whenComplete(() => init()),
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
                        if (jagger.subscription != null)
                          FloatingActionButton.extended(
                            heroTag: 'hasTrackST',
                            onPressed: () {},
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
            await startTrack(tracker);
            return;
          }
          stopTrcack(tracker);
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
          children: [
            Text(
              isStart ? 'Эхлэх' : 'Дуусгах',
              style: TextStyle(
                color: isStart ? white : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              isStart ? Icons.gps_fixed : Icons.gps_off,
              color: isStart ? white : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future startTrack(JaggerProvider jagger) async {
    print('starting seller track');
    await LocalBase.saveSellerTrackId();
    final bool sellerTID = await LocalBase.hasSellerTrack();
    if (sellerTID) {
      await jagger.tracking();
    }
  }

  Future stopTrcack(JaggerProvider tracker) async {
    await LocalBase.removeSellerTrackId();
    final bool hasTrack = await LocalBase.hasSellerTrack();
    if (hasTrack) {
      return;
    }
    tracker.stopTracking();
  }
}
