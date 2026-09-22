import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

class SeeMap extends StatefulWidget {
  const SeeMap({super.key});

  @override
  State<SeeMap> createState() => _SeeMapState();
}

class _SeeMapState extends State<SeeMap> {
  static const LatLng _ubFallback = LatLng(47.918873, 106.917572);

  GoogleMapController? _mapController;
  // GoogleMap.initialCameraPosition only applies once, at native-view
  // creation — once rep.currentPosition resolves asynchronously (after the
  // map has already been created with the UB fallback), changing that prop
  // has no effect on the already-live map. This flag lets the first real
  // fix trigger exactly one animateCamera() instead.
  bool _centeredOnRealPosition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RepProvider>().setPosition();
    });
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToPosition(Position p, {bool animate = true}) async {
    final controller = _mapController;
    if (controller == null) return;
    final target = CameraPosition(target: LatLng(p.latitude, p.longitude), zoom: 16);
    if (animate) {
      await controller.animateCamera(CameraUpdate.newCameraPosition(target));
    } else {
      await controller.moveCamera(CameraUpdate.newCameraPosition(target));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RepProvider>(
      builder: (context, rep, child) {
        final p = rep.currentPosition;

        if (p != null && !_centeredOnRealPosition) {
          _centeredOnRealPosition = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToPosition(p));
        }

        return Scaffold(
          appBar: const CustomAppBar(
            title: Text('Газрын зураг'),
            leading: ChevronBack(),
          ),
          extendBody: true,
          body: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  trafficEnabled: true,
                  mapType: MapType.terrain,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: p != null ? LatLng(p.latitude, p.longitude) : _ubFallback,
                    zoom: 14,
                  ),
                ),
                if (p == null)
                  const Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _LoadingPill(text: 'Байршил тодорхойлж байна...'),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'repSeeMapRecenter',
                    mini: true,
                    backgroundColor: white,
                    onPressed: p == null
                        ? null
                        : () => _goToPosition(p),
                    child: Icon(Icons.my_location, color: p == null ? grey400 : primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final String text;
  const _LoadingPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
