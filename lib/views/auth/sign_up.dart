import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController ema = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController passConfirm = TextEditingController();
  final TextEditingController otp = TextEditingController();
  bool showPasss = false;
  bool otpSent = false;
  setOtpSent(bool n) {
    setState(() {
      otpSent = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        'assets/picon.png',
                      ),
                    ),
                  ),
                ),
               const ChevronBack()
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: topBorderRadius(),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    authText('Бүртгүүлэх'),
                    CustomTextField(
                      controller: ema,
                      hintText: 'Имейл',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    CustomTextField(
                      controller: phone,
                      hintText: 'Утасны дугаар',
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    CustomTextField(
                      controller: pass,
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
                        icon: Icon(
                            showPasss ? Icons.visibility : Icons.visibility_off,
                            color: theme.primaryColor),
                      ),
                    ),
                    CustomTextField(
                      controller: passConfirm,
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
                        icon: Icon(
                            showPasss ? Icons.visibility : Icons.visibility_off,
                            color: theme.primaryColor),
                      ),
                    ),
                    (otpSent)
                        ? CustomTextField(
                            controller: otp,
                            hintText: 'Батлагаажуулах код',
                            keyboardType: TextInputType.number,
                          )
                        : const SizedBox(),
                    (!otpSent)
                        ? CustomButton(
                            text: 'Батлагаажуулах код авах',
                            ontap: () => getOtp(authController),
                          )
                        : CustomButton(
                            text: 'Батлагаажуулах',
                            ontap: () => confirm(authController),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getOtp(AuthController authController) async {
    if (ema.text.isNotEmpty && phone.text.isNotEmpty) {
      dynamic res = await authController.signUpGetOtp(ema.text, phone.text);
      final keyK = res['errorType'];
      if (keyK == 1) {
        setOtpSent(true);
      }
      message(res['message']);
    } else {
      message('Бүртгэлийг талбарууд гүйцээнэ үү!');
    }
  }

  confirm(AuthController authController) async {
    if (pass.text == passConfirm.text && pass.text.isNotEmpty) {
      dynamic res = await authController.register(
        email: ema.text,
        phone: phone.text,
        otp: otp.text,
        password: pass.text,
      );
      message(res['message']);
      print(res['errorType']);
      if (res['errorType'] == 1) {
       Navigator.pop(context);
      }
    } else {
      message('Нууц үг таарахгүй байна!');
    }
  }
}
