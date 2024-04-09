import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/screens/home_page/home_page.dart';
import 'package:pharmo_app/screens/login_page.dart';
import 'package:pharmo_app/widgets/create_pass.dart';
import 'package:pharmo_app/widgets/snack_message.dart';

class AuthController extends ChangeNotifier {
  bool invisible = true;
  Future<void> logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.88.39:8000/api/v1/auth/logout/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    notifyListeners();
    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => true);
    }
    notifyListeners();
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    var responseLogin = await http.post(
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
      notifyListeners();
    } else {
      showFailedMessage(message: 'Нууц үг буруу байна!', context: context);
    }
    notifyListeners();
  }

  void toggleVisibile() {
    invisible = !invisible;
    notifyListeners();
  }

  Future<bool> checkEmail(String email, BuildContext context) async {
    try {
      var response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/reged/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {'email': email, 'pwd': false},
        ),
      );

      print('email checked');
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final isPasswordCreated = responseData['pwd'];
        if (!isPasswordCreated) {
          String password = await showDialog(
            context: context,
            builder: (context) {
              return CreatePassDialog(
                email: email,
              );
            },
          );
        }
        if (responseData['ema'] == email && isPasswordCreated) {
          print(responseData);
          notifyListeners();
          return Future.value(true);
        }
        return false;
      } else {
        // Handle non-200 response
        showFailedMessage(
          message: 'И-мейл хаяг бүртгэлгүй байна!',
          context: context,
        );
        return Future.value(false);
      }
    } catch (e) {
      showFailedMessage(
        message: 'Хүсэлт амжилтгүй боллоо!',
        context: context,
      );
      return Future.value(false);
    }
  }

  Future<void> signUpGetOtp(
      String email, String phone, BuildContext context) async {
    try {
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/auth/reg_otp/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'phone': phone,
          }));
      notifyListeners();
      if (response.statusCode == 200) {
        showSuccessMessage(
            message: 'Батлагаажуулах код илгээлээ!',
            // ignore: use_build_context_synchronously
            context: context);
        // ignore: use_build_context_synchronously
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
      notifyListeners();
    }
  }

  Future<void> register(String email, String phone, String password, String otp,
      BuildContext context) async {
    try {
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/auth/register/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'phone': phone,
            'password': password,
            'otp': otp
          }));
      notifyListeners();
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false);
        showSuccessMessage(
            // ignore: use_build_context_synchronously
            message: 'Бүртгэл амжилттай үүслээ',
            // ignore: use_build_context_synchronously
            context: context);
        notifyListeners();
      }
      if (response.statusCode == 500) {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!',
            // ignore: use_build_context_synchronously
            context: context);
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
    }
    notifyListeners();
  }

  Future<void> getResetOtp(String email, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.88.39:8000/api/v1/auth/get_otp/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    notifyListeners();
    if (response.statusCode == 200) {
      showSuccessMessage(
          // ignore: use_build_context_synchronously
          context: context,
          message: 'Батлагаажуулах код илгээлээ');
    } else {
      showFailedMessage(
          // ignore: use_build_context_synchronously
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> createPassword(String email, String otp, String newPassword,
      BuildContext context) async {
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
    if (response.statusCode == 200) {
      showSuccessMessage(
          // ignore: use_build_context_synchronously
          message: 'Нууц үг амжилттай үүслээ',
          context: context);
    }
    if (response.statusCode == 400) {
      showFailedMessage(
          // ignore: use_build_context_synchronously
          message: 'Батлагаажуулах код буруу байна!',
          context: context);
    }
    notifyListeners();
  }
}
