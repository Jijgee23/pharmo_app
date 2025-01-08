import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/global_key.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/public_uses/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  final TextEditingController ema = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final FocusNode email = FocusNode();
  final FocusNode password = FocusNode();
  bool hover = false;
  late Box box1;
  //codepush
  final _updater = ShorebirdUpdater();
  late final bool isUpdaterAvailable;
  var currentTrack = UpdateTrack.stable;
  var _isCheckingForUpdates = false;
  Patch? currentPatch;
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
      ema.text = box1.get('email');
    }
    if (box1.get('password') != null) {
      pass.text = box1.get('password');
    }
  }

  @override
  void initState() {
    super.initState();
    _openBox();
    setState(() => isUpdaterAvailable = _updater.isAvailable);
    _updater.readCurrentPatch().then((currentPatch) {
      setState(() => currentPatch = currentPatch);
    }).catchError((Object error) {
      debugPrint('Алдаа: $error');
    });
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;
    try {
      setState(() => _isCheckingForUpdates = true);
      final status = await _updater.checkForUpdate(track: currentTrack);
      if (!mounted) return;
      switch (status) {
        case UpdateStatus.upToDate:
        case UpdateStatus.outdated:
          await _downloadUpdate();
        case UpdateStatus.restartRequired:
          await _restartBanner();
        case UpdateStatus.unavailable:
      }
    } catch (error) {
      debugPrint('Error checking for update: $error');
    } finally {
      setState(() => _isCheckingForUpdates = false);
    }
  }

  Future<void> _downloadUpdate() async {
    // final status = await _updater.checkForUpdate(track: currentTrack);
    try {
      //  await _updater.update(track: currentTrack);
      // _restartBanner();
      // if (!mounted) return;
      await _updater.update(track: currentTrack).then((e) {
        _restartBanner();
      });
      if (!mounted) return;

      // _restartBanner();
    } on UpdateException catch (error) {
      debugPrint(error.toString());
    }
    // message('Шинэчлэлт татагдлаа');
    // if (status == UpdateStatus.restartRequired) {
    //   await _restartBanner();
    // }
  }

  Future<void> _restartBanner() async {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Шинэчлэлт татагдлаа!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Дахин ачаалах шаардлагатай!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Дахин ачаалуулах',
                    ontap: () => Restart.restartApp(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    bool logging = authController.loading;
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: theme.primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/picon.png'),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: theme.cardColor, borderRadius: topBorderRadius()),
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    authText('Нэвтрэх'),
                    CustomTextField(
                      controller: ema,
                      autofillHints: const [AutofillHints.email],
                      focusNode: email,
                      hintText: 'Имейл хаяг',
                      validator: (v) {
                        if (v!.isNotEmpty) {
                          return validateEmail(v);
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      // onSubmitted: (p0) =>
                      //     FocusScope.of(context).requestFocus(password),
                    ),
                    CustomTextField(
                      autofillHints: const [AutofillHints.password],
                      controller: pass,
                      hintText: 'Нууц үг',
                      obscureText: !hover,
                      focusNode: password,
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
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Намайг сана',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Checkbox(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: rememberMe,
                          onChanged: (val) {
                            setState(() {
                              rememberMe = !rememberMe;
                            });
                          },
                        ),
                      ],
                    ),
                    CustomButton(
                      text: 'Нэвтрэх',
                      ontap: () async {
                        await _checkForUpdate();
                        if (pass.text.isNotEmpty && ema.text.isNotEmpty) {
                          await authController
                              .login(ema.text, pass.text, context)
                              .whenComplete(() async {
                            if (rememberMe) {
                              await box1.put('email', ema.text);
                              await box1.put('password', pass.text);
                            }
                          });
                        } else {
                          message('Нэврэх нэр, нууц үг оруулна уу');
                        }
                      },
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
                          onTap: () => goto(const ResetPassword()),
                        ),
                        CustomTextButton(
                          text: 'Бүртгүүлэх',
                          onTap: () {
                            goto(const SignUpForm());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !logging
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: CustomTextButton(
                text: 'Нууцлалын бодлого',
                onTap: () => goto(const PrivacyPolicy()),
              ),
            )
          : const SizedBox(),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController ema = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController passConfirm = TextEditingController();
  final TextEditingController otp = TextEditingController();
  bool showPasss = false;
  bool otpSent = false;
  setOtpSent(bool n) {
    setState(() {
      otpSent = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        'assets/picon.png',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: h * .05,
                  left: 20,
                  child: back(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: topBorderRadius(),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 15,
                  children: [
                    authText('Бүртгүүлэх'),
                    CustomTextField(
                      controller: ema,
                      hintText: 'Имейл',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    CustomTextField(
                      controller: phone,
                      hintText: 'Утасны дугаар',
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    (otpSent)
                        ? CustomTextField(
                            controller: otp,
                            hintText: 'Батлагаажуулах код',
                            keyboardType: TextInputType.number,
                          )
                        : const SizedBox(),
                    (otpSent)
                        ? CustomTextField(
                            controller: pass,
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
                              icon: Icon(
                                  showPasss
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.primaryColor),
                            ),
                          )
                        : const SizedBox(),
                    (otpSent)
                        ? CustomTextField(
                            controller: passConfirm,
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
                              icon: Icon(
                                  showPasss
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.primaryColor),
                            ),
                          )
                        : const SizedBox(),
                    (!otpSent)
                        ? CustomButton(
                            text: 'Батлагаажуулах код авах',
                            ontap: () => getOtp(authController),
                          )
                        : CustomButton(
                            text: 'Батлагаажуулах',
                            ontap: () => confirm(authController),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getOtp(AuthController authController) async {
    if (ema.text.isNotEmpty && phone.text.isNotEmpty) {
      dynamic res = await authController.signUpGetOtp(ema.text, phone.text);
      final keyK = res['errorType'];
      if (keyK == 1) {
        setOtpSent(true);
      }
      message(res['message']);
    } else {
      message('Бүртгэлийг талбарууд гүйцээнэ үү!');
    }
  }

  confirm(AuthController authController) async {
    if (pass.text == passConfirm.text && pass.text.isNotEmpty) {
      dynamic res = await authController.register(
          ema.text, phone.text, pass.text, otp.text);
      message(res['message']);
      if (res['errorType'] == 1) {
        Get.back();
      }
    } else {
      message('Нууц үг таарахгүй байна!');
    }
  }
}

topBorderRadius() {
  return const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );
}

class PharmoIndicator extends StatefulWidget {
  const PharmoIndicator({super.key});

  @override
  State<PharmoIndicator> createState() => _PharmoIndicatorState();
}

class _PharmoIndicatorState extends State<PharmoIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.141592653589793, // Full circle
          child: child,
        );
      },
      child: Image.asset(
        'assets/logo_circle.png',
        height: 50,
      ),
    );
  }
}

Widget authText(String text) {
  return Align(
    alignment: Alignment.center,
    child: Text(
      text,
      style: TextStyle(
        fontSize: Sizes.mediulFontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(GlobalKeys.navigatorKey.currentState!.context)
            .primaryColor,
      ),
    ),
  );
}
