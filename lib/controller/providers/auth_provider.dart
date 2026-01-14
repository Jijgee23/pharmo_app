import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/app_configs.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/application/services/log_service.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/login/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';
import 'package:http_parser/http_parser.dart' as pharser;

class AuthController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  void initLoginpage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final security = LocalBase.security;
      if (security == null) return;
      final remembered = await LocalBase.getRemember();
      if (remembered) {
        setRemember(true);
        fillEmail(security.email);
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

  final TextEditingController pass = TextEditingController();

  Future<http.Response?> apiPostWithoutToken(
      String endPoint, Object? body) async {
    try {
      final connected = await isOnline();
      if (connected) {
        var response = await http
            .post(
              setUrl(endPoint),
              headers: header,
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: 5));
        return response;
      }
      messageWarning('Интернет холболтоо шалгана уу!');
    } catch (e) {
      if (e is TimeoutException) {
        messageError('Түр хүлээнэ үү!');
        return null;
      }
    }
    return null;
  }

  Map<String, String> get header {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Pharmo-Client': '!pharmo_app?',
    };
  }

  bool checker(Map response, String key) {
    if (response.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  // Нэвтрэх
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      ToastService.show('Нэвтрэх нэр, нууц үг оруулна уу');
      return;
    }
    setLogging(true);
    try {
      var body = {'email': ema.text, 'password': pass.text};
      var responseLogin = await apiPostWithoutToken('auth/login/', body);
      Map<String, dynamic> decodedResponse = convertData(responseLogin!);
      if (responseLogin.statusCode == 200) {
        _handleSuccessfulLogin(decodedResponse);
      } else if (responseLogin.statusCode == 400) {
        _handleBadRequest(decodedResponse);
      } else {
        messageWarning('Алдаа гарлаа, Инфосистемс-ХХК-д хандана уу!');
      }
      notifyListeners();
    } catch (e) {
      messageError(wait);
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
      await LocalBase.clearLocalBase();
      await LocalBase.saveModel(res);
      await LocalBase.initLocalBase();
      await getDeviceInfo();
      await LocalBase.saveLastLoggedIn(true);
      await LogService().createLog('login', LogService.login);
      await LocalBase.saveRemember();
      final sec = LocalBase.security;
      if (sec == null) return;
      setLogging(false);
      await goNamedOfAll('root');
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

  Future<void> logout(BuildContext context) async {
    final security = LocalBase.security;
    if (security != null && security.role != 'PA') {
      if (security.role == 'D') {
        int delmanTrackId = await LocalBase.getDelmanTrackId();
        if (delmanTrackId != 0) {
          bool confirmed = await confirmDialog(
            context: context,
            title:
                'Дуусгаагүй түгээлтийн байршид дамжуулалт зогсоогоод системээс гарах уу?',
          );
          if (confirmed) {
            context.read<JaggerProvider>().stopTracking();
          }
          return;
        }
      }
      // if (security.role == "S") {
      //   bool hasTrack = await LocalBase.hasSellerTrack();
      // }
    }
    try {
      await LogService().createLog('logout', LogService.logout);
      final response = await http.post(
        setUrl('auth/logout/'),
        headers: getHeader(LocalBase.security!.access),
      );
      if (response.statusCode == 200) {
        await _completeLogout(context);
      } else {
        await _completeLogout(context);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR LOGOUT ${e.toString()}');
    }
  }

  Future<void> _completeLogout(BuildContext context) async {
    await LocalBase.removeTokens();
    await LocalBase.saveLastLoggedIn(false);
    await _disposeProviders(context);
    gotoRemoveUntil(LoginPage());
  }

  Future<void> _disposeProviders(BuildContext context) async {
    try {
      Provider.of<BasketProvider>(context, listen: false).reset();
      Provider.of<HomeProvider>(context, listen: false).reset();
      Provider.of<JaggerProvider>(context, listen: false).reset();
      debugPrint('Providers disposed');
    } catch (e) {
      debugPrint('Error disposing providers: ${e.toString()}');
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
      final response = await apiPostWithoutToken('auth/register/', body);
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
      final response = await http.post(setUrl('auth/get_otp/'),
          headers: header, body: jsonEncode({'email': email}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        messageComplete('Батлагаажуулах код илгээлээ');
        return true;
      } else {
        messageWarning('И-Мейл хаяг бүртгэлтгүй байна');
        return false;
      }
    } catch (e) {
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
      final response = await http.post(setUrl('auth/reset/'),
          headers: header,
          body:
              jsonEncode({'email': email, 'otp': otp, 'new_pwd': newPassword}));
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
      final response = await api(Api.post, 'device_token/', body: data);
      if (response!.statusCode == 200) {
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
