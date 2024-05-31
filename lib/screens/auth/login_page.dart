import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/screens/auth/signup_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

final emailController = TextEditingController(text: 'p1@a.mn');
final passwordController = TextEditingController(text: 'pasS0011');

class _LoginPageState extends State<LoginPage> {
  bool hover = false;
  late AuthController authController;
  @override
  void initState() {
    super.initState();
    authController = Provider.of<AuthController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);

    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: size.height * 0.13,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                Text(
                  'Pharmo',
                  style: TextStyle(
                      fontSize: size.height * 0.04,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
                Text(
                  'Эмийн бөөний худалдаа,\n захиалгын систем',
                  style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.1, horizontal: size.width * 0.1),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    const Text('Нэвтрэх'),
                    SizedBox(height: size.height * 0.03),
                    CustomTextField(
                        controller: emailController,
                        hintText: 'Имейл хаяг',
                        obscureText: false,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress),
                    SizedBox(height: size.height * 0.03),
                    Visibility(
                      visible: !authController.invisible,
                      child: CustomTextField(
                        controller: passwordController,
                        hintText: 'Нууц үг',
                        obscureText: !hover,
                        validator: validatePassword,
                        keyboardType: TextInputType.name,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hover = !hover;
                              });
                            },
                            icon: Icon(hover
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    CustomButton(
                        text: !authController.invisible
                            ? 'Үргэлжлүүлэх'
                            : 'Нэвтрэх',
                        ontap: () async {
                          if (!authController.invisible) {
                            if (passwordController.text.isNotEmpty) {
                              await authController
                                  .login(emailController.text,
                                      passwordController.text, context)
                                  .whenComplete(() {
                                passwordController.clear();
                              });
                            } else {
                              showFailedMessage(
                                  context: context,
                                  message: 'Нууц үгээ оруулна уу');
                            }
                          } else {
                            final bool islock = await authController.checkEmail(
                                emailController.text, context);
                            if (islock) {
                              authController.toggleVisibile();
                            }
                          }
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        authController.invisible
                            ? const Text('')
                            : CustomTextButton(
                                text: 'Буцах',
                                onTap: () {
                                  setState(() {
                                    authController.invisible =
                                        !authController.invisible;
                                  });
                                }),
                        authController.invisible
                            ? CustomTextButton(
                                text: 'Бүртгүүлэх',
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SignUpPage()));
                                })
                            : CustomTextButton(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
