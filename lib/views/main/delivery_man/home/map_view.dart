import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        Color trafficColor = jagger.trafficEnabled ? Colors.green : Colors.grey;
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
              Positioned(
                top: 0,
                left: 20,
                child: SafeArea(
                  top: true,
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              mapIcon(() => jagger.toggleTraffic(), Icons.traffic, 20,
                  trafficColor),
              mapIcon(() => jagger.toggleView(), Icons.remove_red_eye, 65,
                  neonBlue),
              mapIcon(() => jagger.zoomIn(), Icons.add, 110, black),
              mapIcon(() => jagger.zoomOut(), Icons.remove, 155, black),
            ],
          ),
        );
      },
    );
  }

  mapIcon(
      GestureTapCallback ontap, IconData icon, double fromLeft, Color iColor) {
    return Positioned(
      bottom: 30,
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
