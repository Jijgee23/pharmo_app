// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/controllers/address_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/complete_registration.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  bool invisible = true;
  bool invisible2 = false;
  bool loading = false;
  late Map<String, dynamic> _userInfo;
  Map<String, dynamic> get userInfo => _userInfo;
  Map<String, String> deviceData = {};

  void toggleVisibile() {
    invisible = !invisible;
    notifyListeners();
  }

  void toggleVisibile2() {
    invisible2 = !invisible2;
    notifyListeners();
  }

  void setLogging(bool n) {
    loading = n;
    notifyListeners();
  }

  apiPostWithoutToken(String endPoint, Object? body) async {
    http.Response response = await http.post(setUrl(endPoint),
        headers: header, body: jsonEncode(body));
    getApiInformation(endPoint, response);
    return response;
  }

  Map<String, String> get header {
    return {'Content-Type': 'application/json; charset=UTF-8'};
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
      var responseLogin = await apiPostWithoutToken(
        'auth/login/',
        {'email': email, 'password': password},
      );
      final decodedResponse = convertData(responseLogin);
      if (responseLogin.statusCode == 200) {
        _handleSuccessfulLogin(decodedResponse, context);
      } else if (responseLogin.statusCode == 400) {
        _handleBadRequest(decodedResponse, email, password);
      } else if (responseLogin.statusCode == 401) {
      } else {
        {
          message('Имейл эсвэл нууц үг буруу байна!');
        }
      }
      notifyListeners();
    } catch (e) {
      message('Интернет холболтоо шалгана уу!');
      debugPrint('error================= on login> ${e.toString()} ');
    }
    setLogging(false);
  }

  // Нэвтрэх амжилттай
  Future<void> _handleSuccessfulLogin(
      Map<String, dynamic> res, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', res['access_token']);
    await prefs.setString('refresh_token', res['refresh_token']);

    final accessToken = prefs.getString('access_token')!;
    final decodedToken = JwtDecoder.decode(accessToken);

    _userInfo = decodedToken;

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);

    await prefs.setString('useremail', decodedToken['email']);
    await prefs.setInt('user_id', decodedToken['user_id']);
    await prefs.setString('userrole', decodedToken['role']);

    final home = Provider.of<HomeProvider>(context, listen: false);
    await home.getUserInfo();
    print('HOME USER: ${home.userRole}');

    if (home.userRole == 'PA') {
      await homeProvider.getSuppliers();
      await homeProvider.getBranches();
      if (decodedToken['supplier'] != null) {
        await prefs.setInt('suppID', decodedToken['supplier']);
        int? k = prefs.getInt('suppID');
        home.getSuppliers();
        if (k != null) {
          home.pickSupplier(int.parse(home.supList[0].id), context);
          home.changeSupName(home.supList[0].name);
          home.setSupId(k);
        }

        // HomeProvider().getSuppliers();
        // HomeProvider()
        //     .pickSupplier(int.parse(HomeProvider().supList[0].id), context);
      } else {
        message('Нийлүүлэгч сонгоно уу!');
      }
    }

    Hive.box('auth').put('role', decodedToken['role']);
    await basketProvider.getBasket();
    await basketProvider.getBasketCount;
    _navigateBasedOnRole(decodedToken['role']);
    debugPrint(accessToken);
    tokerRefresher();
    notifyListeners();
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
    // await getDeviceToken();

    gotoRemoveUntil(const IndexPharma());
    switch (role) {
      case 'S':
        gotoRemoveUntil(const IndexPharma());
        break;
      case 'PA':
        gotoRemoveUntil(const IndexPharma());
        break;
      case 'D':
        gotoRemoveUntil(const IndexDeliveryMan());
        break;
      // case 'A':
      //   gotoRemoveUntil(const AdminIndex());
      //   break;
      default:
        message('Веб хуудсаар хандана уу');
    }
    await getDeviceInfo();
  }

  //Токен шинэчлэх
  Future<void> refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rtoken = prefs.getString("refresh_token");
    Object body = {'refresh': rtoken!};
    var response = await apiPost('auth/refresh/', body);
    if (response.statusCode == 200) {
      String accessToken = json.decode(response.body)['access'];
      await prefs.setString('access_token', accessToken);
      notifyListeners();
    }
  }

  tokerRefresher() async {
    Timer.periodic(const Duration(minutes: 20), (timer) async {
      await refresh();
    });
  }

  // Системээс гарах
  Future<void> logout() async {
    try {
      final response = await http.post(
        setUrl('auth/logout/'),
        headers: getHeader(await getAccessToken()),
      );
      if (response.statusCode == 200) {
        await _completeLogout();
      } else {
        await _completeLogout();
        // message('Холболт саллаа.');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR LOGOUT ${e.toString()}');
    }
  }

  _completeLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    await _disposeProviders();
    Get.offAll(() => const LoginPage());
  }

  Future<void> _disposeProviders() async {
    try {
      HomeProvider().dispose();
      BasketProvider().dispose();
      PromotionProvider().dispose();
      JaggerProvider().dispose();
      IncomeProvider().dispose();
      PharmProvider().dispose();
      AuthController().dispose();
      MyOrderProvider().dispose();
      AddressProvider().dispose();
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
      if (response.statusCode == 200) {
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
      http.Response response =
          await apiPostWithoutToken('auth/register/', body);
      final data = jsonDecode(utf8.decode(response.bodyBytes));
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

  createPassword(
      {required String email,
      required String otp,
      required String newPassword}) async {
    try {
      final response = await http.post(
        setUrl('auth/reset/'),
        headers: header,
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_pwd': newPassword,
        }),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        return buildResponse(1, '', 'Нууц үг амжилттай үүслээ');
      } else {
        return buildResponse(2, '', 'Түр хэлээгээд дахин оролдоно уу!');
      }
    } catch (e) {
      return buildResponse(2, '', 'Түр хэлээгээд дахин оролдоно уу!');
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
        'deviceId': deviceData['deviceId'],
        'platform': deviceData['platform'],
        'brand': deviceData['brand'],
        'model': deviceData['model'],
        'modelVersion': deviceData['modelVersion'],
        'os': deviceData['os'],
        'osVersion': deviceData['osVersion']
      };
      print(data['deviceId']);

      http.Response response = await apiPost('device_id/', data);
      if (response.statusCode == 200) {
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
      required String rd,
      required String type,
      String? additional,
      String? inviCode,
      String? address,
      required File license,
      File? logo,
      required double? lat,
      required double? lng}) async {
    print(lat);
    try {
      var request = http.MultipartRequest('POST', setUrl('company/'));
      request.files
          .add(await http.MultipartFile.fromPath('license', license.path));
      logo != null
          ? request.files
              .add(await http.MultipartFile.fromPath('logo', logo.path))
          : null;
      request.fields['email'] = ema;
      request.fields['password'] = pass;
      request.fields['name'] = name;
      request.fields['rd'] = rd;
      additional != null ? request.fields['note'] = additional : null;
      inviCode != null ? request.fields['referral_code'] = inviCode : null;
      request.fields['cType'] = (type == 'Эмийн сан') ? 'P' : 'S';
      request.fields['address2'] =
          jsonEncode({'lat': lat, 'lng': lng, 'address2': address}).toString();
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
