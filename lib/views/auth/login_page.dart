import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final _formKey = GlobalKey<FormState>();

class _LoginPageState extends State<LoginPage> {
  bool hover = false;
  bool rememberMe = false;
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: size.height * 0.13,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: const Column(
              children: [
                Text(
                  'Pharmo',
                  style: TextStyle(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ),
                Text(
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
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/icons/login.png',
                        height: 75,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Нэвтрэх',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: emailController,
                        autofillHints: const [AutofillHints.email],
                        hintText: 'Имейл хаяг',
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      Visibility(
                        visible: !authController.invisible,
                        child: CustomTextField(
                          autofillHints: const [AutofillHints.password],
                          controller: passwordController,
                          hintText: 'Нууц үг',
                          obscureText: !hover,
                          validator: validatePassword,
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
                      ),
                      Visibility(
                        visible: !authController.invisible,
                        child: Row(
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
                      ),
                      CustomButton(
                          text: !authController.invisible
                              ? 'Нэвтрэх'
                              : 'Үргэлжлүүлэх',
                          ontap: () async {
                            if (_formKey.currentState!.validate()) {
                              TextInput.finishAutofillContext();
                            }
                            if (!authController.invisible) {
                              if (passwordController.text.isNotEmpty) {
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
                                    message: 'Нууц үгээ оруулна уу');
                              }
                            } else {
                              final bool reged = await authController
                                  .checkEmail(emailController.text, context);
                              if (reged) {
                                authController.toggleVisibile();
                              }
                            }
                          }),
                      const SizedBox(height: 15),
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
                                            builder: (_) =>
                                                const SignUpPage()));
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
      ),
    );
  }
}
