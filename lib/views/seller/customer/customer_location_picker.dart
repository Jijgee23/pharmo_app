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
  GoogleMapController? controller;
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
        controller!.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
      },
    );
  }

  _onMapTapped(LatLng location) {
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
        body: Stack(
          children: <Widget>[
            // 1. Google Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14,
              ),
              myLocationEnabled: true, // Хэрэглэгчийн цэнхэр цэгийг харуулна
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false, // Илүү цэвэрхэн харагдуулна
              onMapCreated: (c) => controller = c,
              onTap: _onMapTapped,
              markers: _marker != null ? {_marker!} : {},
            ),

            // 2. Дээд талын мэдээллийн хэсэг (Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name ?? 'Байршил тогтоох',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const Text(
                            'Газрын зураг дээр дарж байршлыг сонгоно уу',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Баруун доорх үйлдлийн товчлуурууд
            Positioned(
              bottom: 30,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapActionButton(
                    icon: Icons.my_location,
                    onTap: goToMyLocation,
                    heroTag: 'myLoc',
                  ),
                  const SizedBox(height: 15),
                  _mapActionButton(
                    icon: Icons.check_circle,
                    label: 'Хадгалах',
                    color: primary,
                    iconColor: Colors.white,
                    onTap: () => saveCustomerLocatoin(pp),
                    heroTag: 'saveLoc',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Загварлаг газрын зургийн товчлуур
  Widget _mapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String heroTag,
    String? label,
    Color color = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(5)),
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
        FloatingActionButton(
          heroTag: heroTag,
          onPressed: onTap,
          backgroundColor: color,
          elevation: 4,
          child: Icon(icon, color: iconColor),
        ),
      ],
    );
  }

  // Жижиг засвар: controller-ийг null эсэхийг заавал шалгах
  Future<void> goToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng current = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = current;
        _marker = Marker(
          markerId: const MarkerId("selected-location"),
          position: current,
        );
      });

      controller?.animateCamera(CameraUpdate.newLatLngZoom(current, 16));
    } catch (e) {
      messageWarning("Байршил тогтооход алдаа гарлаа");
    }
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
