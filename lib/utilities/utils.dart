import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void goto(Widget widget) {
  Get.to(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );
}

void gotoRemoveUntil(Widget widget, BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

const ts1 = TextStyle(color: Colors.blueGrey, fontSize: 12.0);
const ts2 = TextStyle(color: Colors.blueGrey, fontSize: 16.0);
const ts3 = TextStyle(color: Colors.blueGrey, fontSize: 20.0);
getScreenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

extension AppContext on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
  Future push(Widget widget) async {
    await Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  void pop() async {
    return Navigator.pop(this);
  }
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

toPrice(String v) {
  return '$v ₮';
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

getApiInformation(String type, http.Response res) {
  debugPrint(
      ' $type . STATUS: ${res.statusCode} BODY: ${jsonDecode(utf8.decode(res.bodyBytes))}');
}
