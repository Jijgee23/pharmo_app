import 'package:pharmo_app/views/auth/login/auth_text.dart';
import 'package:pharmo_app/views/auth/login/login_footer.dart';
import 'package:pharmo_app/views/auth/login/login_header_image.dart';
import 'package:pharmo_app/application/application.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().initLoginpage();
    });
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        if (auth.loading) {
          return const PharmoIndicator(
            withMaterial: true,
          );
        }

        return Scaffold(
          body: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const LoginHeaderImage(),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthText('Нэвтрэх'),
                      const SizedBox(height: 10),
                      Text(
                        'Үргэлжлүүлэхийн тулд бүртгэлээрээ нэвтэрнэ үү.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 30),

                      // Имейл
                      CustomTextField(
                        controller: auth.ema,
                        autofillHints: const [AutofillHints.email],
                        hintText: 'Имейл хаяг',
                        prefix: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      // Нууц үг
                      CustomTextField(
                        controller: auth.pass,
                        autofillHints: const [AutofillHints.password],
                        hintText: 'Нууц үг',
                        obscureText: auth.hidePass,
                        prefix: Icons.lock_outline,
                        suffixIcon: IconButton(
                          onPressed: auth.toggleHidePass,
                          icon: Icon(
                            auth.hidePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),

                      // Сануулах & Нууц үг мартсан
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                value: auth.remember,
                                onChanged: (val) => auth.setRemember(val!),
                              ),
                              const Text('Сануулах',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          CustomTextButton(
                            text: 'Нууц үг мартсан?',
                            onTap: () => goNamed('reset_password'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Нэвтрэх',
                        ontap: () async {
                          if (formKey.currentState!.validate()) {
                            await auth.login();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Center(child: SignupPrompt()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const LoginFooter(),
        );
      },
    );
  }
}

class SignupPrompt extends StatelessWidget {
  const SignupPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Бүртгэлгүй юу? '),
        GestureDetector(
          onTap: () => goNamed('signup'),
          child: Text(
            'Бүртгүүлэх',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
