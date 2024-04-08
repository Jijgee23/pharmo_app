import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/login_page.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final emailController = TextEditingController();
final phoneController = TextEditingController();
final passwordController = TextEditingController();
final passwordConfirmController = TextEditingController();
final optController = TextEditingController();

class _SignUpPageState extends State<SignUpPage> {
  Future<void> getOtp() async {
    final String email = emailController.text;
    final String phone = phoneController.text;
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
      if (response.statusCode == 200) {
        showSuccessMessage(
            message: 'Батлагаажуулах код илгээлээ!',
            // ignore: use_build_context_synchronously
            context: context);
        // ignore: use_build_context_synchronously
      }
    } catch (e) {
      showFailedMessage(
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.1, horizontal: size.width * 0.1),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF843333),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  const Text('Бүртгүүлэх'),
                  SizedBox(height: size.height * 0.04),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Имейл',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomTextField(
                    controller: phoneController,
                    hintText: 'Утасны дугаар',
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    validator: validatePhone,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Нууц үг',
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: validatePassword,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomTextField(
                    controller: passwordConfirmController,
                    hintText: 'Нууц үг давтах',
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: validatePassword,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomButton(
                      text: 'Батлагаажуулах код авах',
                      ontap: () {
                        if (passwordController.text ==
                            passwordConfirmController.text) {
                          getOtp();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return OtpDialog(
                                  email: emailController.text,
                                  otp: otpController.text,
                                );
                              });
                        } else {
                          showFailedMessage(
                              message: 'Нууц үг таарахгүй байна!',
                              // ignore: use_build_context_synchronously
                              context: context);
                        }
                      }),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Row(
                    children: [
                      CustomTextButton(
                          text: 'Нэвтрэх',
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ],
                  ),
                  CustomTextButton(
                      text: 'Бүртгүүлэх заавар үзэх', onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpDialog extends StatefulWidget {
  final String email;
  final String otp;
  const OtpDialog({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

final TextEditingController otpController = TextEditingController();

class _OtpDialogState extends State<OtpDialog> {
  Future<void> register() async {
    final String email = emailController.text;
    final String phone = phoneController.text;
    final String password = passwordController.text;
    final String otp = otpController.text;
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
      }
      if (response.statusCode == 500) {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!',
            // ignore: use_build_context_synchronously
            context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  final _formKey = GlobalKey<FormState>();
  Widget contentBox(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.35,
      width: size.width * 0.75,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Нууц үг үүсгэх',
            style: TextStyle(fontSize: size.height * 0.02),
          ),
          SizedBox(
            height: size.height * 0.08,
            child: TextFormField(
              key: _formKey,
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Батлагаажуулах код',
                  border: OutlineInputBorder()),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              validator: validateOtp,
            ),
          ),
          CustomButton(
              text: 'Батлагаажуулах',
              ontap: () {
                register();
              }),
        ],
      ),
    );
  }
}
