import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';

class CreatePassDialog extends StatefulWidget {
  final String email;
  const CreatePassDialog({
    super.key,
    required this.email,
  });

  @override
  State<CreatePassDialog> createState() => _CreatePassDialogState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController otpController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController newPasswordController = TextEditingController();
final GlobalKey<FormState> formKey = GlobalKey<FormState>();

bool _invisible = true;

class _CreatePassDialogState extends State<CreatePassDialog> {
  Future<void> getOtp(String email) async {
    final email = widget.email;
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
          showSuccessMessage(
            // ignore: use_build_context_synchronously
            context: context, message: 'Батлагаажуулах код илгээлээ');
        setState(() {
          _invisible = !_invisible;
        });
      } else {
        showFailedMessage(
            // ignore: use_build_context_synchronously
            message: 'Амжилтгүй!',
            // ignore: use_build_context_synchronously
            context: context);
        throw Exception('Амжилтгүй: ${response.statusCode}');
      }
    } catch (e) {
      showFailedMessage(
          // ignore: use_build_context_synchronously
          message: 'Амжилтгүй!',
          // ignore: use_build_context_synchronously
          context: context);
    }
  }

  Future<void> createPassword(
      String email, String otp, String newPassword) async {
    final email = widget.email;
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
      if (response.statusCode == 200) {
        showSuccessMessage(
            // ignore: use_build_context_synchronously
            message: 'Нууц үг амжилттай үүслээ', context: context);
      }
      if (response.statusCode == 400) {
        showFailedMessage(
            // ignore: use_build_context_synchronously
            message: 'Батлагаажуулах код буруу байна!', context: context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(message: 'Амжилтгүй, дахин оролдоно уу!', context: context);
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

  Widget contentBox(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.6,
      width: size.width * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Нууц үг үүсгэх',
              style: TextStyle(fontSize: size.height * 0.035),
            ),
            SizedBox(height: size.height * 0.04),
            CustomTextField(
              controller: passwordController,
              hintText: 'Нууц үг',
              obscureText: true,
              validator: validatePassword,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: size.height * 0.04),
            CustomTextField(
              controller: newPasswordController,
              hintText: 'Нууц үг давтах',
              obscureText: true,
              validator: validatePassword,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: size.height * 0.04),
            Visibility(
              visible: !_invisible,
              child: CustomTextField(
                  controller: otpController,
                  hintText: 'Батлагаажуулах код',
                  obscureText: false,
                  validator: validateOtp,
                  keyboardType: TextInputType.number),
            ),
            SizedBox(height: size.height * 0.04),
            CustomButton(
              text: _invisible ? 'Батлагаажуулах код авах' : 'Батлагаажуулах',
              ontap: () {
                String password = passwordController.text;
                String password2 = newPasswordController.text;
                if (_invisible) {
                  getOtp(emailController.text);
                } else {
                  if (password == password2) {
                    createPassword(widget.email, otpController.text,
                        newPasswordController.text);
                         showSuccessMessage(
                        // ignore: use_build_context_synchronously
                        message: 'Нууц үг амжилттай үүслээ',
                        context: context);
                    
                    Navigator.of(context).pop(password);
                  }
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Нууц үгээ оруулна уу';
                    } else {}
                    return null;
                  };
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
