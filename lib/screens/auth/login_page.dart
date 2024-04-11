import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/auth/signup_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

final emailController = TextEditingController();
final passwordController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Provider.of<AuthController>(context);
    late bool hover = true;
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
                    CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            hover = !hover;
                          });
                        },
                        icon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                        ),
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
                        obscureText: hover,
                        validator: validatePassword,
                        keyboardType: TextInputType.name,
                        suffixIcon: Icons.lock,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    CustomButton(
                        text: !authController.invisible
                            ? 'Үргэлжлүүлэх'
                            : 'Нэвтрэх',
                        ontap: () async {
                          if (!authController.invisible) {
                            await authController.login(emailController.text,
                                passwordController.text, context);
                          } else {
                            final bool islock = await authController.checkEmail(
                                emailController.text, context);
                            if (islock) {
                              setState(() {
                                authController.toggleVisibile();
                              });
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

class TokenManager {
  static const String _tokenKey = 'token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
