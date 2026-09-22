import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:http_parser/http_parser.dart' as pharser;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/application/application.dart'
    hide Response, FormData, MultipartFile;
import 'package:pharmo_app/authentication/auth_operations/complete_registration.dart';
import 'package:pharmo_app/authentication/auth_operations/reset_pass.dart';
import 'package:pharmo_app/authentication/auth_operations/select_branch_page.dart';

class AuthController extends ChangeNotifier {
  void initLoginpage({bool skip = false}) {
    if (skip) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final remembered = await Authenticator.getRemember();
      if (remembered) {
        setRemember(true);
        final idendAndPass = await Authenticator.readIdentifierAndPassword();
        final email = idendAndPass['identifier'];
        final pass = idendAndPass['password'];
        fillEmail(email ?? '');
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

  final TextEditingController ema = TextEditingController();
  void fillEmail(String email) {
    ema.text = email;
    notifyListeners();
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
    try {
      var body = {'email': ema.text, 'password': pass.text};
      var r = await apiPostWithoutToken(loginUrl, body);
      if (r == null) {
        messageError(
          'Серверт холбогдож чадсангүй, интернет холболтоо шалгана уу!',
        );
        setLogging(false);
        return;
      }
      Map<String, dynamic> decodedResponse = convertData(r);
      if (r.statusCode == 200) {
        _handleSuccessfulLogin(decodedResponse);
        setLogging(false);
      } else if (r.statusCode == 400) {
        _handleBadRequest(decodedResponse);
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
        await Authenticator.saveIdentifierAndPassword(ema.text, pass.text);
      }
      final sec = Authenticator.security;
      if (sec == null) return;
      await Authenticator.saveLoginHistory(ema.text, sec.name);
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
    await goto(const SelectBranchPage());
  }

  // Нэвтрэх амжилтгүй
  void _handleBadRequest(Map<String, dynamic> res) {
    if (checker(res, 'noCmp')) {
      goto(CompleteRegistration(ema: ema.text, pass: pass.text));
    }
    if (checker(res, 'no_password')) {
      Get.bottomSheet(CreatePassDialog(email: ema.text));
    } else if (checker(res, 'noLic') || checker(res, 'noLoc')) {
      messageWarning('Веб хуудсаар хандан бүртгэл гүйцээнэ үү!');
    } else if (checker(res, 'noRev')) {
      messageWarning('Бүртгэлийн мэдээллийг хянаж байна, түр хүлээнэ үү!');
    } else if (checker(res, 'password')) {
      messageWarning('${res['password']}');
    } else if (checker(res, 'email')) {
      messageWarning('Имейл хаяг бүртгэлгүй байна!');
    } else if (checker(res, 'password_blocked')) {
      goto(const ResetPassword());
    }
  }

  Future<void> logout(BuildContext context,
      {bool withoutRequest = false}) async {
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
      if (response!.statusCode == 200) {
        return buildResponse(1, null, 'Батлагаажуулах код илгээлээ.');
      } else if (response.statusCode == 400) {
        return buildResponse(2, null, 'И-Мейл эсвэл утас бүртгэлтэй байна!');
      } else {
        return buildResponse(3, null, 'Алдаа гарлаа!');
      }
    } catch (e) {
      buildResponse(3, null, 'Алдаа гарлаа!!');
    }
  }

  // Бүртгүүлэх
  Future register(
      {required String email,
      required String phone,
      required String otp,
      required String password}) async {
    try {
      var body = {
        'email': email,
        'phone': phone,
        'otp': otp,
        'password': password
      };
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

  Future<bool> resetPassOtp(String email) async {
    try {
      final response = await apiPostWithoutToken(
        'auth/get_otp/',
        {'email': email},
      );
      if (response == null) return false;
      if (response.statusCode == 200) {
        messageComplete('Батлагаажуулах код илгээлээ');
        return true;
      }
      print("body: ${convertData(response)}");
      messageWarning('И-Мейл хаяг бүртгэлтгүй байна');
      return false;
    } catch (e) {
      if (e is TimeoutException) {
        messageError('Интернет холболтоо шалгана уу!');
        return false;
      }
      messageError('Түр хүлээгээд дахин оролдоно уу!');
      return false;
    }
  }

  Future createPassword(
    String email,
    String otp,
    String newPassword,
    BuildContext context,
  ) async {
    try {
      final b = {'email': email, 'otp': otp, 'new_pwd': newPassword};
      final response = await apiPostWithoutToken('auth/reset/', b);
      if (response == null) return;
      if (response.statusCode == 200) {
        messageComplete('Нууц үг амжилттай үүслээ');
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        final data = convertData(response);
        if (data.toString().contains('Баталгаажуулах')) {
          messageWarning('Баталгаажуулах код буруу байна!');
        } else if (data.toString().contains('new_pwd')) {
          messageWarning('Нууц үг шаардлага хангахгүй байна!');
        } else {
          messageWarning(wait);
        }
      }
    } catch (e) {
      return messageError(wait);
    }
  }

  Future getDeviceInfo() async {
    final deviceManager = DeviceManager();
    final device = await deviceManager.deviceInfo();
    try {
      final data = {
        'token': device.firebaseToken,
        'platform': device.type,
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
        debugPrint('Device info not sent');
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
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$ema:$pass'))}';
      if (license.isEmpty) {
        message('Тусгай зөвшөөрөл оруулна уу!');
        return;
      }
      final licenseFiles = await Future.wait(
        license.map(
          (lic) => MultipartFile.fromFile(
            lic.path,
            contentType: pharser.MediaType('image', 'jpeg'),
          ),
        ),
      );
      final compressedLogo = await compressImage(logo!);

      final formData = FormData.fromMap({
        'license[]': licenseFiles,
        if (compressedLogo != null)
          'logo': await MultipartFile.fromFile(compressedLogo.path),
        'public_name': publicName,
        'email': ema,
        'password': pass,
        'name': name,
        'rd': rd,
        if (additional != null) 'note': additional,
        if (inviCode != null) 'referral_code': inviCode,
        'cType': (type == 'Эмийн сан') ? 'P' : 'S',
        'address2': jsonEncode({'lat': lat, 'lng': lng, 'address2': address})
            .toString(),
      });
      print(formData.fields);
      print(formData.files);
      final res = await ApiService.plainDio.post(
        ApiService.buildUrl('company/info/').toString(),
        data: formData,
        options: Options(headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        }),
      );
      final responseBody = convertData(res).toString();
      print(res.statusCode);
      print(responseBody);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return buildResponse(
            1, null, 'Мэдээлэл амжилттай хадгалагдлаа. Нэвтэрнэ үү!');
      } else {
        if (responseBody.contains('already exists')) {
          return buildResponse(
              2, null, 'И-Мейл, РД эсвэл нэр давхардаж байна!');
        } else {
          return buildResponse(3, null, 'Түх хүлээгээд дахин оролдоно уу!');
        }
      }
    } catch (e) {
      return buildResponse(3, null, 'Түх хүлээгээд дахин оролдоно уу!');
    }
  }
}
