import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/firebase_api.dart';
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
  bool isDownloading = false;
  setIsDownloading(bool n) {
    setState(() {
      isDownloading = n;
    });
  }

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
      setState(() {
        rememberMe = true;
      });
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
    firebaseInit(context);
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;
    try {
      setState(() => _isCheckingForUpdates = true);
      final status = await _updater.checkForUpdate(track: currentTrack);
      if (status == UpdateStatus.outdated) {
        _downloadUpdate().then((e) => _restartBanner());
      } else if (status == UpdateStatus.restartRequired) {
        _restartBanner();
      }
    } catch (error) {
      debugPrint('Error checking for update: $error');
    } finally {
      setState(() => _isCheckingForUpdates = false);
    }
  }

  Future<void> _downloadUpdate() async {
    try {
      await _updater.update(track: currentTrack);
      if (!mounted) return;
    } on UpdateException catch (error) {
      debugPrint(error.toString());
    }
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
                    ontap: () => Restart.restartApp(
                      notificationTitle: 'Шинэчлэлт татагдлаа',
                      notificationBody: 'Энд дарж нээнэ үү!',
                    ),
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

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Image.asset('assets/picon.png'),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
              ),
              child: Center(
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
                        icon: Icon(hover ? Icons.visibility_off : Icons.visibility,
                            color: theme.primaryColor.withOpacity(.3)),
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
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      ontap: () => _handleLogin(authController),
                      child: logging
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: white),
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
                            text: 'Нууц үг сэргээх', onTap: () => goto(const ResetPassword())),
                        CustomTextButton(text: 'Бүртгүүлэх', onTap: () => goto(const SignUpForm())),
                      ],
                    ),
                    if (_isCheckingForUpdates)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmallText('Шинэчлэлт шалгаж байна'),
                          SizedBox(width: Sizes.bigFontSize),
                          CircularProgressIndicator.adaptive(),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: primary.withOpacity(.3),
          borderRadius: topBorderRadius(),
        ),
      ),
    );
  }

  _handleLogin(AuthController auth) async {
    await _checkForUpdate();
    final status = await _updater.checkForUpdate(track: currentTrack);
    if (status == UpdateStatus.outdated) {
      _downloadUpdate().then((e) => _restartBanner());
    } else if (status == UpdateStatus.restartRequired) {
      _restartBanner();
    } else {
      if (pass.text.isNotEmpty && ema.text.isNotEmpty) {
        await auth.login(ema.text, pass.text, context).whenComplete(() async {
          if (rememberMe) {
            await box1.put('email', ema.text);
            await box1.put('password', pass.text);
          }
        });
      } else {
        message('Нэврэх нэр, нууц үг оруулна уу');
      }
    }
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
