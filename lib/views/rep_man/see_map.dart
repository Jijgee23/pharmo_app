import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/rep_provider.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class SeeMap extends StatefulWidget {
  const SeeMap({super.key});

  @override
  State<SeeMap> createState() => _SeeMapState();
}

class _SeeMapState extends State<SeeMap> {
  @override
  void initState() {
    super.initState();
    setLoc();
  }

  setLoc() {
    final rep = context.read<RepProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rep.setPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepProvider>(builder: (context, rep, child) {
      final p = rep.currentPosition;
      return Scaffold(
        appBar: CustomAppBar(
          title: Text('Газрын зураг'),
          leading: ChevronBack(),
        ),
        extendBody: true,
        body: SafeArea(
          child: GoogleMap(
            trafficEnabled: true,
            mapType: MapType.terrain,
            compassEnabled: true,
            mapToolbarEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: p != null
                  ? LatLng(p.latitude, p.longitude)
                  : const LatLng(47.918873, 106.917572),
              zoom: 14,
            ),
          ),
        ),
      );
    });
  }
}
