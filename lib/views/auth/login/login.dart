import 'package:pharmo_app/views/auth/login/auth_text.dart';
import 'package:pharmo_app/views/auth/login/forget_and_signup.dart';
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
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Builder(builder: (context) {
            if (auth.loading) {
              return PharmoIndicator();
            }
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LoginHeaderImage(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(color: theme.cardColor),
                    child: Center(
                      child: Column(
                        spacing: 15,
                        children: [
                          SizedBox(),
                          AuthText('Нэвтрэх'),
                          CustomTextField(
                            controller: auth.ema,
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
                          CustomTextField(
                            autofillHints: const [AutofillHints.password],
                            controller: auth.pass,
                            hintText: 'Нууц үг',
                            obscureText: auth.hidePass,
                            validator: validatePassword,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              onPressed: auth.toggleHidePass,
                              icon: Icon(
                                auth.hidePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.primaryColor.withAlpha(75),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => auth.setRemember(!auth.remember),
                            child: Row(
                              spacing: 5,
                              children: [
                                Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: auth.remember,
                                  onChanged: (val) =>
                                      auth.setRemember(!auth.remember),
                                ),
                                Text(
                                  'Сануулах',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(
                              text: 'Нэвтрэх',
                              ontap: () async {
                                if (!formKey.currentState!.validate()) {
                                  message('Нэвтрэх нэр, нууц үг оруулна уу');
                                  return;
                                }
                                await auth.login();
                              }),
                          ForgetAndSignup(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          bottomNavigationBar: LoginFooter(),
        );
      },
    );
  }
}
