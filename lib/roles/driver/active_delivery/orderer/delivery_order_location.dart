import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

/// A small map of where an order goes: [coordinates], labelled [title].
class DeliveryOrderLocation extends StatelessWidget {
  final (double, double) coordinates;
  final String title;
  const DeliveryOrderLocation({super.key, required this.coordinates, required this.title});

  @override
  Widget build(BuildContext context) {
    final target = LatLng(coordinates.$1, coordinates.$2);
    return GoogleMap(
      mapType: MapType.normal,
      buildingsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('order'),
          position: target,
          infoWindow: InfoWindow(title: title),
        ),
      },
      initialCameraPosition: CameraPosition(target: target, zoom: 16),
    );
  }
}
