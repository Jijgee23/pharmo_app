// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/resetPass.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController passwordConfirmController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  bool hover = false;
  bool rememberMe = false;
  bool isLoading = false;
  bool showPasss = false;
  String selectedMenu = 'Нэвтрэх';
  bool isLogin = true;
  late Box box1;
  late AuthController authController;
  @override
  void initState() {
    super.initState();
    _openBox();
    authController = Provider.of<AuthController>(context, listen: false);
  }

  Future<void> _openBox() async {
    try {
      box1 = await Hive.openBox('auth');
      getLocalData();
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
    }
  }

  void getLocalData() {
    if (box1.get('email') != null) {
      emailController.text = box1.get('email');
    }
    if (box1.get('password') != null) {
      passwordController.text = box1.get('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset('assets/1024.png', height: 40),
                          ),
                          const SizedBox(width: 10),
                          const Text('Pharmo',
                              style: TextStyle(
                                  fontSize: 40,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white)),
                        ],
                      ),
                      const Text('Эмийн бөөний худалдаа,\n захиалгын систем',
                          style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/picon.png'))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tapItem('Нэвтрэх'),
                    const SizedBox(width: 20),
                    tapItem('Бүртгүүлэх'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      (selectedMenu == 'Нэвтрэх') ? loginForm() : signUpForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  tapItem(String txt) {
    return Expanded(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () => setState(() {
          selectedMenu = txt;
        }),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Center(
                child: Text(
                  txt,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: (selectedMenu == txt)
                    ? const Border(
                        bottom:
                            BorderSide(color: AppColors.primary, width: 1.5))
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  loginForm() {
    final authController = Provider.of<AuthController>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        CustomTextField(
          controller: emailController,
          autofillHints: const [AutofillHints.email],
          hintText: 'Имейл хаяг',
          validator: (v) {
            if (v!.isNotEmpty) {
              return validateEmail(v);
            } else {
              return null;
            }
          },
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          autofillHints: const [AutofillHints.password],
          controller: passwordController,
          hintText: 'Нууц үг',
          obscureText: !hover,
          validator: (v) {
            if (v!.isNotEmpty) {
              return validatePassword(v);
            } else {
              return null;
            }
          },
          keyboardType: TextInputType.visiblePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                hover = !hover;
              });
            },
            icon: Icon(hover ? Icons.visibility_off : Icons.visibility,
                color: AppColors.primary),
          ),
        ),
        Row(
          children: [
            const Text(
              'Намайг сана',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary),
            ),
            Checkbox(
                value: rememberMe,
                onChanged: (val) {
                  setState(() {
                    rememberMe = !rememberMe;
                  });
                }),
          ],
        ),
        CustomButton(
            text: 'Нэвтрэх',
            ontap: () async {
              setState(() {
                isLoading = true;
              });
              await Future.delayed(const Duration(milliseconds: 500));
              if (passwordController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                await authController
                    .login(
                        emailController.text, passwordController.text, context)
                    .whenComplete(() async {
                  if (rememberMe) {
                    await box1.put('email', emailController.text);
                    await box1.put('password', passwordController.text);
                  }
                });
              } else {
                message(
                    context: context,
                    message: 'Нэврэх нэр, нууц үг оруулна уу');
              }
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextButton(
              text: 'Нууц үг сэргээх',
              onTap: () {
                goto(const ResetPassword(), context);
                // setState(() {
                //   authController.invisible2 = false;
                // });
                // passwordController.clear();
                // passwordConfirmController.clear();
                // newPasswordController.clear();
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return CreatePassDialog(
                //       email: emailController.text,
                //     );
                //   },
                // );
              },
            ),
          ],
        )
      ],
    );
  }

  signUpForm() {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 15),
          CustomTextField(
            controller: emailController,
            hintText: 'Имейл',
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: phoneController,
            hintText: 'Утасны дугаар',
            obscureText: false,
            keyboardType: TextInputType.phone,
            validator: validatePhone,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: passwordController,
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
              icon: Icon(showPasss ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: passwordConfirmController,
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
              icon: Icon(showPasss ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 15),
          CustomButton(
              text: 'Батлагаажуулах код авах',
              ontap: () {
                if (passwordController.text == passwordConfirmController.text &&
                    passwordController.text.isNotEmpty) {
                  authController
                      .signUpGetOtp(emailController.text, phoneController.text,
                          passwordConfirmController.text, context)
                      .whenComplete(
                    () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return OtpDialog(
                              email: emailController.text,
                              otp: otpController.text,
                            );
                          });
                    },
                  );
                } else {
                  message(
                      message: 'Нууц үг таарахгүй байна!', context: context);
                }
              }),
        ],
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
                'Нууц үг үүсгэх',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              CustomButton(
                  text: 'Батлагаажуулах',
                  ontap: () {
                    authController
                        .register(
                            emailController.text,
                            phoneController.text,
                            passwordController.text,
                            otpController.text,
                            context)
                        .whenComplete(() {
                      passwordConfirmController.clear();
                      passwordController.clear();
                      phoneController.clear();
                      otpController.clear();
                    });
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
