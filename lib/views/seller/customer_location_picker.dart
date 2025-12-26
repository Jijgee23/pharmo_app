import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:provider/provider.dart';

class LocationPicker extends StatefulWidget {
  final int cusotmerId;
  final double? lat;
  final double? lng;
  const LocationPicker({
    super.key,
    required this.cusotmerId,
    this.lat,
    this.lng,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late final GoogleMapController controller;
  LatLng _selectedLocation = const LatLng(0.0, 0.0);
  Marker? _marker;
  bool _isLoading = false;
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
        desiredAccuracy: LocationAccuracy.high);
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
    // final GoogleMapController r = await controller;
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
    return Consumer2<HomeProvider, PharmProvider>(
      builder: (context, home, pp, child) => Scaffold(
        appBar: const SideAppBar(text: 'Байршил сонгох'),
        body: Builder(
          builder: (context) {
            if (_isLoading) {
              return Center(child: CircularProgressIndicator());
            }
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
                  bottom: 80,
                  right: 20,
                  child: SafeArea(
                    child: FloatingActionButton(
                      heroTag: 'myLocationPL',
                      elevation: 20,
                      onPressed: goToMyLocation,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => saveCustomerLocatoin(pp),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: primary,
                                overlayColor: Colors.white.withAlpha(120),
                              ),
                              child: Text(
                                'Хадгалах',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedLocation,
          zoom: 16,
        ),
      ),
    );
  }

  saveCustomerLocatoin(PharmProvider pharm) async {
    await pharm.sendCustomerLocation(widget.cusotmerId, context);
    Navigator.pop(context);
    await pharm.getCustomerDetail(widget.cusotmerId);
  }
}
