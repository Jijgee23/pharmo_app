import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:http_parser/http_parser.dart' as pharser;
import 'package:pharmo_app/application/application.dart';

class AuthController extends ChangeNotifier {
  void initLoginpage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final remembered = await LocalBase.getRemember();
      if (remembered) {
        setRemember(true);
        final idendAndPass = await LocalBase.readIdentifierAndPassword();
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
      var responseLogin = await apiPostWithoutToken(loginUrl, body);
      Map<String, dynamic> decodedResponse = convertData(responseLogin!);
      if (responseLogin.statusCode == 200) {
        _handleSuccessfulLogin(decodedResponse);
        setLogging(false);
      } else if (responseLogin.statusCode == 400) {
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
      if (decodedToken['role'] == 'A') {
        messageWarning('Веб хуудсаар хандана уу!');
        return;
      }
      await LocalBase.clearSecurity();
      await LocalBase.saveModel(res);
      await LocalBase.initLocalBase();
      await getDeviceInfo();
      await LocalBase.saveLastLoggedIn(true);
      await LogService().createLog('Нэвтрэх', LogService.login);
      if (remember) {
        await LocalBase.saveRemember();
        await LocalBase.saveIdentifierAndPassword(ema.text, pass.text);
      }
      final sec = LocalBase.security;
      if (sec == null) return;
      setLogging(false);
      await gotoRootPage();
      //  goNamedOfAll('root');
    } catch (e) {
      print(e);
    }
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
      if (!withoutRequest) {
        await LogService().createLog('Системээс гарах', LogService.logout);
        await api(Api.post, logoutUrl);
      }
      await LocalBase.removeTokens();
      await LocalBase.clearSecurity();
      await LocalBase.saveLastLoggedIn(false);
      context.read<HomeProvider>().reset();
      context.read<BasketProvider>().reset();
      context.read<DriverProvider>().reset();
      context.read<JaggerProvider>().reset();
      context.read<LogProvider>().reset();
      context.read<MyOrderProvider>().reset();
      context.read<PharmProvider>().reset();
      context.read<PromotionProvider>().reset();
      context.read<ReportProvider>().reset();
      await goNamedOfAll('login');
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
      final data = jsonDecode(utf8.decode(response!.bodyBytes));
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
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceData = {};
    String token = await FirebaseApi.getToken();
    if (token != '') {
      await LocalBase.saveDeviceToken(token);
    }
    debugPrint("device token: $token");
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          "deviceId": token,
          "platform": 'android',
          "brand": androidInfo.brand,
          "model": androidInfo.model,
          "modelVersion": androidInfo.device,
          "os": Platform.operatingSystem,
          "osVersion": Platform.operatingSystemVersion,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          "deviceId": token,
          "platform": "ios",
          "brand": "Apple",
          "model": iosInfo.name,
          "modelVersion": iosInfo.utsname.machine,
          "os": "iOS",
          "osVersion": iosInfo.systemVersion,
        };
      }
      final data = {
        'token': deviceData['deviceId'],
        'platform': deviceData['platform'],
        'brand': deviceData['brand'],
        'model': deviceData['model'],
        'modelVersion': deviceData['modelVersion'],
        'os': deviceData['os'],
        'osVersion': deviceData['osVersion']
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
      var request = http.MultipartRequest('POST', setUrl('company/info/'));

      String basicAuth = 'Basic ${base64Encode(utf8.encode('$ema:$pass'))}';
      if (license.isEmpty) {
        message('Тусгай зөвшөөрөл оруулна уу!');
        return;
      }
      List<http.MultipartFile> files = [];
      for (File lic in license) {
        final file = await http.MultipartFile.fromPath('license[]', lic.path,
            contentType: pharser.MediaType('image', 'jpeg'));
        files.add(file);
      }
      request.files.addAll(files);
      request.headers['Authorization'] = basicAuth;
      request.headers['Accept'] = 'application/json';
      final compressedLogo = await compressImage(logo!);
      compressedLogo != null
          ? request.files.add(
              await http.MultipartFile.fromPath('logo', compressedLogo.path))
          : null;
      request.fields['public_name'] = publicName;
      request.fields['email'] = ema;
      request.fields['password'] = pass;
      request.fields['name'] = name;
      request.fields['rd'] = rd;
      additional != null ? request.fields['note'] = additional : null;
      inviCode != null ? request.fields['referral_code'] = inviCode : null;
      request.fields['cType'] = (type == 'Эмийн сан') ? 'P' : 'S';
      request.fields['address2'] =
          jsonEncode({'lat': lat, 'lng': lng, 'address2': address}).toString();
      print(request.fields);
      print(request.files);
      var res = await request.send();
      String responseBody = await res.stream.bytesToString();
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
