import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

const LatLng ulaanbaatar = LatLng(47.921230, 106.918556);

class LocationPicker extends StatefulWidget {
  final Customer customer;
  const LocationPicker({super.key, required this.customer});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late final GoogleMapController controller;
  LatLng _selectedLocation = ulaanbaatar;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    final pharm = context.read<PharmProvider>();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled) {
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );
    final custLat = pharm.customerDetail.lat;
    final custLng = pharm.customerDetail.lng;
    setState(
      () {
        _selectedLocation = (custLat != null && custLng != null)
            ? LatLng(custLat, custLng)
            : currentLocation;
        _marker = Marker(
          markerId: const MarkerId("current-location"),
          position: _selectedLocation,
          infoWindow: const InfoWindow(title: "Одоогийн байршил"),
        );
        controller.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
      },
    );
  }

  _onMapTapped(LatLng location) {
    print('lat ${location.latitude}\n lng${location.longitude}');
    setState(() {
      _selectedLocation = location;
      _marker = Marker(
        markerId: const MarkerId("selected-location"),
        position: location,
        infoWindow: const InfoWindow(title: "Сонгосон байршил"),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (context, home, pp, child) => Scaffold(
        body: Builder(
          builder: (context) {
            return Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 12,
                  ),
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController c) {
                    setState(() {
                      controller = c;
                    });
                  },
                  onTap: _onMapTapped,
                  markers: _marker != null ? {_marker!} : {},
                ),
                Positioned(
                  bottom: 0,
                  right: 20,
                  child: SafeArea(
                    child: Column(
                      spacing: 10,
                      children: [
                        FloatingActionButton(
                          heroTag: 'cusotmerLocationGOTO',
                          elevation: 20,
                          onPressed: goToMyLocation,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.my_location,
                              color: Colors.black),
                        ),
                        FloatingActionButton(
                          heroTag: 'SaveCustomerLocation',
                          elevation: 20,
                          onPressed: () async => await saveCustomerLocatoin(pp),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.save, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: SafeArea(
                    bottom: true,
                    child: FloatingActionButton(
                      heroTag: 'cusotmerLocationPop',
                      elevation: 20,
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> goToMyLocation() async {
    if (controller == null) {
      return;
    }

    final n = await Geolocator.getCurrentPosition();
    if (n != null) _selectedLocation = LatLng(n.latitude, n.longitude);

    _marker = Marker(
      markerId: const MarkerId("current-location"),
      position: _selectedLocation,
      infoWindow: const InfoWindow(title: "Одоогийн байршил"),
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedLocation,
          zoom: 16,
        ),
      ),
    );
    setState(() {});
  }

  saveCustomerLocatoin(PharmProvider pharm) async {
    final msg =
        'Уртраг: ${_selectedLocation.latitude}, Өргөрөг: ${_selectedLocation.longitude}';
    final confirmed = await confirmDialog(
      context: context,
      title: 'Та ${widget.customer.name}-ийн байршлыг шинэчилэх үү?',
      message: msg,
    );

    if (!confirmed) return;
    await pharm.sendCustomerLocation(widget.customer.id!, _selectedLocation);

    Navigator.pop(context);
    await pharm.getCustomerDetail(widget.customer.id!);
  }
}
