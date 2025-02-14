import 'package:flutter/material.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool boolean = false;
  final otpController = OtpFieldControllerV2();
  String opt = '';
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) => Scaffold(
        appBar: const SideAppBar(text: 'Нууц үг сэргээх'),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text('Бүртгэлтэй и-мейл хаягаа оруулна уу?'),
                // Constants.boxV10,
                CustomTextField(
                    controller: email, validator: (p0) => validateEmail(p0), hintText: 'И-мейл'),
                Constants.boxV10,
                (!boolean)
                    ? CustomButton(
                        text: 'Батлагаажуулах код авах',
                        ontap: () async {
                          dynamic sent = await auth.resetPassOtp(email.text);
                          print(sent['errorType']);
                          if (email.text.isNotEmpty) {
                            if (sent['errorType'] == 1) {
                              setState(() {
                                boolean = true;
                              });
                            }
                            message(sent['message']);
                          } else {
                            message('Бүртгэлтэй и-мейл хаягаа оруулна уу!');
                          }
                        },
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Батлагаажуулах нууц үгээ оруулна уу!'),
                          Constants.boxV10,
                          OTPTextFieldV2(
                              controller: otpController,
                              length: 6,
                              width: MediaQuery.of(context).size.width,
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldWidth: 45,
                              fieldStyle: FieldStyle.box,
                              outlineBorderRadius: 15,
                              style: const TextStyle(fontSize: 17),
                              keyboardType: TextInputType.number,
                              onChanged: (pin) {},
                              onCompleted: (pin) {
                                setState(() {
                                  opt = pin;
                                });
                              }),
                          Constants.boxV10,
                          const Text('Шинэ нууц үгээ оруулна уу!'),
                          Constants.boxV10,
                          CustomTextField(
                            controller: password,
                            hintText: 'Нууц үг',
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            validator: validatePassword,
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: confirmPassword,
                            hintText: 'Нууц үг давтах',
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            validator: validatePassword,
                          ),
                          Constants.boxV10,
                          CustomButton(
                            text: 'Хадгалах',
                            ontap: () {
                              if (password.text == confirmPassword.text) {
                                auth.createPassword(email.text, opt, password.text, context);
                              } else {
                                message('Нууц үг таарахгүй байна');
                              }
                            },
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
