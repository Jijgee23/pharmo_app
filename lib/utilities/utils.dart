import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void goto(Widget widget, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
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
