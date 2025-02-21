import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

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
  final d = jsonDecode(utf8.decode(body.bodyBytes));
  return d;
}

getApiInformation(String endPoint, http.Response response) {
  try {
    print('<===$endPoint===>');
    print('<===${response.statusCode}===>');
    // print('<===${response.body}===>');
  } catch (e) {
    debugPrint('ERROR at $endPoint : $e');
  }
}

apiGet(String endPoint) async {
  try {
    http.Response response = await http.get(
      setUrl(endPoint),
      headers: getHeader(await getAccessToken()),
    );
    getApiInformation(endPoint, response);
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
}

apiPost(String endPoint, Object? body) async {
  try {
    http.Response response = await http.post(setUrl(endPoint),
        headers: getHeader(await getAccessToken()), body: jsonEncode(body));
    getApiInformation(endPoint, response);
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
}

apiPatch(String endPoint, Object? body) async {
  try {
    http.Response response = await http.patch(
      setUrl(endPoint),
      headers: getHeader(await getAccessToken()),
      body: body,
    );
    getApiInformation(endPoint, response);
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
}

apiDelete(String endPoint) async {
  try {
    http.Response response = await http.delete(
      setUrl(endPoint),
      headers: getHeader(await getAccessToken()),
    );
    getApiInformation(endPoint, response);
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<http.Response?> apiRequest({
  required String method,
  required String endPoint,
  Map<String, dynamic>? body,
}) async {
  try {
    final Uri url = setUrl(endPoint);
    final Map<String, String> headers = await getHeader(await getAccessToken());
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(url, headers: headers, body: jsonEncode(body));
        break;
      case 'PATCH':
        response = await http.patch(url, headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw UnsupportedError('HTTP method $method is not supported.');
    }

    getApiInformation(endPoint, response);
    return response;
  } catch (e) {
    debugPrint('Error in $method request to $endPoint: $e');
    return null;
  }
}

Map<String, dynamic> buildResponse(int errorType, dynamic data, String? message) {
  return {'errorType': errorType, 'data': data, 'message': message};
}

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
    String formattedNumber = intl.NumberFormat('#,##0.##').format(numberValue);
    return '$formattedNumber₮';
  } catch (e) {
    return '0₮';
  }
}

status(String status) {
  switch (status) {
    case "W":
      return 'Төлбөр хүлээгдэж буй';
    case "P":
      return 'Төлбөр төлөгдсөн';
    case "S":
      return 'Цуцлагдсан';
    case "C":
      return 'Биелсэн';
    default:
      return 'Тодорхойгүй';
  }
}

process(String status) {
  switch (status) {
    case "D":
      return 'Хүргэгдсэн';
    case "C":
      return 'Хаалттай';
    case "R":
      return 'Буцаагдсан';
    case "O":
      return 'Түгээлтэнд гарсан';
    case "N":
      return 'Шинэ';
    case "P":
      return 'Бэлэн болсон';
    case "Т":
      return 'Бэлтгэж эхлэсэн';
    case "A":
      return 'Хүлээн авсан';
    default:
      return 'Тодорхойгүй';
  }
}

getProcessGif(String process) {
  if (process == 'Шинэ') {
    return 'assets/stickers/hourglass.gif';
  } else if (process == 'Бэлтгэж эхэлсэн') {
    return 'assets/stickers/box.gif';
  } else if (process == 'Бэлэн болсон') {
    return 'assets/stickers/delivery-service.gif';
  } else if (process == 'Түгээлтэнд гарсан') {
    return 'assets/stickers/truck_animation.gif';
  } else if (process == 'Хүлээн авсан') {
    return 'assets/stickers/delivery-completed.gif';
  } else {
    return 'assets/stickers/hourglass.gif';
  }
}

getStatusGif(String status) {
  if (status == 'Төлбөр хүлээгдэж буй') {
    return 'assets/stickers/payment-time.gif';
  } else if (status == 'Төлбөр төлөгдсөн') {
    return 'assets/stickers/credit-card.gif';
  } else if (status == 'Цуцлагдсан') {
    return 'assets/stickers/delivery-service.gif';
  } else if (status == 'Биелсэн') {
    return 'assets/stickers/verified.gif';
  } else {
    return 'assets/stickers/hourglass.gif';
  }
}

getPayType(String status) {
  if (status == 'L') {
    return 'Зээлээр';
  } else if (status == 'C') {
    return 'Бэлнээр';
  } else if (status == 'T') {
    return 'Дансаар';
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

String maybeNull(String? text) {
  if (text == null || text.isEmpty || text == 'null') {
    return '';
  } else {
    return text;
  }
}

String maybeNullToJson(String? text) {
  if (text == null || text.isEmpty || text == 'null') {
    return '';
  } else {
    return text;
  }
}

String getDate(DateTime date) {
  return date.toString().substring(0, 10);
}

Future compressImage(File imageFile) async {
  try {
    if (isImageLessThan1MB(imageFile)) {
      return imageFile;
    } else {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
      image = img.copyResize(image!, width: 800);
      int quality = 80;
      List<int> compressedBytes = img.encodeJpg(image, quality: quality);
      File compressedImage = File('${imageFile.parent.path}/compressed_image.jpg')
        ..writeAsBytesSync(compressedBytes);
      print('Original size: ${imageFile.lengthSync()} bytes');
      print('Compressed size: ${compressedImage.lengthSync()} bytes');
      return compressedImage;
    }
  } catch (e) {
    print(e.toString());
  }
}

bool isImageLessThan1MB(File imageFile) {
  const int oneMBInBytes = 1 * 1024 * 1024;
  int fileSize = imageFile.lengthSync();
  return fileSize < oneMBInBytes;
}
