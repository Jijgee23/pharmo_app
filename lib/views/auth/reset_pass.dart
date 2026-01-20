
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/application/application.dart';

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CustomTextField(
                  controller: email,
                  validator: (p0) => validateEmail(p0),
                  hintText: 'И-мейл',
                ),
                (!boolean)
                    ? CustomButton(
                        text: 'Баталгаажуулах код авах',
                        ontap: () async {
                          final sent = await auth.resetPassOtp(email.text);
                          if (!sent) return;
                          boolean = true;
                          setState(() {});
                        },
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          const Text('Баталгаажуулах нууц үгээ оруулна уу!'),
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
                          const Text('Шинэ нууц үгээ оруулна уу!'),
                          CustomTextField(
                            controller: password,
                            hintText: 'Нууц үг',
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            validator: validatePassword,
                          ),
                          CustomTextField(
                            controller: confirmPassword,
                            hintText: 'Нууц үг давтах',
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            validator: validatePassword,
                          ),
                          CustomButton(
                            text: 'Хадгалах',
                            ontap: () {
                              if (password.text == confirmPassword.text) {
                                auth.createPassword(
                                    email.text, opt, password.text, context);
                              } else {
                                messageWarning('Нууц үг таарахгүй байна');
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
