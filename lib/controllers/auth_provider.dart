import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/auth/root_page.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/main/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/main/rep_man/index.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart' as pharser;

class AuthController extends ChangeNotifier {
  bool loading = false;
  bool remember = false;

  setRemember(bool n) {
    remember = n;
    notifyListeners();
  }

  void setLogging(bool n) {
    loading = n;
    notifyListeners();
  }

  Future<http.Response?> apiPostWithoutToken(
      String endPoint, Object? body) async {
    http.Response? result;
    if (await isOnline()) {
      var response = await http.post(
        setUrl(endPoint),
        headers: header,
        body: jsonEncode(body),
      );
      result = response;
    } else {
      message('Интернет холболтоо шалгана уу!');
    }
    return result;
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
  Future<void> login(
      String email, String password, BuildContext context) async {
    setLogging(true);
    try {
      var body = {
        'email': email,
        'password': password,
      };
      var responseLogin = await apiPostWithoutToken('auth/login/', body);
      Map<String, dynamic> decodedResponse = convertData(responseLogin!);
      // print(decodedResponse);
      if (responseLogin.statusCode == 200) {
        // debugPrint(decodedResponse);
        _handleSuccessfulLogin(decodedResponse, context);
      } else if (responseLogin.statusCode == 400) {
        setLogging(false);
        _handleBadRequest(decodedResponse, email, password);
      } else if (responseLogin.statusCode == 401) {
        setLogging(false);
      } else {
        setLogging(false);
        message('Имейл эсвэл нууц үг буруу байна!');
      }
      notifyListeners();
    } catch (e) {
      message('Интернет холболтоо шалгана уу!');
      debugPrint('error================= on login> ${e.toString()} ');
    } finally {
      setLogging(false);
    }
  }

  // Нэвтрэх амжилттай
  Future<void> _handleSuccessfulLogin(
      Map<String, dynamic> res, BuildContext context) async {
    await LocalBase.saveModel(res);

    if (remember) await LocalBase.saveRemember();

    gotoRemoveUntil(RootPage());

    // _userInfo = decodedToken;
    // if (remember) {
    //   Userservice.saveUserData(decodedToken, password);
    // }

    // final homeProvider = context.read<HomeProvider>();
    // final basketProvider = context.read<BasketProvider>();

    // await prefs.setString('useremail', decodedToken['email']);
    // await prefs.setInt('user_id', decodedToken['user_id']);
    // await prefs.setString('userrole', decodedToken['role']);
    // final home = Provider.of<HomeProvider>(context, listen: false);
    // await home.getUserInfo();
    // setAccountInfo(Account.fromJson(decodedToken));
    // if (home.userRole == 'PA') {
    //   if (decodedToken['stock_id'] != null) {
    //     await prefs.setInt('stock_id', decodedToken['stock_id']);
    //   }
    //   await homeProvider.getSuppliers();
    //   await homeProvider.getBranches();
    //   if (decodedToken['supplier_id'] != null) {
    //     await prefs.setInt('suppID', decodedToken['supplier_id']);
    //     int? k = prefs.getInt('suppID');
    //     home.getSuppliers();
    //     Supplier sup = home.supliers.firstWhere((e) => e.id == k);
    //     home.setSupplier(sup);
    //   } else {
    //     await home.getSuppliers();
    //     Supplier sup = home.supliers[0];
    //     print(sup.name);
    //     home.pickSupplier(sup, sup.stocks[0], context);
    //     home.setSupplier(sup);
    //   }
    // } else {
    //   await prefs.setString('company_name', decodedToken['company_name']);
    // }
    // await basketProvider.getBasket();
    // await basketProvider.getBasketCount;
    // _navigateBasedOnRole(_account.role);
    // debugPrint(accessToken);
    // notifyListeners();
  }

  // Нэвтрэх амжилтгүй
  void _handleBadRequest(Map<String, dynamic> res, String email, String pass) {
    if (checker(res, 'noCmp')) {
      goto(CompleteRegistration(
        ema: email,
        pass: pass,
      ));
    }
    if (checker(res, 'no_password')) {
      Get.bottomSheet(CreatePassDialog(email: email));
    } else if (checker(res, 'noLic') || checker(res, 'noLoc')) {
      message('Веб хуудсаар хандан бүртгэл гүйцээнэ үү!');
    } else if (checker(res, 'noRev')) {
      message('Бүртгэлийн мэдээллийг хянаж байна, түр хүлээнэ үү!');
    } else if (checker(res, 'password')) {
      message('${res['password']}');
    } else if (checker(res, 'email')) {
      message('Имейл хаяг бүртгэлгүй байна!');
    } else if (checker(res, 'password_blocked')) {
      goto(const ResetPassword());
    }
  }

  // Хэрэглэгчийн эрхээс хамаарч дэлгэц харуулах
  void _navigateBasedOnRole(String role) async {
    switch (role) {
      case 'S':
        gotoRemoveUntil(const IndexPharma());
        break;
      case 'PA':
        gotoRemoveUntil(const IndexPharma());
        break;
      case 'D':
        gotoRemoveUntil(const IndexDeliveryMan());
      case 'R':
        gotoRemoveUntil(IndexRep());
        break;
      default:
        message('Веб хуудсаар хандана уу');
    }
    await getDeviceInfo();
  }

  // Токен шинэчлэх
  Future<void> refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rtoken = prefs.getString("refresh_token");
    var body = {'refresh': rtoken!};
    var response = await api(Api.post, 'auth/refresh/', body: body);
    if (response!.statusCode == 200) {
      String accessToken = json.decode(response.body)['access'];
      await prefs.setString('access_token', accessToken);
      notifyListeners();
    }
  }

  // Системээс гарах
  Future<void> logout(BuildContext context) async {
    try {
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

  _completeLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    await _disposeProviders(context);
    Get.offAll(() => const LoginPage());
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
  signUpGetOtp(String email, String phone) async {
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
  register(
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

  resetPassOtp(String email) async {
    try {
      final response = await http.post(setUrl('auth/get_otp/'),
          headers: header, body: jsonEncode({'email': email}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        return buildResponse(1, null, 'Батлагаажуулах код илгээлээ');
      } else {
        return buildResponse(2, null, 'И-Мейл хаяг бүртгэлтгүй байна');
      }
    } catch (e) {
      return buildResponse(3, null, 'Түр хүлээгээд дахин оролдоно уу!');
    }
  }

  createPassword(String email, String otp, String newPassword,
      BuildContext context) async {
    try {
      final response = await http.post(setUrl('auth/reset/'),
          headers: header,
          body:
              jsonEncode({'email': email, 'otp': otp, 'new_pwd': newPassword}));
      if (response.statusCode == 200) {
        message('Нууц үг амжилттай үүслээ');
        Navigator.pop(context);
      } else {
        final data = convertData(response);
        if (data.toString().contains('Баталгаажуулах')) {
          message('Баталгаажуулах код буруу байна!');
        } else if (data.toString().contains('new_pwd')) {
          message('Нууц үг шаардлага хангахгүй байна!');
        } else {
          message(wait);
        }
      }
    } catch (e) {
      return message(wait);
    }
  }

  Future getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceData = {};
    String token = await getToken();
    print('DEVICE TOKEN =====> $token');
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
      http.Response? response =
          await api(Api.post, 'device_token/', body: data);
      if (response!.statusCode == 200) {
        debugPrint('Device info sent');
      } else {
        debugPrint('Device info not sent');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future getToken() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

        if (iosInfo.isPhysicalDevice == false) {
          return 'SIMULATOR';
        } else {
          await FirebaseMessaging.instance.getAPNSToken();
          await Future.delayed(const Duration(seconds: 2));
          return await FirebaseMessaging.instance.getToken() ?? '';
        }
      } else {
        return await FirebaseMessaging.instance.getToken() ?? '';
      }
    } catch (e) {
      debugPrint(e.toString());
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

  ShorebirdUpdater updater = ShorebirdUpdater();

  final currentTrack = UpdateTrack.stable;
  bool checking = false;
  Patch? currentPatch;
  setChecking(bool n) {
    checking = n;
    notifyListeners();
  }

  Future<void> checkForUpdate() async {
    setChecking(true);
    try {
      final status = await updater.checkForUpdate(track: currentTrack);
      if (status == UpdateStatus.unavailable) {
        debugPrint('Шинэчлэлт байхгүй');
        return;
      }
      if (status == UpdateStatus.upToDate) {
        debugPrint('Шинэчлэлт шаардлагагүй');
        return;
      }

      if (status == UpdateStatus.outdated) {
        debugPrint('Шинэчлэлт татагдаж байна');
        await updater.update(track: currentTrack).whenComplete(() async {
          await restartBanner();
        });
      }
      if (status == UpdateStatus.restartRequired) {
        debugPrint('Дахин ачаалуулах');
        await restartBanner();
      }
    } catch (error) {
      debugPrint('Error checking for update: $error');
    } finally {
      setChecking(false);
    }
  }

  Future<void> getUpdateMessage() async {
    final status = await updater.checkForUpdate(track: currentTrack);
    if (status == UpdateStatus.unavailable) {
      message('Шинэчлэлт байхгүй');
      return;
    }
    if (status == UpdateStatus.upToDate) {
      message('Шинэчлэлт шаардлагагүй');
      return;
    }

    if (status == UpdateStatus.outdated) {
      message('Шинэчлэлт татагдаж байна');
      await updater.update(track: currentTrack).whenComplete(() async {
        await restartBanner();
      });
    }
    if (status == UpdateStatus.restartRequired) {
      message('Дахин ачаалуулах шаардлагатай');
      await restartBanner();
    }
  }

  Future<void> restartBanner() async {
    return Get.dialog(
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
                    ontap: () {
                      Restart.restartApp(
                        notificationTitle: 'Шинэчлэлт татагдлаа',
                        notificationBody: 'Энд дарж нээнэ үү!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
