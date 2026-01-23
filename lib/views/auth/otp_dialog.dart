import 'package:pharmo_app/application/function/validator/varlidator.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
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
                'Баталгаажуулах',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: _formKey,
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Баталгаажуулах код',
                    border: OutlineInputBorder()),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: false,
                validator: validateOtp,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Баталгаажуулах',
                ontap: () {
                  authController
                      .register(
                          email: emailController.text,
                          phone: phoneController.text,
                          otp: otpController.text,
                          password: passwordController.text)
                      .whenComplete(() {
                    passwordConfirmController.clear();
                    passwordController.clear();
                    phoneController.clear();
                    otpController.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
