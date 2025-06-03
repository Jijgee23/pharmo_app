import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';

class SeeOrderMap extends StatefulWidget {
  final Order? order;
  const SeeOrderMap({super.key, this.order});

  @override
  State<SeeOrderMap> createState() => _SeeOrderMapState();
}

class _SeeOrderMapState extends State<SeeOrderMap> {
  Set<Marker> markers = {};

  late GoogleMapController mapController;
  @override
  void initState() {
    super.initState();
    var user = widget.order!.orderer;
    markers.add(
      Marker(
        markerId: const MarkerId('_loc'),
        position: LatLng(parseDouble(user!.lat), parseDouble(user.lng)),
        infoWindow: InfoWindow(title: user.name),
        icon: AssetMapBitmap('assets/drugstore.png', height: 30, width: 30),
      ),
    );
  }

  bool trafficEnabled = false;

  _toggleTraffic() {
    setState(() {
      trafficEnabled = !trafficEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideAppBar(text: widget.order!.orderer!.name),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.all(10),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            buildingsEnabled: true,
            trafficEnabled: trafficEnabled,
            zoomControlsEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            markers: markers,
            initialCameraPosition: CameraPosition(
                zoom: 12,
                target: LatLng(parseDouble(widget.order!.orderer!.lat),
                    parseDouble(widget.order!.orderer!.lng))),
          ),
          Positioned(
              bottom: 20,
              left: 40,
              child: InkWell(
                onTap: () => _toggleTraffic(),
                child: AnimatedContainer(
                  duration: duration,
                  padding: EdgeInsets.all(15),
                  decoration:
                      BoxDecoration(color: white, shape: BoxShape.circle),
                  child: Icon(Icons.traffic_outlined,
                      color: trafficEnabled ? Colors.green : Colors.red),
                ),
              ))
        ],
      ),
    );
  }
}
