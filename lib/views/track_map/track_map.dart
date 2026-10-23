import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/orderer_orders.dart';
import 'package:pharmo_app/views/track_map/delivery_panel.dart';
import 'package:pharmo_app/views/track_map/map_buttons.dart';
import 'package:pharmo_app/views/track_map/map_heading.dart';
import 'package:pharmo_app/views/track_map/seller_track_button.dart';
import 'package:pharmo_app/views/track_map/stop_markers.dart';
import 'package:pharmo_app/views/track_map/track_permission_page.dart';

/// The tracking map: a D/VS tab (their delivery's stops, the route so far
/// and the delivery panel), or a page a seller pushes for their route.
class TrackMap extends StatefulWidget {
  const TrackMap({super.key});

  @override
  State<TrackMap> createState() => _TrackMapState();
}

class _TrackMapState extends State<TrackMap> {
  JaggerProvider? _jagger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jagger = context.read<JaggerProvider>();
  }

  @override
  void dispose() {
    // The GoogleMap platform view (and its controller) dies with this
    // widget; drop the reference so nothing tries to use it afterwards.
    _jagger?.clearMapController();
    super.dispose();
  }

  // Not behind the blocking loader: the map and the panel show their own
  // loading, and the tab is visited often.
  Future<void> init() async {
    final user = Authenticator.security;
    final jag = context.read<JaggerProvider>();
    if (user == null) return;
    await jag.loadPermission();
    await jag.loadTrackState();
    if (user.isDeliveryCapable) await jag.getDeliveries();
    if (user.isSaler) await jag.checkSellerTrack();
  }

  @override
  Widget build(BuildContext context) {
    final user = Authenticator.security;
    if (user == null) return const Scaffold();
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final permission = jagger.permission;
        if (permission == null) {
          return const Scaffold(body: Center(child: PharmoIndicator()));
        }
        final showMap = permission == LocationPermission.always &&
            jagger.accuracy == LocationAccuracyStatus.precise;
        if (!showMap) return const TrackPermissionPage();

        final isSeller = user.isSaler;
        final insets = MediaQuery.of(context).padding;
        // A seller's map is a page of its own; D/VS see it as a tab under
        // the floating bottom bar.
        final bottom = insets.bottom + (isSeller ? 16 : 100);
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: jagger.onMapCreated,
                markers: {
                  ...stopMarkers(
                    jagger.delivery,
                    onTap: (stop) => goto(OrdererOrders(stopKey: stop.key)),
                  ),
                  ...jagger.tripMarkers,
                },
                polylines: jagger.polylines,
                trafficEnabled: jagger.trafficEnabled,
                mapType: jagger.mapType,
                // Keeps the logo, and what "centre" means, clear of the
                // heading and of the panel at the bottom.
                padding: EdgeInsets.only(top: insets.top + 56, bottom: bottom + 80),
                compassEnabled: true,
                mapToolbarEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                buildingsEnabled: false,
                initialCameraPosition: CameraPosition(
                  bearing: jagger.bearing,
                  tilt: jagger.tilt,
                  target: jagger.latLng,
                  zoom: jagger.zoomIndex,
                ),
              ),
              Positioned(top: 0, left: 0, right: 0, child: MapHeading(isSeller: isSeller)),
              Positioned(
                left: 16,
                right: 16,
                bottom: bottom,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(alignment: Alignment.centerRight, child: MapControls()),
                    const SizedBox(height: 12),
                    if (isSeller)
                      const Align(alignment: Alignment.centerLeft, child: SellerTrackButton())
                    else if (user.isDeliveryCapable)
                      const DeliveryPanel(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
