import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/home_page/home_page.dart';
import 'package:pharmo_app/screens/signup_page.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/create_pass.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  bool _invisible = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: size.height * 0.13,
          centerTitle: true,
          backgroundColor: const Color(0xFF1B2E3C),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                Text(
                  'Pharmo',
                  style: TextStyle(fontSize: size.height * 0.04, fontStyle: FontStyle.italic, color: Colors.white),
                ),
                Text(
                  'Эмийн бөөний худалдаа,\n захиалгын систем',
                  style: TextStyle(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.1, horizontal: size.width * 0.1),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFA32711),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    const Text('Нэвтрэх'),
                    SizedBox(height: size.height * 0.03),
                    CustomTextField(controller: emailController, hintText: 'Имейл хаяг', obscureText: false, validator: validateEmail, keyboardType: TextInputType.emailAddress),
                    SizedBox(height: size.height * 0.03),
                    Visibility(
                        visible: !_invisible,
                        child:
                            CustomTextField(controller: passwordController, hintText: 'Нууц үг', obscureText: true, validator: validatePassword, keyboardType: TextInputType.name)),
                    SizedBox(height: size.height * 0.03),
                    CustomButton(
                        text: !_invisible ? 'Үргэлжлүүлэх' : 'Нэвтрэх',
                        ontap: () async {
                          if (_invisible) {
                            await checkEmail(emailController.text);
                          } else {
                            login(emailController.text, passwordController.text);
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _invisible
                            ? const Text('')
                            : CustomTextButton(
                                text: 'Буцах',
                                onTap: () {
                                  setState(() {
                                    _invisible = !_invisible;
                                  });
                                }),
                        _invisible
                            ? CustomTextButton(
                                text: 'Бүртгүүлэх',
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                                })
                            : CustomTextButton(
                                text: 'Нууц үг сэргээх',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CreatePassDialog(
                                        email: emailController.text,
                                      );
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final responseLogin = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzEyMTM4MDk3LCJpYXQiOjE3MTIwNTE2OTcsImp0aSI6IjM3NzE2NzEwN2VhZDRkYTRhNDA5ZTE4M2YzMmFlNDhjIiwidXNlcl9pZCI6NDUwLCJlbWFpbCI6ImppamdlZTY0N0BnbWFpbC5jb20iLCJyb2xlIjoiUEEiLCJpc19zdGFmZiI6ZmFsc2UsImlzX3ZlcmlmaWVkIjp0cnVlLCJzdXBwbGllciI6bnVsbCwicGMiOmZhbHNlLCJpc1Jldmlld2VkIjpudWxsfQ.SmniAagJJnLl8NmvzLTB1CgCcXDlVP865HlneMp9suE',
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );
      final responseData = jsonDecode(responseLogin.body);
      if (responseLogin.statusCode == 200) {
        String accessToken = responseData['access_token'];
        String refreshToken = responseData['refresh_token'];
        await TokenManager.saveToken(accessToken);
        await TokenManager.saveToken(refreshToken);
        String? savedAccessToken = await TokenManager.getToken();
        String? savedRefreshToken = await TokenManager.getToken();
        print('access token: $savedAccessToken');
        print('refresh token: $savedRefreshToken');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        showFailedMessage(message: 'Нууц үг буруу байна!', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Интернет холболтоо шалгана уу!', context: context);
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/reged/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      print('check email: ${response.statusCode}');
      final responseData = jsonDecode(response.body);
      final bool isPasswordCreated = responseData['pwd'];
      print(responseData);
      if (isPasswordCreated == false) {
        await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => CreatePassDialog(
            email: emailController.text,
          ),
        );
      }
      if (response.statusCode == 200 && responseData['ema'] == emailController.text && isPasswordCreated) {
        setState(() {
          _invisible = !_invisible;
        });
        if (_invisible) {
          login(emailController.text, passwordController.text);
        }
        return true;
      }
      return false;
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(message: 'И-мэйл хаяг бүртгэлгүй байна!', context: context);
      return false;
    }
  }

  Future<void> createPassword(String email, String otp, String newPassword) async {
    final email = emailController.text;
    final otp = otpController.text;
    final newPassword = newPasswordController.text;
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
        showFailedMessage(message: 'Батлагаажуулах код буруу байна!', context: context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(message: 'Амжилтгүй, дахин оролдоно уу!', context: context);
    }
  }

  Future<void> getOtp(String email) async {
    final email = emailController.text;
    try {
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/auth/get_otp/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        createPassword(emailController.text, otpController.text, newPasswordController.text);
      } else {
        showFailedMessage(
            // ignore: use_build_context_synchronously
            message: 'Амжилтгүй!',
            context: context);
        throw Exception('Амжилтгүй: ${response.statusCode}');
      }
    } catch (e) {
      print('Алдаа: $e');
    }
  }
}

class TokenManager {
  static const String _tokenKey = 'token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
