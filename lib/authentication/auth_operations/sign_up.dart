import 'package:pharmo_app/authentication/login/auth_text.dart';
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

  final _formKey = GlobalKey<FormState>(); // Validation хийхэд хэрэгтэй
  bool showPasss = false;
  bool otpSent = false;

  @override
  void dispose() {
    ema.dispose();
    pass.dispose();
    phone.dispose();
    passConfirm.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header хэсэг
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Image.asset('assets/picon.png', width: 100),
                  ),
                ),
                const Positioned(top: 50, left: 15, child: ChevronBack()),
              ],
            ),

            // 2. Form хэсэг
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthText('Бүртгүүлэх'),
                    const SizedBox(height: 10),
                    Text(
                      'Шинэ бүртгэл үүсгэхийн тулд мэдээллээ оруулна уу.',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 25),

                    CustomTextField(
                      controller: ema,
                      hintText: 'Имейл хаяг',
                      prefix: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 15),

                    CustomTextField(
                      controller: phone,
                      hintText: 'Утасны дугаар',
                      prefix: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 15),

                    CustomTextField(
                      controller: pass,
                      hintText: 'Нууц үг',
                      obscureText: !showPasss,
                      prefix: Icons.lock_outline,
                      suffixIcon: _viewIcon(),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 15),

                    CustomTextField(
                      controller: passConfirm,
                      hintText: 'Нууц үг давтах',
                      obscureText: !showPasss,
                      prefix: Icons.lock_reset,
                      suffixIcon: _viewIcon(),
                      validator: (v) =>
                          v != pass.text ? 'Нууц үг таарахгүй байна' : null,
                    ),

                    if (otpSent) ...[
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: otp,
                        hintText: 'Батлагаажуулах код',
                        prefix: Icons.vibration_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 30),

                    // 3. Үйлдэл хийх товч
                    otpSent
                        ? CustomButton(
                            text: 'Бүртгэл баталгаажуулах',
                            ontap: () => confirm(authController),
                          )
                        : CustomButton(
                            text: 'Батлагаажуулах код авах',
                            ontap: () => getOtp(authController),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButton _viewIcon() {
    return IconButton(
      onPressed: () => setState(() => showPasss = !showPasss),
      icon: Icon(showPasss ? Icons.visibility : Icons.visibility_off,
          color: primary.withOpacity(0.6)),
    );
  }

  // Логик хэсэгт нэмсэн засварууд
  getOtp(AuthController authController) async {
    if (_formKey.currentState!.validate()) {
      dynamic res = await authController.signUpGetOtp(ema.text, phone.text);
      if (res['errorType'] == 1) {
        setState(() => otpSent = true);
      }
      messageComplete(res['message']);
    }
  }

  confirm(AuthController authController) async {
    if (_formKey.currentState!.validate() && otp.text.isNotEmpty) {
      dynamic res = await authController.register(
        email: ema.text,
        phone: phone.text,
        otp: otp.text,
        password: pass.text,
      );
      if (res['errorType'] == 1) {
        messageComplete(res['message']);
        Navigator.pop(context);
      } else {
        messageWarning(res['message']);
      }
    } else if (otp.text.isEmpty) {
      messageWarning('Баталгаажуулах код оруулна уу!');
    }
  }
}
