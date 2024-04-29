import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LocationData? _currentLocation;
  Location location = Location();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: FlutterLocationPicker(
        initZoom: 13,
        initPosition: _currentLocation != null
            ? LatLong(_currentLocation!.latitude!, _currentLocation!.longitude!)
            : const LatLong(47.9184676, 106.91769547123221),
        minZoomLevel: 5,
        maxZoomLevel: 20,
        locationButtonBackgroundColor: Colors.white,
        showLocationController: true,
        zoomButtonsBackgroundColor: Colors.white,
        searchBarBackgroundColor: Colors.white,
        searchBarHintText: 'Байршил хайх',
        selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
        selectLocationButtonText: '',
        selectLocationButtonWidth: size.width * 0.2,
        selectLocationButtonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
        ),
        showSearchBar: false,
        mapLanguage: 'en',
        mapAnimationDuration: const Duration(milliseconds: 500),
        selectLocationButtonLeadingIcon: const Icon(Icons.check),
        onPicked: (pickedData) {
          print('location ${pickedData.latLong.latitude}');
        },
        onChanged: (pickedData) {
          print(pickedData.latLong.latitude);
          print(pickedData.latLong.longitude);
        },
        showContributorBadgeForOSM: true,
      ),
    );
  }
}
