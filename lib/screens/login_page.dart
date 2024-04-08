import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/home_page.dart';
import 'package:pharmo_app/screens/signup_page.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/create_pass.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://192.168.88.39:8000/api/v1/auth/reged/';
  final String loginUrl = 'http://192.168.88.39:8000/api/v1/auth/login/';
  bool _invisible = true;

  Future<void> login(String email, String password) async {
    try {
      final responseLogin = await http.post(
        Uri.parse(loginUrl),
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
      if (responseLogin.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        showFailedMessage(message: 'Нууц үг буруу байна!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Интернет холболтоо шалгана уу!', context: context);
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
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
      if (isPasswordCreated == false) {
        String password = await showDialog(
          // ignore:
          context: context,
          builder: (context) => CreatePassDialog(
            email: emailController.text,
          ),
        );
        if (password == passwordController.text) {}
      }
      if (response.statusCode == 200 &&
          responseData['ema'] == emailController.text &&
          isPasswordCreated) {
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
      showFailedMessage(
          message: 'И-мэйл хаяг бүртгэлгүй байна!', context: context);
      return false;
    }
  }

  Future<void> createPassword(
      String email, String otp, String newPassword) async {
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
        showFailedMessage(
            message: 'Батлагаажуулах код буруу байна!', context: context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(
          message: 'Амжилтгүй, дахин оролдоно уу!', context: context);
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
        createPassword(emailController.text, otpController.text,
            newPasswordController.text);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
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
                    style: TextStyle(
                        fontSize: size.height * 0.04,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                  ),
                  Text(
                    'Эмийн бөөний худалдаа,\n захиалгын систем',
                    style: TextStyle(
                        fontSize: size.height * 0.02,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                  ),
                ],
              )),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.1, horizontal: size.width * 0.1),
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    const Text('Нэвтрэх'),
                    SizedBox(height: size.height * 0.03),
                    CustomTextField(
                        controller: emailController,
                        hintText: 'Имейл хаяг',
                        obscureText: false,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress),
                    SizedBox(height: size.height * 0.03),
                    Visibility(
                        visible: !_invisible,
                        child: CustomTextField(
                            controller: passwordController,
                            hintText: 'Нууц үг',
                            obscureText: true,
                            validator: validatePassword,
                            keyboardType: TextInputType.name)),
                    SizedBox(height: size.height * 0.03),
                    CustomButton(
                        text: _invisible ? 'Үргэлжлүүлэх' : 'Нэвтрэх',
                        ontap: () async {
                          if (_invisible) {
                            await authController.checkEmail(
                                emailController.text, context);
                            setState(() {
                              _invisible = !_invisible;
                            });
                          } else {
                            authController.login(emailController.text,
                                passwordController.text, context);
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SignUpPage()));
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
}
