import 'package:pharmo_app/views/auth/login/auth_text.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/application/application.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        color: theme.primaryColor.withAlpha(75),
                        image: const DecorationImage(
                            image: AssetImage('assets/picon.png')))),
                const Positioned(
                  top: 30,
                  left: 15,
                  child: ChevronBack(),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    AuthText('Бүртгүүлэх'),
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
      messageComplete(res['message']);
    } else {
      messageWarning('Бүртгэлийг талбарууд гүйцээнэ үү!');
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
      messageComplete(res['message']);
      print(res['errorType']);
      if (res['errorType'] == 1) {
        Navigator.pop(context);
      }
    } else {
      messageWarning('Нууц үг таарахгүй байна!');
    }
  }
}
