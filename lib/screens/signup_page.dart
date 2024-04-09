import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
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
final optController = TextEditingController();

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
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
                    SizedBox(height: size.height * 0.02),
                    const Text('Бүртгүүлэх'),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Имейл',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Утасны дугаар',
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Нууц үг',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: validatePassword,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomTextField(
                      controller: passwordConfirmController,
                      hintText: 'Нууц үг давтах',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: validatePassword,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomButton(
                        text: 'Батлагаажуулах код авах',
                        ontap: () {

                          if (emailController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Имэйл хаягаа оруулна уу!',
                                // ignore: use_build_context_synchronously
                                context: context);
                            return;
                          }
                          if (phoneController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Утасны дугаараа оруулна уу!',
                                // ignore: use_build_context_synchronously
                                context: context);
                            return;
                          }
                          if (passwordController.text.isEmpty ||
                              passwordConfirmController.text.isEmpty) {
                            showFailedMessage(
                                message: 'Нууц үгээ оруулна уу!',
                                // ignore: use_build_context_synchronously
                                context: context);
                            return;
                          }
                          if (passwordController.text ==
                                  passwordConfirmController.text &&
                              passwordController.text.isNotEmpty) {
                            authController.signUpGetOtp(emailController.text,
                                phoneController.text, context);
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
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Container(
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
                  authController.register(
                      emailController.text,
                      phoneController.text,
                      passwordController.text,
                      otpController.text,
                      context);
                }),
          ],
        ),
      ),
    );
  }
}
