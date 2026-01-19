import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/services/settings.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/views/delivery_man/active_delivery/deliveries.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool deniedOrNotGranted = jagger.permission == null ||
            jagger.permission == LocationPermission.denied ||
            jagger.permission == LocationPermission.deniedForever;
        bool unableToDetermine = jagger.permission != null &&
            jagger.permission == LocationPermission.unableToDetermine;
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
              onMapCreated: (controller) => jagger.onMapCreated(controller),
              markers: {...jagger.orderMarkers, ...jagger.markers},
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
                target: jagger.currentPosition != null
                    ? LatLng(jagger.currentPosition!.latitude,
                        jagger.currentPosition!.longitude)
                    : const LatLng(47.918873, 106.917572),
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
                        jagger.mapController
                            .animateCamera(CameraUpdate.zoomOut());
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
            if (jagger.subscription != null && !jagger.subscription!.isPaused)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: SizedBox(
                    width: context.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: 'hasTrack2DMANMAPjk',
                          onPressed: () async {
                            // await jagger.updateDatasToSended();

                            final refresh = await refreshed();
                            print(refresh);
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
              ),
            // if (jagger.delivery.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              child: SafeArea(
                child: SizedBox(
                  width: context.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FloatingActionButton.extended(
                        elevation: 10,
                        heroTag: 'trackingDeliveries',
                        onPressed: () => goto(Deliveries()),
                        backgroundColor: Colors.white,
                        label: Column(
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
                                  // Text(
                                  //   'Нийт: ${truncateToDigits(calculateTotalDistanceKm(jagger.trackDatas), 1)} км',
                                  //   style: TextStyle(
                                  //     color: Colors.black,
                                  //     fontSize: 12,
                                  //   ),
                                  // ),
                                ],
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
      },
    );
  }
}
