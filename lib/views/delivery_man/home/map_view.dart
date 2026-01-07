import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/application/utilities/colors.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        return Scaffold(
          body: Stack(
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
                        heroTag: 'zoomInD',
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
                        heroTag: 'zoomOutD',
                        elevation: 20,
                        onPressed: () {
                          jagger.mapController
                              .animateCamera(CameraUpdate.zoomOut());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      FloatingActionButton(
                        heroTag: 'myLocationD',
                        elevation: 20,
                        onPressed: jagger.goToMyLocation,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'toggleTrafficD',
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
              // if (jagger.timer.isActive && jagger.delivery.isNotEmpty)
              //   Positioned(
              //   bottom: 20,
              //   left: 20,
              //   child: Card(
              //     elevation: 3,
              //     color: white,
              //     shape: RoundedRectangleBorder(
              //       side: BorderSide(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Builder(builder: (context) {
              //       final diff = DateTime.now().difference(
              //         DateTime.parse(jagger.delivery[0].startedOn ?? ''),
              //       );

              //       final hh = diff.inHours.toString().padLeft(2, '0');
              //       final mm =
              //           (diff.inMinutes % 60).toString().padLeft(2, '0');
              //       final ss =
              //           (diff.inSeconds % 60).toString().padLeft(2, '0');

              //       return Container(
              //         padding: EdgeInsets.all(10),
              //         child: Column(
              //           spacing: 10,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text('Хугацаа: $hh:$mm:$ss'),
              //             Text(
              //               'Нийт зам: ${truncateToDigits(calculateTotalDistanceKm(jagger.trackDatas), 1)} км',
              //             ),
              //           ],
              //         ),
              //       );
              //     }),
              //   ),
              // ),
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
                            heroTag: 'hasTrack2',
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
                ),
            ],
          ),
        );
      },
    );
  }
}
