import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/views/auth/signup_page.dart';
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

final emailController = TextEditingController();
final passwordController = TextEditingController();
final _formKey = GlobalKey<FormState>();

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
                      const CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('Нэвтрэх'),
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
                                  : Icons.visibility)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                          text: !authController.invisible
                              ? 'Үргэлжлүүлэх'
                              : 'Нэвтрэх',
                          ontap: () async {
                            if (_formKey.currentState!.validate()) {
                              TextInput.finishAutofillContext();
                            }
                            if (!authController.invisible) {
                              if (passwordController.text.isNotEmpty) {
                                await authController.login(emailController.text,
                                    passwordController.text, context);
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
