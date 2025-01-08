import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/utilities/sizes.dart';
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

void gotoRemoveUntil(Widget widget) {
  Get.offAll(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );
}

back({Color? color}) {
  return Container(
    margin: EdgeInsets.all(Sizes.width * 0.02),
    padding: EdgeInsets.all(Sizes.width * 0.01),
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        // BoxShadow(blurRadius: 7, color: Colors.grey.shade300),
      ],
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(100),
      splashColor: Colors.black.withOpacity(0.3),
      onTap: () => Get.back(),
      child: const Icon(
        Icons.chevron_left,
        color: Colors.black,
      ),
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

convertData(http.Response body) {
  var d = jsonDecode(utf8.decode(body.bodyBytes));
  return d;
}

getApiInformation(String endPoint, http.Response response) {
  try {
    debugPrint(
        '$endPoint, status: ${response.statusCode},\n body; ${convertData(response)}');
  } catch (e) {
    debugPrint('ERROR at $endPoint : $e');
  }
}

apiGet(String endPoint) async {
  http.Response response = await http.get(
    setUrl(endPoint),
    headers: getHeader(
      await getAccessToken(),
    ),
  );

  getApiInformation(endPoint, response);
  return response;
}

apiPost(String endPoint, Object? body) async {
  http.Response response = await http.post(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
    body: body,
  );
  getApiInformation(endPoint, response);
  return response;
}

apiPatch(String endPoint, Object body) async {
  http.Response response = await http.patch(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
    body: body,
  );
  getApiInformation(endPoint, response);
  return response;
}

apiDelete(String endPoint) async {
  http.Response response = await http.delete(
    setUrl(endPoint),
    headers: getHeader(await getAccessToken()),
  );
  getApiInformation(endPoint, response);
  return response;
}

Map<String, dynamic> buildResponse(
    int errorType, dynamic data, String? message) {
  return {'errorType': errorType, 'data': data, 'message': message};
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

checker(Map response, String key) {
  if (response.containsKey(key)) {
    return true;
  } else {
    return false;
  }
}

shadow() {
  return [BoxShadow(color: Colors.grey.shade400, blurRadius: 5)];
}

String maybeNull(String? text) {
  if (text == null || text.isEmpty) {
    return '-';
  } else {
    return text;
  }
}
