import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/models/a_models.dart';
import 'package:pharmo_app/services/local_base.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/services/firebase_sevice.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/auth/sign_up.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController ema = TextEditingController();
  final TextEditingController pass = TextEditingController();
  bool hover = false;

  init() {
    final auth = context.read<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Security? security = LocalBase.security;
      if (security == null) {
        return;
      }
      await auth.checkForUpdate().whenComplete(() async {
        final remembered = await LocalBase.getRemember();
        if (remembered) {
          setState(() {
            auth.setRemember(true);
            ema.text = security.email;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    firebaseInit(context);
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(builder: (context, auth, child) {
      bool logging = auth.loading;
      return Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(75),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Image.asset('assets/picon.png'),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                ),
                child: Center(
                  child: Column(
                    spacing: 15,
                    children: [
                      SizedBox(),
                      authText('Нэвтрэх'),
                      CustomTextField(
                        controller: ema,
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
                        controller: pass,
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
                          icon: Icon(
                              hover ? Icons.visibility_off : Icons.visibility,
                              color: theme.primaryColor.withAlpha(75)),
                        ),
                      ),
                      Row(
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
                      CustomButton(
                        text: 'Нэвтрэх',
                        ontap: () => _handleLogin(auth),
                        child: logging
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(color: white),
                                  ),
                                  SizedBox(width: Sizes.width * 0.03),
                                  const Text(
                                    'Түр хүлээнэ үү!',
                                    style: TextStyle(color: white),
                                  )
                                ],
                              )
                            : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextButton(
                              text: 'Нууц үг сэргээх',
                              onTap: () => goto(const ResetPassword())),
                          CustomTextButton(
                              text: 'Бүртгүүлэх',
                              onTap: () => goto(const SignUpForm())),
                        ],
                      ),
                      if (auth.checking)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SmallText('Шинэчлэлт шалгаж байна'),
                            SizedBox(width: Sizes.bigFontSize),
                            CircularProgressIndicator.adaptive(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: BoxDecoration(
            color: primary.withAlpha(60),
            borderRadius: topBorderRadius(),
          ),
        ),
      );
    });
  }

  _handleLogin(AuthController auth) async {
    if (!formKey.currentState!.validate()) {
      message('Нэврэх нэр, нууц үг оруулна уу');
      return;
    }
    await auth.login(ema.text, pass.text, context);
  }
}

topBorderRadius() {
  return const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );
}

Widget authText(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: theme.primaryColor,
      ),
    ),
  );
}

bottomRadius() {
  return const BorderRadius.only(
    bottomLeft: Radius.circular(30),
    bottomRight: Radius.circular(30),
  );
}
