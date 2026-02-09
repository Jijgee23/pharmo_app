import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/track_map/driver_button.dart';
import 'package:pharmo_app/views/track_map/map_buttons.dart';
import 'package:pharmo_app/views/track_map/map_heading.dart';
import 'package:pharmo_app/views/track_map/seller_track_button.dart';
import 'package:pharmo_app/views/track_map/track_permission_page.dart';
import 'package:pharmo_app/views/track_map/tracking_status_card.dart';

class TrackMap extends StatefulWidget {
  const TrackMap({super.key});

  @override
  State<TrackMap> createState() => _TrackMapState();
}

class _TrackMapState extends State<TrackMap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await init(),
    );
  }

  Future<void> init() async {
    final user = Authenticator.security;
    final jag = context.read<JaggerProvider>();
    if (user == null) return;

    await LoadingService.run(() async {
      await jag.loadPermission();
      await jag.loadTrackState();

      if (user.isDriver) {
        await jag.getDeliveries();
      }
      if (user.isSaler) {
        await jag.checkSellerTrack();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Authenticator.security;
    if (user == null) return Scaffold();
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool isSeller = user.isSaler;
        LocationPermission? per = jagger.permission;
        LocationAccuracyStatus? accuracy = jagger.accuracy;
        bool backgrounEnabled = per != null && per == LocationPermission.always;
        bool isPrecise =
            accuracy != null && accuracy == LocationAccuracyStatus.precise;
        final showMap = backgrounEnabled && isPrecise;
        final showTracking =
            jagger.subscription != null && !jagger.subscription!.isPaused;
        if (showMap) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => jagger.onMapCreated(controller),
                markers: {...jagger.orderMarkers},
                trafficEnabled: jagger.trafficEnabled,
                mapType: jagger.mapType,
                compassEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: true,
                buildingsEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  bearing: jagger.bearing,
                  tilt: jagger.tilt,
                  target: jagger.latLng,
                  zoom: jagger.zoomIndex,
                ),
                tiltGesturesEnabled: true,
                polylines: jagger.polylines,
              ),
              MapButtons(),
              MapHeading(isSeller: isSeller, showTracking: showTracking),
              if (showTracking) const TrackingStatusCard(),
              // if (!isSeller) const DeliveryInfoCard(),
              DriverButton(),
              SellerTrackButton(),
            ],
          );
        }
        return TrackPermissionPage();
      },
    );
  }
}
