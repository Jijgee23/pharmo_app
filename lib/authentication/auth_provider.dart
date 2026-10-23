import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/application.dart' hide Response, FormData, MultipartFile;
import 'package:pharmo_app/authentication/auth_operations/complete_registration.dart';
import 'package:pharmo_app/authentication/auth_operations/reset_pass.dart';
import 'package:pharmo_app/authentication/auth_operations/select_branch_sheet.dart';
import 'package:pharmo_app/authentication/widgets/phone_verify_sheet.dart';

class AuthController extends ChangeNotifier {
  void initLoginpage({bool skip = false}) {
    if (skip) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final remembered = await Authenticator.getRemember();
      if (remembered) {
        setRemember(true);
        final idendAndPass = await Authenticator.readIdentifierAndPassword();
        final identifier = idendAndPass['identifier'];
        final pass = idendAndPass['password'];
        fillIdentifier(identifier ?? '');
        fillPassword(pass ?? '');
      }
    });
  }

  bool loading = false;
  bool remember = false;
  bool hidePass = true;

  void toggleHidePass() {
    hidePass = !hidePass;
    notifyListeners();
  }

  void setRemember(bool n) {
    remember = n;
    notifyListeners();
  }

  void setLogging(bool n) {
    loading = n;
    notifyListeners();
  }

  LoginMethod method = LoginMethod.email;
  void setMethod(LoginMethod value) {
    if (method == value) return;
    method = value;
    notifyListeners();
  }

  final TextEditingController ema = TextEditingController();
  final TextEditingController phone = TextEditingController();

  /// The field [method] signs in with; each method keeps its own text.
  TextEditingController get identifierController =>
      method == LoginMethod.email ? ema : phone;
  String get identifier => identifierController.text.trim();

  /// Sign-in takes two steps: the identifier, checked against the server
  /// first ([continueWithIdentifier]), then the password ([login]).
  bool passwordStep = false;

  /// Fills a known e-mail or phone number (a saved login, or one that just
  /// got a password) and goes straight to the password step.
  void fillIdentifier(String identifier) {
    method = LoginMethod.of(identifier);
    identifierController.text = identifier;
    pass.clear();
    passwordStep = identifier.isNotEmpty;
    notifyListeners();
  }

  /// Back to step one, to sign in with a different account.
  void backToIdentifier() {
    passwordStep = false;
    pass.clear();
    notifyListeners();
  }

  /// Step one of sign-in. Asks the server about the identifier
  /// (auth/reged/, auth/check-phone/), then moves on to the password, to
  /// the code-based password setup an account without one must go through,
  /// or to a reset when repeated wrong passwords locked it.
  Future<void> continueWithIdentifier() async {
    if (loading) return;
    setLogging(true);
    // The validators accept surrounding spaces (e.g. from keyboard
    // suggestions), so strip them before the value is sent or saved.
    identifierController.text = identifier;
    AccountStatus? status;
    try {
      status = await checkUsableAccount(
        identifier,
        verifyReason: 'Утсаар нэвтрэхийн өмнө дугаараа баталгаажуулна уу.',
      );
    } finally {
      setLogging(false);
    }
    if (status == null) return;
    if (!status.hasPassword) {
      Get.bottomSheet(CreatePassDialog(identifier: identifier), isScrollControlled: true);
    } else if (status.locked) {
      final reset = await confirmDialog(
        title: 'Түр хаагдсан',
        message: 'Нууц үгээ олон удаа буруу оруулсан тул бүртгэл түр хаагдсан байна. Нууц үгээ сэргээх үү?',
      );
      if (reset) goto(ResetPassword(identifier: identifier));
    } else {
      passwordStep = true;
      notifyListeners();
    }
  }

  /// [checkAccount], plus what both sign-in and password reset need before
  /// going further: the account exists, and a phone number is verified —
  /// verifying it now, since an unverified number can neither sign in nor
  /// get an SMS code. Null when it cannot go further.
  Future<AccountStatus?> checkUsableAccount(
    String identifier, {
    required String verifyReason,
  }) async {
    final status = await checkAccount(identifier);
    if (status == null) return null;
    if (!status.exists) {
      messageWarning(
        LoginMethod.of(identifier) == LoginMethod.email
            ? 'Бүртгэлгүй и-мейл хаяг байна!'
            : 'Бүртгэлгүй утасны дугаар байна!',
      );
      return null;
    }
    if (!status.phoneVerified &&
        !await showPhoneVerifySheet(this, identifier, reason: verifyReason)) {
      return null;
    }
    return status;
  }

  void fillPassword(String value) {
    pass.text = value;
    notifyListeners();
  }

  final TextEditingController pass = TextEditingController();

  bool checker(Map response, String key) {
    if (response.containsKey(key)) {
      return true;
    }
    return false;
  }

  // Нэвтрэх
  Future<void> login() async {
    setLogging(true);
    // The validators accept surrounding spaces (e.g. from keyboard
    // suggestions), so strip them before the value is sent or saved.
    identifierController.text = identifier;
    try {
      var body = {method.key: identifier, 'password': pass.text};
      var r = await apiPostWithoutToken(loginUrl, body);
      if (r == null) {
        messageError(
          'Серверт холбогдож чадсангүй, интернет холболтоо шалгана уу!',
        );
        setLogging(false);
        return;
      }
      final data = apiBody(r);
      if (r.statusCode == 200) {
        _handleSuccessfulLogin(data);
        setLogging(false);
      } else if (r.statusCode == 400 && data is Map) {
        _handleBadRequest(Map<String, dynamic>.from(data));
        setLogging(false);
      } else {
        messageWarning('Алдаа гарлаа, Инфосистемс-ХХК-д хандана уу!');
        setLogging(false);
      }
    } catch (e) {
      messageError(wait);
      setLogging(false);
      debugPrint('error================= on login> ${e.toString()} ');
    } finally {
      setLogging(false);
    }
  }

  // Нэвтрэх амжилттай
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> res) async {
    try {
      final decodedToken = JwtDecoder.decode(res['access_token']);
      print("login success body => $decodedToken");
      if (decodedToken['role'] == 'A') {
        messageWarning('Веб хуудсаар хандана уу!');
        return;
      }
      await Authenticator.clearSecurity();
      await Authenticator.saveModel(res);
      await Authenticator.initAuthenticator();
      await getDeviceInfo();
      await Authenticator.saveLastLoggedIn(true);
      await LogService().createLog('Нэвтрэх', LogService.login);
      if (remember) {
        await Authenticator.saveRemember();
        await Authenticator.saveIdentifierAndPassword(identifier, pass.text);
      }
      final sec = Authenticator.security;
      if (sec == null) return;
      await Authenticator.saveLoginHistory(identifier, sec.name);
      if (sec.isPharmacist) {
        await _maybeSelectBranch();
      }
      setLogging(false);
      await gotoRootPage();
    } catch (e) {
      throw Exception(e);
    }
  }

  // PA staff acting across multiple branches must pick which one they're
  // acting as before proceeding to the home screen — PATCH select_branch/
  // swaps the stored access token for one scoped to that branch's
  // customer_id claim. Skipped entirely when there's only one branch (or
  // none), matching the existing order_sheet.dart auto-select-if-one
  // convention for the same branch list.
  Future<void> _maybeSelectBranch() async {
    final context = Get.context;
    if (context == null) return;
    final home = context.read<HomeProvider>();
    await home.getBranches();
    if (home.branches.length <= 1) return;
    await showSelectBranchSheet();
  }

  // Нэвтрэх амжилтгүй
  void _handleBadRequest(Map<String, dynamic> res) {
    if (checker(res, 'noCmp')) {
      goto(CompleteRegistration(ema: identifier, pass: pass.text));
      return;
    }
    if (checker(res, 'no_password')) {
      Get.bottomSheet(
        CreatePassDialog(identifier: identifier),
        isScrollControlled: true,
      );
    } else if (checker(res, 'phone_unverified')) {
      _verifyPhoneAndRetry();
    } else if (checker(res, 'noLic') || checker(res, 'noLoc')) {
      messageWarning('Веб хуудсаар хандан бүртгэл гүйцээнэ үү!');
    } else if (checker(res, 'noRev')) {
      messageWarning('Бүртгэлийн мэдээллийг хянаж байна, түр хүлээнэ үү!');
    } else if (checker(res, 'password')) {
      messageWarning(apiErrorMessage(res['password']) ?? 'Нууц үг буруу байна!');
    } else if (checker(res, 'email')) {
      messageWarning('Имейл хаяг бүртгэлгүй байна!');
    } else if (checker(res, 'phone')) {
      messageWarning(apiErrorMessage(res['phone']) ?? 'Утасны дугаар бүртгэлгүй байна!');
    } else if (checker(res, 'password_blocked')) {
      goto(ResetPassword(identifier: identifier));
    } else {
      messageWarning(apiErrorMessage(res) ?? wait);
    }
  }

  // Phone sign-in needs a verified number: verify it, then sign in again.
  Future<void> _verifyPhoneAndRetry() async {
    final verified = await showPhoneVerifySheet(
      this,
      identifier,
      reason: 'Утсаар нэвтрэхийн өмнө дугаараа баталгаажуулна уу.',
    );
    if (verified) await login();
  }

  Future<void> logout(BuildContext context, {bool withoutRequest = false}) async {
    try {
      // api() дуудалтыг тэр даруй таслах — async clearSecurity()-г хүлээхгүй
      Authenticator.security = null;
      if (!withoutRequest) {
        await LogService().createLog('Системээс гарах', LogService.logout);
        await api(Api.post, logoutUrl);
      }
      await Authenticator.removeTokens();
      await Authenticator.clearSecurity();
      await Authenticator.saveLastLoggedIn(false);
      if (!context.mounted) return;
      context.read<HomeProvider>().reset();
      context.read<CartProvider>().reset();
      context.read<DriverProvider>().reset();
      context.read<JaggerProvider>().reset();
      context.read<LogProvider>().reset();
      context.read<OrderProvider>().reset();
      context.read<PharmProvider>().reset();
      context.read<PromotionProvider>().reset();
      context.read<ReportProvider>().reset();
      // Санамж: goNamedOfAll(Get.offAndToNamed) буцаадаг Future нь шинэ
      // ('root') дэлгэц ХОЖИМ нь pop хийгдэх хүртэл resolve болохгүй тул
      // энд await хийвэл дуудагч (LoadingService.run гэх мэт) мөнхөд
      // хүлээх болно. logout()-ийн бодит ажил дээрх мөрүүдэд аль хэдийн
      // дуусаж, шилжилтийг эхлүүлээд л болно.
      goNamedOfAll('root');
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  // Бүртгэл батлагаажуулах код авах
  Future signUpGetOtp(String email, String phone) async {
    try {
      final response = await apiPostWithoutToken(
        'auth/reg_otp/',
        {'email': email, 'phone': phone},
      );
      // apiPostWithoutToken has already told the user why.
      if (response == null) return null;
      if (response.statusCode == 200) {
        return buildResponse(1, null, 'Батлагаажуулах код илгээлээ.');
      } else if (response.statusCode == 425) {
        // A code went out moments ago and is still valid.
        return buildResponse(4, null, _cooldownMessage(response));
      } else if (response.statusCode == 400) {
        return buildResponse(2, null, 'И-Мейл эсвэл утас бүртгэлтэй байна!');
      } else {
        return buildResponse(3, null, 'Алдаа гарлаа!');
      }
    } catch (e) {
      return buildResponse(3, null, 'Алдаа гарлаа!!');
    }
  }

  // Бүртгүүлэх
  Future register(
      {required String email,
      required String phone,
      required String otp,
      required String password}) async {
    try {
      var body = {'email': email, 'phone': phone, 'otp': otp, 'password': password};
      final response = await apiPostWithoutToken(registerUrl, body);
      final data = convertData(response!);
      print(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return buildResponse(1, data, 'Бүртгэл үүслээ');
      } else if (response.statusCode == 500) {
        return buildResponse(2, data, 'Түр хүлээгээд дахин оролдоно уу!');
      } else if (response.statusCode == 400) {
        if (checker(data, 'otp') == true) {
          return buildResponse(3, data, 'Батлагаажуулах код буруу!');
        } else {
          return buildResponse(0, data, 'Алдаа гарлаа');
        }
      }
    } catch (e) {
      return buildResponse(0, null, 'Алдаа гарлаа');
    }
    notifyListeners();
  }

  /// What the server says about [identifier] before any password is asked
  /// for (auth/reged/ for an e-mail, auth/check-phone/ for a phone); null
  /// when it could not be asked.
  Future<AccountStatus?> checkAccount(String identifier) async {
    final isPhone = LoginMethod.of(identifier) == LoginMethod.phone;
    final r = await apiPostWithoutToken(
      isPhone ? 'auth/check-phone/' : 'auth/reged/',
      {(isPhone ? LoginMethod.phone : LoginMethod.email).key: identifier},
    );
    if (r == null) return null;
    final data = apiBody(r);
    if (r.statusCode != 200 || data is! Map) {
      messageWarning(apiErrorMessage(data) ?? wait);
      return null;
    }
    if (isPhone) {
      return AccountStatus(
        exists: data['exists'] == true && data['isActive'] != false,
        hasPassword: data['needsPasswordSetup'] != true,
        phoneVerified: data['phoneVerified'] == true,
      );
    }
    // `ema` is the address when registered and active, false otherwise.
    return AccountStatus(
      exists: data['ema'] is String,
      hasPassword: data['pwd'] == true,
      locked: data['pwd_blocked'] == true,
    );
  }

  /// Sends the code [createPassword] needs: by e-mail (auth/get_otp/) or by
  /// SMS (auth/phone/send-otp/).
  Future<OtpRequest> sendPasswordOtp(String identifier) async {
    if (LoginMethod.of(identifier) == LoginMethod.phone) {
      // Answers 200 whatever happens, by design, and sends nothing to an
      // unverified number — checkAccount() is how callers find that out.
      final r = await apiPostWithoutToken(
        'auth/phone/send-otp/',
        {'phone': identifier, 'purpose': 'password_reset'},
      );
      if (r == null) return OtpRequest.failed;
      messageComplete('Батлагаажуулах код илгээлээ');
      return OtpRequest.sent;
    }
    final r = await apiPostWithoutToken('auth/get_otp/', {'email': identifier});
    if (r == null) return OtpRequest.failed;
    switch (r.statusCode) {
      case 200:
        messageComplete('Батлагаажуулах код илгээлээ');
        return OtpRequest.sent;
      case 425:
        messageWarning(_cooldownMessage(r));
        return OtpRequest.cooldown;
      default:
        messageWarning(apiErrorMessage(apiBody(r)) ?? 'И-Мейл хаяг бүртгэлгүй байна');
        return OtpRequest.failed;
    }
  }

  /// Sets a new password with the code from [sendPasswordOtp] (auth/reset/).
  /// On success pops the current route back to the login page, waiting at
  /// the password step for [identifier].
  Future createPassword(
    String identifier,
    String otp,
    String newPassword,
    BuildContext context,
  ) async {
    try {
      final b = {
        LoginMethod.of(identifier).key: identifier,
        'otp': otp,
        'new_pwd': newPassword,
      };
      final response = await apiPostWithoutToken('auth/reset/', b);
      if (response == null) return;
      if (response.statusCode == 200) {
        messageComplete('Нууц үг амжилттай хадгалагдлаа');
        fillIdentifier(identifier);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else if (response.statusCode == 404) {
        messageWarning('Баталгаажуулах код олдсонгүй, дахин код авна уу!');
      } else {
        final data = apiBody(response);
        if (data is Map && data.containsKey('new_pwd')) {
          messageWarning('Нууц үг шаардлага хангахгүй байна!');
        } else {
          messageWarning(apiErrorMessage(data) ?? wait);
        }
      }
    } catch (e) {
      return messageError(wait);
    }
  }

  /// Texts [phone] a code proving it belongs to the caller
  /// (auth/phone/send-otp/, purpose `verification`).
  Future<bool> sendPhoneVerification(String phone) async {
    final r = await apiPostWithoutToken(
      'auth/phone/send-otp/',
      {'phone': phone, 'purpose': 'verification'},
    );
    if (r == null) return false;
    messageComplete('Батлагаажуулах код илгээлээ');
    return true;
  }

  /// Checks the code from [sendPhoneVerification]; once it passes, the
  /// number can sign in and receive password codes.
  Future<bool> verifyPhone(String phone, String otp) async {
    final r = await apiPostWithoutToken(
      'auth/phone/verify-otp/',
      {'phone': phone, 'otp': otp, 'purpose': 'verification'},
    );
    if (r == null) return false;
    if (r.statusCode == 200) {
      messageComplete('Утасны дугаар баталгаажлаа');
      return true;
    }
    messageWarning(apiErrorMessage(apiBody(r)) ?? 'Баталгаажуулах код буруу байна!');
    return false;
  }

  /// Changes the signed-in user's password (auth/change/). On success the
  /// server ends every session, this one included, so the caller must sign
  /// the user out.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final r = await api(
      Api.post,
      'auth/change/',
      body: {'old_pwd': oldPassword, 'new_pwd': newPassword},
    );
    if (r == null) return false;
    if (r.statusCode == 200) {
      // Keep «Сануулах» signing in with the new password.
      final saved = await Authenticator.readIdentifierAndPassword();
      if (await Authenticator.getRemember() && saved['password'] == oldPassword) {
        await Authenticator.saveIdentifierAndPassword(saved['identifier'] ?? '', newPassword);
      }
      return true;
    }
    final data = apiBody(r);
    if (data is Map && data.containsKey('new_pwd')) {
      messageWarning('Нууц үг шаардлага хангахгүй байна!');
    } else {
      messageWarning(apiErrorMessage(data) ?? wait);
    }
    return false;
  }

  Future getDeviceInfo() async {
    final deviceManager = DeviceManager();
    final device = await deviceManager.deviceInfo();
    // device_token/ takes "android", "ios" or "other", lower case only.
    final platform = device.type.toLowerCase();
    try {
      final data = {
        'token': device.firebaseToken,
        'platform': const {'android', 'ios'}.contains(platform) ? platform : 'other',
        'brand': device.brand,
        'model': device.model,
        'modelVersion': device.modelVersion,
        'os': device.os,
        'osVersion': device.osVersion,
      };
      final r = await api(Api.post, deviceTokenUrl, body: data);
      if (r == null) return;
      if (r.statusCode == 200) {
        debugPrint('Device info sent');
      } else {
        debugPrint('Device info not sent: ${apiBody(r)}');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future completeRegistration(
      {required String ema,
      required String pass,
      required String name,
      required String publicName,
      required String rd,
      required String type,
      String? additional,
      String? inviCode,
      String? address,
      required List<File> license,
      File? logo,
      required double? lat,
      required double? lng}) async {
    try {
      // Called after login answered noCmp, so there is no token yet: the
      // endpoint also takes Basic auth.
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$ema:$pass'))}';
      if (license.isEmpty) {
        return buildResponse(2, null, 'Тусгай зөвшөөрөл хавсаргана уу!');
      }
      if (logo == null) {
        return buildResponse(2, null, 'Лого хавсаргана уу!');
      }

      // Files must already meet the upload rules — see compressImage().
      final formData = FormData.fromMap({
        'license[]': await Future.wait(license.map(ApiService.imagePart)),
        'logo': await ApiService.imagePart(logo),
        'public_name': publicName,
        // The sign-in identifier doubles as the contact e-mail or phone.
        LoginMethod.of(ema).key: ema,
        'password': pass,
        'name': name,
        'rd': rd,
        if (additional != null) 'note': additional,
        if (inviCode != null) 'referral_code': inviCode,
        'cType': (type == 'Эмийн сан') ? 'P' : 'S',
        'address2': jsonEncode({'lat': lat, 'lng': lng, 'address2': address}).toString(),
      });
      final res = await ApiService.plainDio.post(
        ApiService.buildUrl('company/info/').toString(),
        data: formData,
        options: Options(headers: {
          ...ApiService.clientHeader,
          'Authorization': basicAuth,
          'Accept': 'application/json',
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return buildResponse(1, null, 'Мэдээлэл амжилттай хадгалагдлаа. Нэвтэрнэ үү!');
      }
      final data = apiBody(res);
      if ('$data'.contains('already exists')) {
        return buildResponse(2, null, 'И-Мейл, РД эсвэл нэр давхардаж байна!');
      }
      return buildResponse(3, null, apiErrorMessage(data) ?? wait);
    } catch (e) {
      debugPrint('company/info/ failed: $e');
      return buildResponse(3, null, wait);
    }
  }
}

/// What the server knows about an e-mail or phone before any password is
/// asked for — see [AuthController.checkAccount].
class AccountStatus {
  /// Registered and active; inactive accounts read as unregistered.
  final bool exists;
  final bool hasPassword;

  /// Always true for an e-mail. An unverified number can neither sign in nor
  /// receive a password code until it is verified.
  final bool phoneVerified;

  /// Temporarily locked out after too many wrong passwords; clears by itself,
  /// or with a reset. Only reported for an e-mail.
  final bool locked;

  const AccountStatus({
    required this.exists,
    required this.hasPassword,
    this.phoneVerified = true,
    this.locked = false,
  });
}

/// auth/get_otp/ and auth/reg_otp/ answer 425 with the seconds left until
/// another code may be requested.
String _cooldownMessage(Response r) {
  final seconds = int.tryParse('${apiBody(r)}'.trim());
  return seconds == null
      ? 'Код саяхан илгээсэн тул түр хүлээгээд дахин авна уу.'
      : 'Код саяхан илгээсэн. $seconds секундын дараа дахин авах боломжтой.';
}
