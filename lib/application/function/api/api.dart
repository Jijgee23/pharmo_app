import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/application/application.dart' hide Response;

Future<Response?> api(
  Api method,
  String endpoint, {
  Map<String, dynamic>? body,
  Map<String, String>? header,
}) async {
  try {
    final hasInternet = await NetworkChecker.hasInternet();
    if (!hasInternet) return null;

    await Authenticator.initAuthenticator();
    if (Authenticator.security == null) return null;

    // 401 + refresh логик AuthInterceptor-т шилжсэн
    final res = await responser(method, endpoint, body, header);
    if (res == null) {
      messageError('Серверт холбогдож чадсангүй, Инфосистемс ХХК-д холбогдоно уу!');
    }
    return res;
  } catch (e) {
    if (e is DioException) {
      messageError('Серверт холбогдож чадсангүй, Инфосистемс ХХК-д холбогдоно уу!');
    }
    debugPrint('Error in $method request to $endpoint: $e');
    return null;
  }
}

Future<void> showLogoutDialog(BuildContext context, String reason) async {
  await showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red top accent bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 28),
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4B4B), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                child: Column(
                  spacing: 16,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF4B4B).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFFF4B4B),
                        size: 28,
                      ),
                    ),
                    Text(
                      reason,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xFFFF4B4B),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.read<AuthController>().logout(
                              context,
                              withoutRequest: true,
                            ),
                        child: Text(
                          'Нэвтрэх',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

bool apiSucceess(Response? res) {
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

Future<Response?> responser(
  Api method,
  String endpoint,
  Map<String, dynamic>? body,
  Map<String, String>? header,
) async {
  final String url = ApiService.buildUrl(endpoint).toString();
  // Authorization header-г AuthInterceptor автоматаар нэмнэ
  final Map<String, String> headers = {
    ...header ?? {},
    ...ApiService.buildHeader(null),
  };
  final options = Options(headers: headers);
  final dio = ApiService.dio;
  late Response res;
  switch (method) {
    case Api.get:
      res = await dio.get(url, options: options);
    case Api.post:
      res = await dio.post(url, data: body, options: options);
    case Api.patch:
      res = await dio.patch(url, data: body, options: options);
    case Api.delete:
      res = await dio.delete(url, data: body, options: options);
  }
  if (kDebugMode) {
    debugPrint('[$endpoint] status: ${res.statusCode} body: ${res.data}');
  }
  return res;
}

Future<bool> refreshed() async {
  await Authenticator.initAuthenticator();
  final user = Authenticator.security;

  if (user == null) return false;
  final access = user.access;
  try {
    final response = await apiPostWithoutToken(
      'auth/refresh/',
      {"refresh": user.refresh},
    );
    if (response == null || !apiSucceess(response)) return false;
    final data = convertData(response);
    print('Refresh token response data: $data');
    final newAccess = data['access'];
    if (newAccess == null) return false;
    await Authenticator.updateAccess(newAccess);
    final updated = await Authenticator.getSecurity();
    if (updated == null) return false;
    return updated.access != access;
  } catch (e) {
    debugPrint('Error refreshing token: $e');
    return false;
  }
}

Map<String, dynamic> buildResponse(int errorType, dynamic data, String? message) {
  return {
    'errorType': errorType,
    'data': data,
    'message': message,
  };
}

Future<Response?> apiPostWithoutToken(
  String endPoint,
  Object? body,
) async {
  try {
    final connected = await NetworkChecker.hasInternet();
    if (!connected) {
      messageWarning('Интернет холболтоо шалгана уу!');
      return null;
    }
    return await ApiService.plainDio
        .post(
          ApiService.buildUrl(endPoint).toString(),
          data: body,
          options: Options(headers: ApiService.buildHeader(null)),
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

dynamic convertData(Response response) {
  final data = response.data;
  // Dio-ийн default transformer нь content-type='application/json'
  // тохиолдолд аль хэдийн decode хийсэн байдаг; backend буруу
  // content-type буцаавал түүхий String хэвээр ирнэ тул тэр тохиолдолд
  // өмнөх http-суурьтай хувилбартай адил гараар jsonDecode хийнэ.
  if (data is String) {
    if (data.isEmpty) return data;
    return jsonDecode(data);
  }
  return data;
}

Future<Response?> apiMacsMn(Object o, StackTrace s) async {
  try {
    final isOnline = await NetworkChecker.hasInternet();
    if (!isOnline) return null;
    final deviceManager = DeviceManager();
    final device = await deviceManager.deviceInfo();
    return await ApiService.plainDio.post(
      '${dotenv.env['MACS']}logs/pharmo_error/',
      data: {
        "error_message": o.toString(),
        "stack_trace": s.toString(),
        "os": device.os,
        "os_version": device.osVersion,
        "device_name": device.name,
        "app_version": await deviceManager.loadVersionAppversion(),
        "app_name": "Pharmo",
      },
      options: Options(
        headers: {
          "Connection": "Keep-Alive",
          "Accept": "application/json",
          "Content-type": "application/json",
          "charset": "utf-8",
          "checkcode": "46",
        },
      ),
    );
  } catch (e) {
    if (e is SocketException) {
      debugPrint(e.toString());
    }
    throw Exception(e);
  }
}
