import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/screens/home_page/home_page.dart';
import 'package:pharmo_app/screens/login_page.dart';
import 'package:pharmo_app/widgets/snack_message.dart';

class AuthController extends ChangeNotifier {
//  bool _invisible = true;
  Future<void> logout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/logout/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false);
      } else {
        throw Exception('Амжилтгүй: ${response.statusCode}');
      }
    } catch (e) {
      print('Интернет холболтоо шалгана уу!');
    }
    notifyListeners();
  }

  Future<void> createPassword(String email, String otp, String newPassword,
      BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/reset/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_pwd': newPassword,
        }),
      );
      if (response.statusCode == 200) {}
      if (response.statusCode == 400) {
        // ignore: use_build_context_synchronously
        showFailedMessage(
            message: 'Батлагаажуулах код буруу байна!', context: context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(
          message: 'Амжилтгүй, дахин оролдоно уу!', context: context);
    }
  }

  Future<void> getOtp(String email, String otp, String newPassword,
      BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/get_otp/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_pwd': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        createPassword(email, otp, newPassword, context);
        notifyListeners();
      } else {
        showFailedMessage(
            // ignore: use_build_context_synchronously
            message: 'Амжилтгүй!',
            context: context);
        notifyListeners();
        throw Exception('Амжилтгүй: ${response.statusCode}');
      }
    } catch (e) {
      print('Алдаа: $e');
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      final responseLogin = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzEyMTM4MDk3LCJpYXQiOjE3MTIwNTE2OTcsImp0aSI6IjM3NzE2NzEwN2VhZDRkYTRhNDA5ZTE4M2YzMmFlNDhjIiwidXNlcl9pZCI6NDUwLCJlbWFpbCI6ImppamdlZTY0N0BnbWFpbC5jb20iLCJyb2xlIjoiUEEiLCJpc19zdGFmZiI6ZmFsc2UsImlzX3ZlcmlmaWVkIjp0cnVlLCJzdXBwbGllciI6bnVsbCwicGMiOmZhbHNlLCJpc1Jldmlld2VkIjpudWxsfQ.SmniAagJJnLl8NmvzLTB1CgCcXDlVP865HlneMp9suE',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (responseLogin.statusCode == 200) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        showFailedMessage(message: 'Нууц үг буруу байна!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Интернет холболтоо шалгана уу!', context: context);
    }
    notifyListeners();
  }
}
