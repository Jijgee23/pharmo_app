import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/login_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class CreatePassDialog extends StatefulWidget {
  final String email;
  const CreatePassDialog({
    super.key,
    required this.email,
  });

  @override
  State<CreatePassDialog> createState() => _CreatePassDialogState();
}

final TextEditingController otpController = TextEditingController();
final TextEditingController newPasswordController = TextEditingController();
final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class _CreatePassDialogState extends State<CreatePassDialog> {
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
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Нууц үг үүсгэх',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: emailController,
                obscureText: false,
                hintText: 'Имейл хаяг',
                validator: validateEmail,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: passwordController,
                hintText: 'Нууц үг',
                obscureText: true,
                validator: validatePassword,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: newPasswordController,
                hintText: 'Нууц үг давтах',
                obscureText: true,
                validator: validatePassword,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: authController.invisible2,
                child: CustomTextField(
                    controller: otpController,
                    hintText: 'Батлагаажуулах код',
                    obscureText: false,
                    validator: validateOtp,
                    keyboardType: TextInputType.number),
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: !authController.invisible2
                    ? 'Батлагаажуулах код авах'
                    : 'Батлагаажуулах',
                ontap: () {
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Нууц үгээ оруулна уу';
                    }
                  };
                  String email = emailController.text;
                  String password = passwordController.text;
                  String password2 = newPasswordController.text;
                  String otp = otpController.text;
                  if (password.isEmpty) {
                    showFailedMessage(
                        context: context, message: 'Нууц үг оруулна уу');
                  }
                  if (password == password2 && password2.isNotEmpty && password.isNotEmpty) {
                    if (!authController.invisible2) {
                      authController.resetPassOtp(email, context);
                      setState(() {
                        authController.toggleVisibile2();
                      });
                    } else {
                      if (otpController.text.isEmpty) {
                        showFailedMessage(
                            context: context,
                            message: 'Батлагаажуулах код орууна уу');
                      }
                      authController.createPassword(
                          email, otp, password, context);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false);
                      showSuccessMessage(
                          message: 'Нууц үг амжилттай үүслээ',
                          context: context);
                      setState(() {
                        authController.toggleVisibile2();
                      });
                    }
                  } else {
                    showFailedMessage(
                        message: 'Нууц үг таарахгүй байна!', context: context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
