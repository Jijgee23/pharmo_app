import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';

class DeliveryOrderLocation extends StatefulWidget {
  final DeliveryOrder order;
  const DeliveryOrderLocation({super.key, required this.order});
  @override
  State<DeliveryOrderLocation> createState() => _DeliveryOrderLocationState();
}

class _DeliveryOrderLocationState extends State<DeliveryOrderLocation> {
  Set<Marker> markers = {};

  late GoogleMapController mapController;
  @override
  void initState() {
    super.initState();
    var user = widget.order.orderer;
    markers.add(
      Marker(
        markerId: const MarkerId('_loc'),
        position: LatLng(parseDouble(user!.lat), parseDouble(user.lng)),
        infoWindow: InfoWindow(title: user.name),
        icon: AssetMapBitmap('assets/drugstore.png', height: 30, width: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      buildingsEnabled: false,
      markers: markers,
      initialCameraPosition: CameraPosition(
        zoom: 16,
        target: LatLng(
          parseDouble(widget.order.orderer!.lat),
          parseDouble(widget.order.orderer!.lng),
        ),
      ),
    );
  }
}
