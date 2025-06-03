import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final jagger = context.read<JaggerProvider>();
    Color trafficColor = jagger.trafficEnabled ? Colors.green : Colors.grey;
    Color aspectColor =
        jagger.aspectRatio == 2.3 / 4 ? Colors.green : Colors.grey;
    return AspectRatio(
      aspectRatio: jagger.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(),
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => jagger.onMapCreated(controller),
                markers: jagger.markers,
                trafficEnabled: jagger.trafficEnabled,
                mapType: jagger.mapType,
                compassEnabled: true,
                mapToolbarEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
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
              mapIcon(
                  () => jagger.toggleZoom(), Icons.fullscreen, 10, aspectColor),
              mapIcon(() => jagger.toggleTraffic(), Icons.traffic, 55,
                  trafficColor),
              mapIcon(() => jagger.toggleView(), Icons.remove_red_eye, 100,
                  neonBlue),
              mapIcon(() => jagger.zoomIn(), Icons.add, 145, black),
              mapIcon(() => jagger.zoomOut(), Icons.remove, 190, black),
            ],
          ),
        ),
      ),
    );
  }

  mapIcon(
      GestureTapCallback ontap, IconData icon, double fromLeft, Color iColor) {
    return Positioned(
      bottom: 10,
      left: fromLeft,
      child: InkWell(
        onTap: ontap,
        child: Container(
          padding: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
              color: white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: grey500, blurRadius: 1)]),
          child: Icon(icon, color: iColor),
        ),
      ),
    );
  }
}
