import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/application/function/api/api.dart';
import 'package:pharmo_app/application/function/api/auth_interceptor.dart';

class ApiService {
  static Map<String, String> buildHeader(String? token, {bool toPharmo = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (toPharmo) 'X-Pharmo-Client': '!pharmo_app?',
      if (token != null) 'Authorization': token,
    };
    return headers;
  }

  static Uri buildUrl(String endPoint) {
    Uri url = Uri.parse('${dotenv.env['SERVER_URL']}$endPoint');
    return url;
  }

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: dotenv.env['SERVER_URL'] ?? '',
        // http.Response never threw for non-2xx status codes - callers
        // branch on r.statusCode themselves (400, 403, ... are expected
        // control flow, not exceptions). Keep that behavior under Dio.
        validateStatus: (_) => true,
      );

  /// Token interceptor бүхий client — authenticated хүсэлтэд ашиглана
  static final Dio dio = Dio(_baseOptions)..interceptors.add(AuthInterceptor());

  /// Token шаардахгүй хүсэлтэд (login, register, refresh г.м.)
  static final Dio plainDio = Dio(_baseOptions);

  static Future<bool> successRefresh() async {
    try {
      bool success = await refreshed();
      return success;
    } catch (e) {
      throw Exception(e);
    }
  }
}
