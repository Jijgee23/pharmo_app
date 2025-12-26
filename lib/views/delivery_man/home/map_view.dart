import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => jagger.onMapCreated(controller),
                markers: jagger.markers,
                trafficEnabled: jagger.trafficEnabled,
                mapType: jagger.mapType,
                compassEnabled: true,
                mapToolbarEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  bearing: 0,
                  tilt: 150,
                  target: jagger.currentPosition != null
                      ? LatLng(jagger.currentPosition!.latitude,
                          jagger.currentPosition!.longitude)
                      : const LatLng(47.918873, 106.917572),
                  zoom: jagger.zoomIndex,
                ),
                polylines: {
                  if (jagger.routeCoords.isNotEmpty)
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: jagger.routeCoords,
                      color: Colors.indigo,
                      width: 5,
                    ),
                  if (jagger.noSendedLocs.isNotEmpty)
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: <LatLng>[
                        ...jagger.noSendedLocs.map((d) => LatLng(d.lat, d.lng))
                      ],
                      color: Colors.redAccent,
                      width: 5,
                    ),
                },
              ),
              Positioned(
                bottom: 20,
                right: 15,
                child: SafeArea(
                  child: Column(
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'myLocationD',
                        elevation: 20,
                        onPressed: jagger.goToMyLocation,
                        backgroundColor: Colors.white,
                        child:
                            const Icon(Icons.my_location, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
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
              if (jagger.positionSubscription != null &&
                  !jagger.positionSubscription!.isPaused)
                Positioned(
                  top: 0,
                  right: 20,
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Байршил дамжуулж байна'),
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
