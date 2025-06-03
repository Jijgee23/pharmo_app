import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
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

Future<String> getRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("refresh_token");
  String bearerToken = "Bearer $token";
  return bearerToken;
}

getHeader(String token) {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Pharmo-Client': '!pharmo_app?',
    'Authorization': token,
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
    print('<===${response.body}===>');
  } catch (e) {
    debugPrint('ERROR at $endPoint : $e');
  }
}

enum Api { get, post, patch, delete }

Future<http.Response?> api(
  Api method,
  String endpoint, {
  Map<String, dynamic>? body,
  Map<String, String>? header,
}) async {
  try {
    String access = await getAccessToken();
    if (access.isEmpty) {
      message('Нэвтэрнэ үү!');
      gotoRemoveUntil(const LoginPage());
      return null;
    }
    if (JwtDecoder.isExpired(access)) {
      var k = await http.post(setUrl('auth/refresh/'),
          headers: getHeader(await getRefreshToken()));
      if (k.statusCode == 200) {
        final data = convertData(k);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('access_token', data['access_token']);
        prefs.setString('refresh_token', data['refresh_token']);
      } else {
        message('Нэвтрэх эрх тань дууссан байна. Нэвтэрнэ үү!');
        gotoRemoveUntil(const LoginPage());
        return null;
      }
      message('Таны нэвтрэх эрх дууссан байна. Нэвтэрнэ үү!');
      gotoRemoveUntil(const LoginPage());
      return null;
    }
    final Uri url = setUrl(endpoint);
    Map<String, String> headers = {
      ...header ?? {},
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Pharmo-Client': '!pharmo_app?',
      'Authorization': await getAccessToken(),
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
    getApiInformation(endpoint, res);
    return res;
  } catch (e) {
    debugPrint('Error in $method request to $endpoint: $e');
    return null;
  }
}

Map<String, dynamic> buildResponse(
    int errorType, dynamic data, String? message) {
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

Future<File> compressImage(File imageFile) async {
  File? result;
  if (isImageLessThan1MB(imageFile)) {
    result = imageFile;
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
    result = compressedImage;
  }
  return result;
}

bool isImageLessThan1MB(File imageFile) {
  const int oneMBInBytes = 1 * 1024 * 1024;
  int fileSize = imageFile.lengthSync();
  return fileSize < oneMBInBytes;
}
