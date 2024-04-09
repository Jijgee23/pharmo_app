import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/signup_page.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
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
final TextEditingController passwordController = TextEditingController();
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
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Container(
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
                visible: !authController.invisible,
                child: CustomTextField(
                    controller: otpController,
                    hintText: 'Батлагаажуулах код',
                    obscureText: false,
                    validator: validateOtp,
                    keyboardType: TextInputType.number),
              ),
              SizedBox(height: size.height * 0.04),
              CustomButton(
                text: !authController.invisible
                    ? 'Батлагаажуулах код авах'
                    : 'Батлагаажуулах',
                ontap: () {
                  String password = passwordController.text;
                  String password2 = newPasswordController.text;
                  if (authController.invisible) {
                    authController.getResetOtp(emailController.text, context);
                    setState(() {
                      authController.toggleVisibile();
                    });
                  } else {
                    if (password == password2) {
                      authController.createPassword(
                          emailController.text,
                          otpController.text,
                          newPasswordController.text,
                          context);
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
      ),
    );
  }
}
