import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/login_page.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final emailController = TextEditingController();
final phoneController = TextEditingController();
final passwordController = TextEditingController();
final passwordConfirmController = TextEditingController();

class _SignUpPageState extends State<SignUpPage> {
  bool showPasss = false;
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Center(
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/1024.png',
                      height: 75,
                    ),
                    const SizedBox(height: 15),
                    const Text('Бүртгүүлэх'),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Имейл',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Утасны дугаар',
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Нууц үг',
                      obscureText: !showPasss,
                      keyboardType: TextInputType.visiblePassword,
                      validator: validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPasss = !showPasss;
                          });
                        },
                        icon: Icon(showPasss
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: passwordConfirmController,
                      hintText: 'Нууц үг давтах',
                      obscureText: !showPasss,
                      keyboardType: TextInputType.visiblePassword,
                      validator: validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPasss = !showPasss;
                          });
                        },
                        icon: Icon(showPasss
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                        text: 'Батлагаажуулах код авах',
                        ontap: () {
                          if (emailController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Имэйл хаягаа оруулна уу!',
                                context: context);
                            return;
                          }
                          if (phoneController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Утасны дугаараа оруулна уу!',
                                context: context);
                            return;
                          }
                          if (passwordController.text.isEmpty ||
                              passwordConfirmController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Нууц үгээ оруулна уу!',
                                context: context);
                            return;
                          }
                          if (passwordController.text ==
                                  passwordConfirmController.text &&
                              passwordController.text.isNotEmpty) {
                            authController
                                .signUpGetOtp(
                                    emailController.text,
                                    phoneController.text,
                                    passwordConfirmController.text,
                                    context)
                                .whenComplete(
                              () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return OtpDialog(
                                        email: emailController.text,
                                        otp: otpController.text,
                                      );
                                    });
                              },
                            );
                          } else {
                            showFailedMessage(
                                message: 'Нууц үг таарахгүй байна!',
                                context: context);
                          }
                        }),
                    Row(
                      children: [
                        CustomTextButton(
                            text: 'Нэвтрэх',
                            onTap: () {
                              Navigator.pop(context);
                            })
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
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  final _formKey = GlobalKey<FormState>();
  Widget contentBox(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text(
                'Нууц үг үүсгэх',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              CustomButton(
                  text: 'Батлагаажуулах',
                  ontap: () {
                    authController
                        .register(
                            emailController.text,
                            phoneController.text,
                            passwordController.text,
                            otpController.text,
                            context)
                        .whenComplete(() {
                      passwordConfirmController.clear();
                      passwordController.clear();
                      phoneController.clear();
                      otpController.clear();
                    });
                    goto(const LoginPage(), context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
