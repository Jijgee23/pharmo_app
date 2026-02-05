import 'package:pharmo_app/authentication/login/auth_text.dart';
import 'package:pharmo_app/authentication/login/login_footer.dart';
import 'package:pharmo_app/authentication/login/login_header_image.dart';
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
        return Scaffold(
          body: Stack(
            children: [
              // Main content
              Form(
                key: formKey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    LoginHeaderImage(loading: auth.loading),
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
                            enabled: !auth.loading,
                          ),
                          const SizedBox(height: 15),

                          // Нууц үг
                          CustomTextField(
                            controller: auth.pass,
                            autofillHints: const [AutofillHints.password],
                            hintText: 'Нууц үг',
                            obscureText: auth.hidePass,
                            prefix: Icons.lock_outline,
                            enabled: !auth.loading,
                            suffixIcon: IconButton(
                              onPressed:
                                  auth.loading ? null : auth.toggleHidePass,
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
                                    onChanged: auth.loading
                                        ? null
                                        : (val) => auth.setRemember(val!),
                                  ),
                                  Text(
                                    'Сануулах',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: auth.loading ? grey400 : null,
                                    ),
                                  ),
                                ],
                              ),
                              CustomTextButton(
                                text: 'Нууц үг мартсан?',
                                onTap: auth.loading
                                    ? null
                                    : () => goNamed('reset_password'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _LoginButton(
                            loading: auth.loading,
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                await auth.login();
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: IgnorePointer(
                              ignoring: auth.loading,
                              child: AnimatedOpacity(
                                opacity: auth.loading ? 0.5 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: const SignupPrompt(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading overlay
              // if (auth.loading)
              //   AnimatedOpacity(
              //     opacity: auth.loading ? 1.0 : 0.0,
              //     duration: const Duration(milliseconds: 200),
              //     child: Container(
              //       color: Colors.white.withOpacity(0.7),
              //       child: const Center(
              //         child: PharmoIndicator(),
              //       ),
              //     ),
              //   ),
            ],
          ),
          bottomNavigationBar: const LoginFooter(),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _LoginButton({
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: loading ? 0 : 2,
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Нэвтрэх',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
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
