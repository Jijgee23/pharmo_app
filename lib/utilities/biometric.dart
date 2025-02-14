import 'package:local_auth/local_auth.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available
  static void isBiometricAvailable() async {
    try {
      print(await _auth.canCheckBiometrics);
    } catch (e) {
      message("Error checking biometrics: $e");
      // return 'false';
    }
  }

  /// Request permission for biometrics
  // static Future<bool> requestBiometricPermission() async {
  // Check if biometric authentication is available
  // bool isAvailable = await isBiometricAvailable();
  // if (!isAvailable) {
  //   message("❌ Biometrics not available.");
  //   return false;
  // } else {
  //   message('Bio metrics available');
  // }
  // return false;

  // Request biometric permission
  // PermissionStatus status = await Permission.sensors.request();
  // if (status.isDenied) {
  //   message("❌ Permission denied.");
  //   return false;
  // }

  // if (status.isPermanentlyDenied) {
  //   message("⚠️ Permission permanently denied. Open settings to enable.");
  //   await openAppSettings();
  //   return false;
  // }

  // Perform authentication
  // return await _auth.authenticate(
  //   localizedReason: "Authenticate to access the app",
  //   options: const AuthenticationOptions(
  //     biometricOnly: true, // Only allow biometrics
  //     stickyAuth: true, // Keep session active
  //     useErrorDialogs: true, // Show system dialog
  //   ),
  // );
  // }
}
