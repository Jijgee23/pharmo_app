// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:pharmo_app/application/application.dart';
// import 'package:pharmo_app/views/SELLER/track/track_permission_page.dart';

// class SellerTracking extends StatefulWidget {
//   const SellerTracking({super.key});
//   @override
//   State<SellerTracking> createState() => _SellerTrackingState();
// }

// class _SellerTrackingState extends State<SellerTracking> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) async => await context.read<JaggerProvider>().loadPermission(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<JaggerProvider>(
//       builder: (context, jagger, child) {
//         LocationPermission? per = jagger.permission;
//         LocationAccuracyStatus? accuracy = jagger.accuracy;
//         bool backgrounEnabled = per != null && per == LocationPermission.always;
//         bool isPrecise =
//             accuracy != null && accuracy == LocationAccuracyStatus.precise;
//         final showMap = backgrounEnabled && isPrecise;
//         return Scaffold(
//           appBar: (showMap) ? null : AppBar(),
//           body: Builder(
//             builder: (context) {
//               if (showMap) {
//                 return Stack(
//                   children: [
//                     GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: jagger.latLng,
//                         zoom: jagger.zoomIndex,
//                         bearing: jagger.bearing,
//                         tilt: jagger.tilt,
//                       ),
//                       onMapCreated: (c) => jagger.onMapCreated(c),
//                       onTap: (argument) {},
//                       compassEnabled: true,
//                       mapToolbarEnabled: false,
//                       mapType: MapType.terrain,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: false,
//                       trafficEnabled: jagger.trafficEnabled,
//                       polylines: jagger.polylines,
//                     ),
//                     Positioned(
//                       top: 0,
//                       left: 25,
//                       child: SafeArea(
//                         child: Row(
//                           spacing: 20,
//                           children: [
//                             FloatingActionButton(
//                               heroTag: 'backST',
//                               // mini: true,
//                               onPressed: () => Navigator.of(context).pop(),
//                               backgroundColor: white,
//                               child: const Icon(
//                                 Icons.arrow_back,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             if (jagger.subscription != null &&
//                                 !jagger.subscription!.isPaused)
//                               FloatingActionButton.extended(
//                                 heroTag: 'hasTrackST',
//                                 onPressed: () async {
//                                   await jagger.updateDatasToSended();
//                                   // await nativeSettingsChannel
//                                   //     .invokeMethod('requestLocationPermissions');
//                                 },
//                                 backgroundColor: Colors.teal,
//                                 label: Text(
//                                   'Байршил дамжуулж байна...',
//                                   style: TextStyle(color: white),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 100,
//                       right: 15,
//                       child: SafeArea(
//                         child: Column(
//                           children: [
//                             FloatingActionButton(
//                               heroTag: 'zoomInST',
//                               elevation: 20,
//                               onPressed: () {
//                                 jagger.zoomIn();
//                               },
//                               backgroundColor: Colors.white,
//                               child: const Icon(Icons.add, color: Colors.black),
//                             ),
//                             const SizedBox(height: 10),
//                             FloatingActionButton(
//                               heroTag: 'zoomOutST',
//                               elevation: 20,
//                               onPressed: () {
//                                 jagger.zoomOut();
//                               },
//                               backgroundColor: Colors.white,
//                               child:
//                                   const Icon(Icons.remove, color: Colors.black),
//                             ),
//                             const SizedBox(height: 10),
//                             FloatingActionButton(
//                               heroTag: 'myLocationST',
//                               elevation: 20,
//                               onPressed: jagger.goToMyLocation,
//                               backgroundColor: Colors.white,
//                               child: const Icon(Icons.my_location,
//                                   color: Colors.black),
//                             ),
//                             const SizedBox(height: 10),
//                             FloatingActionButton(
//                               heroTag: 'toggleTrafficST',
//                               elevation: 20,
//                               onPressed: jagger.toggleTraffic,
//                               backgroundColor: jagger.trafficEnabled
//                                   ? Colors.blue
//                                   : Colors.white,
//                               child: const Icon(
//                                 Icons.traffic,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Positioned(
//                     //   bottom: 0,
//                     //   left: 15,
//                     //   right: 15,
//                     //   child: SafeArea(
//                     //     child: Row(
//                     //       spacing: 20,
//                     //       children: [
//                     //         if (jagger.subscription == null ||
//                     //             (jagger.subscription != null &&
//                     //                 jagger.subscription!.isPaused))
//                     //           button(tracker: jagger),
//                     //         if (jagger.subscription != null &&
//                     //             !jagger.subscription!.isPaused)
//                     //           button(tracker: jagger, isStart: false),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 );
//               }
//               return TrackPermissionPage();
//             },
//           ),
//         );
//       },
//     );
//   }
// }
