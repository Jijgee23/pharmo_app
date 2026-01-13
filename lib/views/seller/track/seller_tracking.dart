import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';

class SellerTracking extends StatefulWidget {
  const SellerTracking({super.key});

  @override
  State<SellerTracking> createState() => _SellerTrackingState();
}

class _SellerTrackingState extends State<SellerTracking>
    with WidgetsBindingObserver {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    readPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      readPermission();
    }
  }

  bool locHasAlways = false;

  void readPermission() async {
    bool value = await Settings.checkAlwaysLocationPermission();
    // if (value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        locHasAlways = value;
      });
    });
  }

  bool mapView = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, tracker, child) {
        if (!locHasAlways) {
          return Material(
            color: white,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text('Байршлыг зөвшөөрлийг идэвхижүүлнэ үү!'),
                  CustomButton(
                    text: 'Тохируулах',
                    ontap: () => openAppSettings(),
                  )
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: tracker.latLng,
                  zoom: 15,
                  bearing: 0,
                  tilt: 150,
                ),
                onMapCreated: (controller) => tracker.onMapCreated(controller),
                onTap: (argument) {},
                compassEnabled: true,
                mapToolbarEnabled: false,
                mapType: MapType.terrain,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                trafficEnabled: tracker.trafficEnabled,
                polylines: tracker.polylines,
              ),
              Positioned(
                top: 0,
                left: 25,
                child: SafeArea(
                  child: Row(
                    spacing: 20,
                    children: [
                      FloatingActionButton(
                        heroTag: 'back',
                        // mini: true,
                        onPressed: () => Navigator.of(context).pop(),
                        backgroundColor: white,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      if (tracker.subscription != null)
                        FloatingActionButton.extended(
                          heroTag: 'hasTrack',
                          onPressed: () {},
                          backgroundColor: Colors.teal,
                          label: Text(
                            'Байршил дамжуулж байна...',
                            style: TextStyle(color: white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 15,
                child: SafeArea(
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        elevation: 20,
                        onPressed: () {
                          tracker.mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        elevation: 20,
                        onPressed: () {
                          tracker.mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'myLocation',
                        elevation: 20,
                        onPressed: tracker.goToMyLocation,
                        backgroundColor: Colors.white,
                        child:
                            const Icon(Icons.my_location, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'toggleTraffic',
                        elevation: 20,
                        onPressed: tracker.toggleTraffic,
                        backgroundColor:
                            tracker.trafficEnabled ? Colors.blue : Colors.white,
                        child: const Icon(
                          Icons.traffic,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: SafeArea(
                  child: Row(
                    spacing: 20,
                    children: [
                      if (tracker.subscription == null)
                        button(tracker: tracker),
                      if (tracker.subscription != null)
                        button(tracker: tracker, isStart: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget button({required JaggerProvider tracker, bool isStart = true}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          bool confirmed = await confirmDialog(
            context: context,
            title:
                'Байршлыг ${isStart ? ' дамжуулж  эхлэх үү' : 'дамжуулалт дуусгах уу'} ?',
            message: isStart
                ? 'Борлуулалтын үед таны байршил хянахыг анхаарна уу!'
                : '',
          );
          if (!confirmed) return;
          isStart ? tracker.tracking() : tracker.stopTracking();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isStart ? Colors.green : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
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
