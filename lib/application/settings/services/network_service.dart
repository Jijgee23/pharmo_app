import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  static Future<bool> hasInternet() async {
    // 1. Техник холболтыг шалгах (Wi-Fi эсвэл Mobile Data асаалттай юу?)
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false; // Ямар ч сүлжээнд холбогдоогүй байна
    }

    // 2. Бодит интернэт байгаа эсэхийг шалгах (Google рүү хандаж үзэх)
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3)); // 3 секундээс илүү хүлээхгүй

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Интернэт байна
      }
    } on SocketException catch (_) {
      return false; // Холболт байхгүй эсвэл DNS ажиллахгүй байна
    } on Exception catch (_) {
      return false;
    }

    return false;
  }
}
