import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/auth_provider.dart';
import 'package:pharmo_app/application/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
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

class _CreatePassDialogState extends State<CreatePassDialog> {
  bool otpSent = false;
  void setInvisible(bool n) {
    setState(() {
      otpSent = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController =
        TextEditingController(text: widget.email);
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final auth = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: SheetContainer(
        title: 'Нууц үг үүсгэх',
        children: [
          CustomTextField(
            controller: emailController,
            obscureText: false,
            hintText: 'Имейл хаяг',
            validator: validateEmail,
            keyboardType: TextInputType.visiblePassword,
          ),
          if (!otpSent)
            CustomButton(
              text: 'Батлагаажуулах код авах',
              ontap: () async {
                dynamic res = await auth.resetPassOtp(widget.email);
                setInvisible(true);
                message(res['message']);
              },
            ),
          if (otpSent)
            CustomTextField(
              controller: passwordController,
              hintText: 'Нууц үг',
              obscureText: true,
              validator: validatePassword,
              keyboardType: TextInputType.visiblePassword,
            ),
          if (otpSent)
            CustomTextField(
              controller: newPasswordController,
              hintText: 'Нууц үг давтах',
              obscureText: true,
              validator: validatePassword,
              keyboardType: TextInputType.visiblePassword,
            ),
          if (otpSent)
            CustomTextField(
                controller: otpController,
                hintText: 'Батлагаажуулах код',
                obscureText: false,
                validator: validateOtp,
                keyboardType: TextInputType.number),
          if (otpSent)
            CustomButton(
              text: 'Батлагаажуулах',
              ontap: () async {
                String email = emailController.text;
                String password = passwordController.text;
                String password2 = newPasswordController.text;
                String otp = otpController.text;
                if (password.isNotEmpty &&
                    password2.isNotEmpty &&
                    otp.isNotEmpty &&
                    password2 == password) {
                  dynamic cp =
                      await auth.createPassword(email, otp, password, context);
                  message(cp['message']);
                  if (cp['errorType'] == 1) {
                    Navigator.pop(context);
                  }
                } else if (password2 != password) {
                  message('Нууц үг таарахгүй байна!');
                } else if (otp.isEmpty ||
                    password2.isEmpty ||
                    password.isEmpty) {
                  message('Талбаруудыг бөглөнө үү!');
                }
              },
            ),
        ],
      ),
    );
  }
}
