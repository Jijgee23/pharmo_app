import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pharmo_app/application/application.dart';

Future<http.Response?> api(
  Api method,
  String endpoint, {
  Map<String, dynamic>? body,
  Map<String, String>? header,
}) async {
  try {
    final hasInternet = await NetworkChecker.hasInternet();
    if (!hasInternet) return null;
    await LocalBase.initLocalBase();
    final security = LocalBase.security;
    if (security == null) return null;
    final access = security.access;
    if (JwtDecoder.isExpired(access)) {
      bool refreshExpired = JwtDecoder.isExpired(security.refresh);
      if (refreshExpired) {
        await showLogoutDialog(Get.context!,
            'Хэрэглэгчийн хандах эрх дууссан байна! \n Нэвтэрнэ үү!');
        return null;
      }
      bool success = await refreshed();
      if (!success) {
        await showLogoutDialog(
          Get.context!,
          'Хэрэглэгчийн хандах эрх дууссан байна! \n Нэвтэрнэ үү!',
        );
        return null;
      }
      var s = await LocalBase.getSecurity();
      if (s == null) return null;
      return await api(method, endpoint, body: body, header: header);
    }
    var res = await responser(method, endpoint, access, body, header);
    if (res != null) {
      print('$endpoint, status code: ${res.statusCode}');
      // print('track api info: ${res.body}');
      if (res.statusCode == 401) {
        await showLogoutDialog(
          Get.context!,
          'Өөр төхөөрөмжөөс нэвтэрсэн байна! \n Нэвтэрнэ үү!',
        );
        return null;
      }
    }
    return res;
  } catch (e) {
    debugPrint('Error in $method request to $endpoint: $e');
    return null;
  }
}

void printGreen(String message) {
  print('\x1B[32m$message\x1B[0m');
}

Future showLogoutDialog(BuildContext context, String reason) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              spacing: 20,
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 30,
                ),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.read<AuthController>().logout(
                            context,
                            withoutRequest: true,
                          ),
                      child: Text('Нэвтрэх'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

bool apiSucceess(http.Response? res) {
  if (res == null) {
    messageError('Сервертэй холбогдож чадсангүй!');
    return false;
  }

  final code = res.statusCode;
  if (code == 200 || code == 201) {
    return true;
  }
  return false;
}

Future<http.Response?> responser(
  Api method,
  String endpoint,
  String access,
  Map<String, dynamic>? body,
  Map<String, String>? header,
) async {
  final Uri url = setUrl(endpoint);
  // print(url);

  Map<String, String> headers = {
    ...header ?? {},
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Pharmo-Client': '!pharmo_app?',
    'Authorization': 'Bearer $access',
  };

  http.Response res;
  switch (method) {
    case Api.get:
      res = await http.get(url, headers: headers);
    case Api.post:
      res = await http.post(url, headers: headers, body: jsonEncode(body));
    case Api.patch:
      res = await http.patch(url, headers: headers, body: jsonEncode(body));
    case Api.delete:
      res = await http.delete(url, headers: headers);
  }
  if (res != null) {
    // debugPrint(res.statusCode.toString());
    // debugPrint(res.body.toString());
  }
  return res;
}

Future<bool> refreshed() async {
  print('refreshing');
  final hasInternet = await NetworkChecker.hasInternet();
  if (hasInternet) return false;
  await LocalBase.initLocalBase();
  final user = LocalBase.security;
  if (user == null) return false;
  final oldAccess = user.access;
  var b = {"refresh": user.refresh};
  try {
    final k = await apiPostWithoutToken('auth/refresh/', b);
    if (k == null) return false;
    if (apiSucceess(k)) {
      Map<String, dynamic> res = convertData(k);
      print('token refreshed: ${res['access'] != oldAccess}');
      await LocalBase.updateAccess(res['access']);
      final newAccess = await LocalBase.getAccess();
      print('oldAccess: $oldAccess');
      print('newAccess: $newAccess');
      return true;
    }
  } catch (e) {
    throw Exception('Error refreshing token: $e');
  }
  return false;
}

Map<String, dynamic> buildResponse(
    int errorType, dynamic data, String? message) {
  return {
    'errorType': errorType,
    'data': data,
    'message': message,
  };
}

Future<http.Response?> apiPostWithoutToken(
    String endPoint, Object? body) async {
  try {
    final connected = await NetworkChecker.hasInternet();
    if (connected) {
      var response = await http
          .post(
            setUrl(endPoint),
            headers: getHeader(null),
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 5));
      return response;
    }
    messageWarning('Интернет холболтоо шалгана уу!');
  } catch (e) {
    if (e is TimeoutException) {
      messageError('Түр хүлээнэ үү!');
      return null;
    }
  }
  return null;
}

getHeader(String? token) {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Pharmo-Client': '!pharmo_app?',
    if (token != null) 'Authorization': token,
  };
  return headers;
}

setUrl(String endPoint) {
  Uri url = Uri.parse('${dotenv.env['SERVER_URL']}$endPoint');
  return url;
}

dynamic convertData(http.Response body) {
  final d = jsonDecode(utf8.decode(body.bodyBytes));
  return d;
}

getApiInformation(String endPoint, http.Response response) {
  try {
    print('<===$endPoint===>');
    print('<===${response.statusCode}===>');
    print('<===${response.body}===>');
  } catch (e) {
    debugPrint('ERROR at $endPoint : $e');
  }
}

Future<String> loadVersionAppversion() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

Future<http.Response> apiMacsMn(Object o, StackTrace s) async {
  var url = Uri.parse('${dotenv.env['MACS']}logs/pharmo_error');
  final device = await deviceInfo();
  var b = {
    "error_message": o.toString(),
    "stack_trace": s.toString(),
    "os": device.os,
    "os_version": device.osVersion,
    "device_name": device.name,
    "app_version": await loadVersionAppversion(),
    "app_name": "Pharmo"
  };
  final res = await http.post(
    url,
    headers: {
      "Connection": "Keep-Alive",
      "Accept": "application/json",
      "Content-type": "application/json",
      "charset": "utf-8",
      "checkcode": "46",
    },
    body: jsonEncode(b),
  );
  return res;
}

Future<Device> deviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final token = await FirebaseApi.getToken();
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    return Device(
      brand: 'Apple',
      name: iosInfo.name,
      model: iosInfo.model,
      modelVersion: iosInfo.utsname.machine,
      os: iosInfo.systemName,
      osVersion: iosInfo.systemVersion,
      id: iosInfo.identifierForVendor ?? '',
      firebaseToken: token,
      type: "IOS",
    );
  }
  AndroidDeviceInfo android = await deviceInfoPlugin.androidInfo;
  return Device(
    brand: android.brand,
    name: android.name,
    model: android.model,
    modelVersion: android.device,
    os: Platform.operatingSystem,
    osVersion: Platform.operatingSystemVersion,
    id: android.id,
    firebaseToken: token,
    type: "ANDROID",
  );
}

const String contactUsMessage = 'Алдаа гарлаа, ИНФОСИСТЕМС ХХК-д хандана уу!';

class Device {
  final String brand;
  final String name;
  final String model;
  final String modelVersion;
  final String os;
  final String osVersion;
  final String id;
  final String firebaseToken;
  final String type;
  Device({
    required this.brand,
    required this.name,
    required this.model,
    required this.modelVersion,
    required this.os,
    required this.osVersion,
    required this.id,
    required this.firebaseToken,
    required this.type,
  });
}
