import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:provider/provider.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({super.key});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _selectedLocation = const LatLng(0.0, 0.0);
  Marker? _marker;
  bool _isLoading = true;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getPosition();
    _getCurrentLocation();
  }

  // Method to get the current location
  Future<void> _getCurrentLocation() async {
    // Check for location permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      // Handle location service not enabled
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        // Handle permission denied
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedLocation = currentLocation;
      _isLoading = false;
      _marker = Marker(
        markerId: const MarkerId("current-location"),
        position: currentLocation,
        infoWindow: const InfoWindow(title: "Одоогйин байршил"),
      );
    });

    // Move camera to current location
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(currentLocation));
  }

  // Method to handle map tap and set new marker
  _onMapTapped(LatLng location) {
    print('lat ${location.latitude}\n lng${location.longitude}');
    homeProvider.setSelectedLoc(LatLng(location.latitude, location.longitude));
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
    return Scaffold(
      appBar: AppBar(
        leading: const ChevronBack(),
        title: const SmallText('Байршил сонгох'),
        backgroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onTap: _onMapTapped,
                  markers: _marker != null ? {_marker!} : {},
                ),
                Positioned(
                  bottom: Sizes.smallFontSize,
                  left: Sizes.width / 2 - Sizes.mediumFontSize * 2,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, _selectedLocation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.mediumFontSize, vertical: Sizes.smallFontSize),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(Sizes.bigFontSize)),
                      child: const Text('Болсон', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
