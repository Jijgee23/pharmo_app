// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pharmo_app/widgets/inputs/custom_button.dart';
// import 'package:restart_app/restart_app.dart';
// import 'package:shorebird_code_push/shorebird_code_push.dart';

// class Updater {
//   static ShorebirdUpdater updater = ShorebirdUpdater();
//   static bool isUpdaterAvailable = updater.isAvailable;
//   static bool checking = false;
//   Patch? currentPatch;
//   static var currentTrack = UpdateTrack.stable;
//   static bool downloading = false;
//   static Future<void> checkForUpdate() async {
//     checking = true;
//     if (!isUpdaterAvailable) {
//       checking = false;
//       return;
//     }
//     try {
//       final status = await updater.checkForUpdate(track: currentTrack);
//       switch (status) {
//         case UpdateStatus.outdated:
//           await updater.update(track: currentTrack).whenComplete(() async {
//             await restartBanner();
//           });
//         case UpdateStatus.upToDate:
//           debugPrint('Шинэчлэлт шаардлагагүй');
//           break;
//         case UpdateStatus.restartRequired:
//           debugPrint('Дахин ачаалалт шаардагдаж байна');
//           await restartBanner();
//           break;
//         case UpdateStatus.unavailable:
//           debugPrint('Шинэчлэлт боломжгүй байна');
//           break;
//       }
//     } catch (error) {
//       debugPrint('Error checking for update: $error');
//     } finally {
//       checking = false;
//     }
//   }

//   static Future<void> download() async {
//     await updater.update(track: currentTrack);
//   }

//   void checkSilently() async {
//     final status = await updater.checkForUpdate(track: currentTrack);
//     if (status == UpdateStatus.restartRequired) {
//       await restartBanner();
//     }
//   }

//   static Future<void> restartBanner() async {
//     return Get.dialog(
//       Material(
//         color: Colors.transparent,
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             margin: const EdgeInsets.symmetric(horizontal: 30),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Шинэчлэлт татагдлаа!',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Дахин ачаалах шаардлагатай!',
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   CustomButton(
//                     text: 'Дахин ачаалуулах',
//                     ontap: () {
//                       Restart.restartApp(
//                         notificationTitle: 'Шинэчлэлт татагдлаа',
//                         notificationBody: 'Энд дарж нээнэ үү!',
//                       );
//                       checking = false;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
