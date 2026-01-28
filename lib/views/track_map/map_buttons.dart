import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

class MapButtons extends StatelessWidget {
  const MapButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => Positioned(
        bottom: 20,
        right: 15,
        child: SafeArea(
          child: Column(
            spacing: 10,
            children: [
              FloatingActionButton(
                heroTag: 'zoomInDMANMAP',
                elevation: 20,
                onPressed: () {
                  jagger.mapController.animateCamera(
                    CameraUpdate.zoomIn(),
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
              ),
              FloatingActionButton(
                heroTag: 'zoomOutDMANMAP',
                elevation: 20,
                onPressed: () {
                  jagger.mapController.animateCamera(
                    CameraUpdate.zoomOut(),
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black),
              ),
              FloatingActionButton(
                heroTag: 'myLocationDMANMAP',
                elevation: 20,
                onPressed: jagger.goToMyLocation,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
              FloatingActionButton(
                heroTag: 'toggleTrafficDMANMAP',
                elevation: 20,
                onPressed: jagger.toggleTraffic,
                backgroundColor:
                    jagger.trafficEnabled ? Colors.blue : Colors.white,
                child: const Icon(
                  Icons.traffic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
