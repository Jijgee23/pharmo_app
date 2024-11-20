import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void goto(Widget widget) {
  Get.to(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );
}

void gotoRemoveUntil(Widget widget, BuildContext context) {
  Get.offAll(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );
}

back() {
  return InkWell(
    borderRadius: BorderRadius.circular(24),
    splashColor: Colors.black.withOpacity(0.3),
    onTap: () => Get.back(),
    child: const Icon(
      Icons.chevron_left,
      color: Colors.black,
    ),
  );
}

Future<String> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("access_token");
  String bearerToken = "Bearer $token";
  return bearerToken;
}

getHeader(String token) {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': token
  };
  return headers;
}

setUrl(String endPoint) {
  Uri url = Uri.parse('${dotenv.env['SERVER_URL']}$endPoint');
  return url;
}

apiGet(String endPoint) async {
  var response = await http.get(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
  );
  return response;
}

apiPost(String endPoint, Object? body) async {
  var response = await http.post(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
    body: body,
  );
  return response;
}

apiPatch(String endPoint, Object body) async {
  var response = await http.patch(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
    body: body,
  );
  return response;
}

apiDelete(String endPoint) async {
  var response = await http.delete(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
  );
  return response;
}

String noImage =
    'https://st4.depositphotos.com/14953852/24787/v/380/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';

double parseDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  } else if (value is int) {
    return value.toDouble();
  } else if (value is String) {
    return double.parse(value);
  }
  {
    return value;
  }
}

int parseInt(dynamic value) {
  if (value == null) {
    return 0;
  } else if (value is double) {
    return value.round();
  } else if (value is String) {
    return int.parse(value);
  }
  {
    return value;
  }
}

String toPrice(dynamic v) {
  if (v == null) {
    return '0₮';
  }
  try {
    num numberValue;
    if (v is num) {
      numberValue = v;
    } else if (v is String) {
      numberValue = num.tryParse(v) ?? 0;
    } else {
      throw Exception('Unsupported value type');
    }
    String formattedNumber = NumberFormat('#,##0.##').format(numberValue);
    return '$formattedNumber₮';
  } catch (e) {
    return '0₮';
  }
}

getProcessNumber(String process) {
  if (process == 'Шинэ') {
    return 0;
  } else if (process == 'Бэлтгэж эхэлсэн') {
    return 1;
  } else if (process == 'Бэлэн болсон') {
    return 2;
  } else if (process == 'Түгээлтэнд гарсан') {
    return 3;
  } else {
    return 4;
  }
}

getOrderProcess(String v) {
  if (v == 'O') {
    return "Хүргэлтэнд гарсан";
  } else if (v == 'N') {
    return 'Шинэ';
  } else if (v == 'M') {
    return 'Бэлтгэж эхлэсэн';
  } else if (v == 'A') {
    return 'Хүлээн авсан';
  } else if (v == 'C') {
    return 'Хаалттай';
  } else if (v == 'R') {
    return 'Буцаагдсан';
  } else if (v == 'P') {
    return 'Бэлэн болсон';
  } else {
    return '';
  }
}

getStatus(String status) {
  if (status == 'W') {
    return 'Төлбөр хүлээгдэж буй';
  } else if (status == 'P') {
    return 'Төлбөр төлөгдсөн';
  } else if (status == 'S') {
    return 'Цуцлагдсан';
  } else if (status == 'C') {
    return 'Биелсэн';
  } else {
    return 'Тодорхой биш';
  }
}

// getApiInformation(String type, http.Response res) {
//   print(' $type . STATUS: ${res.statusCode} BODY: ${jsonDecode(
//     utf8.decode(
//       res.bodyBytes,
//     ),
//   )}');
// }

checker(Map response, String key, BuildContext context) {
  if (response.containsKey(key)) {
    return true;
  } else {
    return false;
  }
}

shadow() {
  return [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)];
}
