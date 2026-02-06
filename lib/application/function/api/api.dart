import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    await Authenticator.initAuthenticator();
    final security = Authenticator.security;
    if (security == null) return null;

    final res =
        await responser(method, endpoint, security.access, body, header);
    if (res == null) {
      messageError(
          'Серверт холбогдож чадсангүй, Инфосистемс ХХК-д холбогдоно уу!');
      return null;
    }

    // 401 — token хөөлөн expires болсон тэмэл дахин refresh-ийн оролдлого
    if (res.statusCode == 401) {
      final code = convertData(res)['code'];
      if (code == "token_not_valid") {
        print('token_not_valid');
        bool refreshSuccess = await refreshed();
        print("Refresh success: $refreshSuccess");
        if (refreshSuccess) {
          final updated = await Authenticator.getSecurity();
          if (updated != null) {
            return responser(method, endpoint, updated.access, body, header);
          }
        }
        LoadingService.hide();
        await showLogoutDialog(
          Get.context!,
          'Хэрэглэгчийн хандах эрх дууссан байна! \n Нэвтэрнэ үү!',
        );
        return null;
      }
      if (code == "authentication_failed") {
        LoadingService.hide();
        await showLogoutDialog(
          Get.context!,
          'Өөр төхөөрөмжөөс нэвтэрсэн байна! \n Нэвтэрнэ үү!',
        );
        return null;
      }
    }

    return res;
  } catch (e) {
    if (e is http.ClientException) {
      messageError(
          'Серверт холбогдож чадсангүй, Инфосистемс ХХК-д холбогдоно уу!');
    }
    debugPrint('Error in $method request to $endpoint: $e');
    return null;
  }
}

Future<void> showLogoutDialog(BuildContext context, String reason) async {
  await showDialog(
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

Future<http.Response> responser(
  Api method,
  String endpoint,
  String access,
  Map<String, dynamic>? body,
  Map<String, String>? header,
) async {
  final Uri url = ApiService.buildUrl(endpoint);
  final Map<String, String> headers = {
    ...header ?? {},
    ...ApiService.buildHeader('Bearer $access'),
  };
  final client = ApiService.client;
  late http.Response res;
  switch (method) {
    case Api.get:
      res = await client.get(url, headers: headers);
    case Api.post:
      res = await client.post(url, headers: headers, body: jsonEncode(body));
    case Api.patch:
      res = await client.patch(url, headers: headers, body: jsonEncode(body));
    case Api.delete:
      res = await client.delete(url, headers: headers, body: jsonEncode(body));
  }
  // if (kDebugMode) {
  //   debugPrint('[$endpoint] status: ${res.statusCode} body: ${res.body}');
  // }
  return res;
}

Future<bool> refreshed() async {
  // final hasInternet = await NetworkChecker.hasInternet();
  // if (!hasInternet) return false;
  await Authenticator.initAuthenticator();
  final user = Authenticator.security;
  if (user == null) return false;
  try {
    final response = await apiPostWithoutToken(
      'auth/refresh/',
      {"refresh": user.refresh},
    );
    if (response == null || !apiSucceess(response)) return false;
    await Authenticator.updateAccess(convertData(response)['access']);
    return true;
  } catch (e) {
    debugPrint('Error refreshing token: $e');
    return false;
  }
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
  String endPoint,
  Object? body,
) async {
  try {
    final connected = await NetworkChecker.hasInternet();
    if (!connected) {
      messageWarning('Интернет холболтоо шалгана уу!');
      return null;
    }
    return await ApiService.client
        .post(
          ApiService.buildUrl(endPoint),
          headers: ApiService.buildHeader(null),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    if (e is TimeoutException) {
      messageError('Түр хүлээнэ үү!');
    } else {
      debugPrint('apiPostWithoutToken error at $endPoint: $e');
    }
    return null;
  }
}

dynamic convertData(http.Response body) {
  return jsonDecode(utf8.decode(body.bodyBytes));
}

Future<http.Response?> apiMacsMn(Object o, StackTrace s) async {
  try {
    final isOnline = await NetworkChecker.hasInternet();
    if (!isOnline) return null;
    final deviceManager = DeviceManager();
    final device = await deviceManager.deviceInfo();
    return await ApiService.client.post(
      Uri.parse('${dotenv.env['MACS']}logs/pharmo_error/'),
      headers: {
        "Connection": "Keep-Alive",
        "Accept": "application/json",
        "Content-type": "application/json",
        "charset": "utf-8",
        "checkcode": "46",
      },
      body: jsonEncode({
        "error_message": o.toString(),
        "stack_trace": s.toString(),
        "os": device.os,
        "os_version": device.osVersion,
        "device_name": device.name,
        "app_version": await deviceManager.loadVersionAppversion(),
        "app_name": "Pharmo",
      }),
    );
  } catch (e) {
    if (e is SocketException) {
      debugPrint(e.toString());
    }
    throw Exception(e);
  }
}
