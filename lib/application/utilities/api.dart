import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/application/services/network_service.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

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

Future<http.Response?> api(Api method, String endpoint,
    {Map<String, dynamic>? body, Map<String, String>? header}) async {
  void onError() async {
    messageWarning('Хандах эрх дууссан эсвэл өөр төхөөрөмжөөс нэвтэрсэн!');
    await gotoRemoveUntil(const LoginPage());
  }

  try {
    Security? security = LocalBase.security;
    if (security == null) return null;
    bool accessExpired = JwtDecoder.isExpired(security.access);
    if (accessExpired) {
      bool refreshExpired = JwtDecoder.isExpired(security.refresh);
      if (!refreshExpired) {
        bool success = await refreshed();
        if (!success) {
          onError();
          return null;
        }
        var s = await LocalBase.getSecurity();
        if (s == null) return null;
        String access = s.access;
        var r = await responser(method, endpoint, access, body, header);
        if (r == null) {
          onError();
          return null;
        }
        if (r != null) {
          print('status code: ${r.statusCode}');
        }
        // if (showLog && r != null) getApiInformation(endpoint, r);
        return r;
      }
      onError();
      return null;
    }
    String access = security.access;
    var res = await responser(method, endpoint, access, body, header);
    if (res != null) {
      print('status code: ${res.statusCode}');
      if (res.statusCode == 401) {
        onError();
        return null;
      }
    }
    return res;
  } catch (e) {
    debugPrint('Error in $method request to $endpoint: $e');
    return null;
  }
}

bool apiSucceess(http.Response? res) {
  if (res == null) return false;
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
  print(url);

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
    final connected = await isOnline();
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
