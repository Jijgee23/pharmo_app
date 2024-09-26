// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/signup_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
//final _formKey = GlobalKey<FormState>();

class _LoginPageState extends State<LoginPage> {
  bool hover = false;
  bool rememberMe = false;
  bool isLoading = false;
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
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: isLoading
          ? const Scaffold(
              body: Center(
                child: MyIndicator(),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                toolbarHeight: size.height * 0.14,
                centerTitle: true,
                backgroundColor: AppColors.primary,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/1024.png',
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pharmo',
                            style: TextStyle(
                                fontSize: 40,
                                fontStyle: FontStyle.italic,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const Text(
                        'Эмийн бөөний худалдаа,\n захиалгын систем',
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              body: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Image.asset('assets/1024.png', height: 75),
                          const Text(
                            'Нэвтрэх',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: size.height * 0.08),
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
                              icon: Icon(hover
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                          Row(
                            children: [
                              const Text('Намайг сана'),
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
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                if (passwordController.text.isNotEmpty &&
                                    emailController.text.isNotEmpty) {
                                  await authController
                                      .login(emailController.text,
                                          passwordController.text, context)
                                      .whenComplete(() async {
                                    if (rememberMe) {
                                      await box1.put(
                                          'email', emailController.text);
                                      await box1.put(
                                          'password', passwordController.text);
                                    }
                                  });
                                } else {
                                  showFailedMessage(
                                      context: context,
                                      message:
                                          'Нэврэх нэр, нууц үг оруулна уу');
                                }
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextButton(
                                text: 'Нууц үг сэргээх',
                                onTap: () {
                                  setState(() {
                                    authController.invisible2 = false;
                                  });
                                  passwordController.clear();
                                  passwordConfirmController.clear();
                                  newPasswordController.clear();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CreatePassDialog(
                                        email: emailController.text,
                                      );
                                    },
                                  );
                                },
                              ),
                              CustomTextButton(
                                  text: 'Бүртгүүлэх',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignUpPage()));
                                  }),
                            ],
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
