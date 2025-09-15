import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';

class SellerTracking extends StatefulWidget {
  const SellerTracking({super.key});

  @override
  State<SellerTracking> createState() => _SellerTrackingState();
}

class _SellerTrackingState extends State<SellerTracking> {
  @override
  void initState() {
    super.initState();
    initer();
  }

  void initer() async {
    // final provider = context.read<LocationProvider>();
    // provider.bgState();
  }

  bool mapView = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, tracker, child) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
                onTap: () {
                  setState(() {
                    mapView = !mapView;
                  });
                },
                child: Text('Байршил дамжуулах')),
            actions: [
              IconButton(
                onPressed: () => tracker.startTracking(),
                icon: Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () => tracker.stopTracking(),
                icon: Icon(Icons.cancel),
              ),
            ],
          ),
          body: !mapView
              ? ListView.builder(
                  itemCount: tracker.offlineLocs.length,
                  itemBuilder: (context, idx) {
                    var item = tracker.offlineLocs[idx];
                    return ListTile(
                      dense: true,
                      onTap: () => tracker.deleteFromLocalDb(item),
                      subtitleTextStyle: TextStyle(color: black),
                      leading:
                          Text(idx.toString(), style: TextStyle(color: black)),
                      title: Text(item.lat.toString(),
                          style: TextStyle(color: black)),
                      subtitle: Text(item.lng.toString(),
                          style: TextStyle(color: black)),
                      trailing: Icon(Icons.circle,
                          color: item.success ? Colors.green : Colors.red),
                    );
                  },
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: tracker.latLng,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) =>
                          tracker.onMapCreated(controller),
                      onTap: (argument) {},
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      mapType: tracker.currentMapType,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      trafficEnabled: tracker.trafficEnabled,
                      polylines: {
                        if (tracker.data.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId("route"),
                            points: List.generate(
                              tracker.data.length,
                              (index) => LatLng(
                                tracker.data[index].latitude,
                                tracker.data[index].longitude,
                              ),
                            ),
                            color: Colors.red,
                            width: 5,
                          ),
                      },
                    ),
                    Positioned(
                      top: 40,
                      left: 15,
                      child: FloatingActionButton(
                        heroTag: 'back',
                        mini: true,
                        onPressed: () => Navigator.of(context).pop(),
                        backgroundColor: Colors.white,
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      right: 15,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoomIn',
                            mini: true,
                            onPressed: () {
                              tracker.mapController
                                  ?.animateCamera(CameraUpdate.zoomIn());
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.add, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'zoomOut',
                            mini: true,
                            onPressed: () {
                              tracker.mapController
                                  ?.animateCamera(CameraUpdate.zoomOut());
                            },
                            backgroundColor: Colors.white,
                            child:
                                const Icon(Icons.remove, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'myLocation',
                            mini: true,
                            onPressed: tracker.goToMyLocation,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.my_location,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'toggleTraffic',
                            mini: true,
                            onPressed: tracker.toggleTraffic,
                            backgroundColor: tracker.trafficEnabled
                                ? Colors.blue
                                : Colors.white,
                            child:
                                const Icon(Icons.traffic, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            heroTag: 'changeMapType',
                            mini: true,
                            onPressed: tracker.changeMapType,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.map, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 15,
                      right: 15,
                      child: Row(
                        spacing: 20,
                        children: [
                          if (tracker.positionSubscription == null)
                            button(tracker: tracker),
                          if (tracker.positionSubscription != null)
                            button(tracker: tracker, isStart: false),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget button({required LocationProvider tracker, bool isStart = true}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          askDialog(
            context,
            () {
              isStart ? tracker.startTracking() : tracker.stopTracking();
              Navigator.pop(context);
            },
            isStart
                ? 'Байршлыг дамжуулж эхлэх үү?'
                : 'Байршил дамжуулалтыг дуусгах уу?',
            [],
          );
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isStart ? Colors.green : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isStart ? 'Эхлэх' : 'Дуусгах',
              style: TextStyle(
                color: isStart ? white : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              isStart ? Icons.gps_fixed : Icons.gps_off,
              color: isStart ? white : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
