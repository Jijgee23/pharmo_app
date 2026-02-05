import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/application/function/api/api.dart';

class ApiService {
  static Map<String, String> buildHeader(String? token,
      {bool toPharmo = true}) {
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

  static http.Client client = http.Client();

  static final constResponse = http.Response('101', 101);

  static Future<bool> successRefresh() async {
    try {
      bool success = await refreshed();
      return success;
    } catch (e) {
      throw Exception(e);
    }
  }
}
