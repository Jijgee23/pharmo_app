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
import 'package:pharmo_app/controllers/product_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/person.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/views/auth/reset_pass.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/pharmacy/index_pharmacy.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/dialog_and_messages/create_pass_dialog.dart';

class AuthController extends ChangeNotifier {
  bool invisible = true;
  bool invisible2 = false;
  bool loading = false;
  late Map<String, dynamic> _userInfo;
  Map<String, dynamic> get userInfo => _userInfo;
  Map<String, String> deviceData = {};
  late Person person;
  setPerson(Person p) {
    person = p;
    notifyListeners();
  }

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
    http.Response response = await http.post(
      setUrl(endPoint),
      headers: header,
      body: jsonEncode(body),
    );
    getApiInformation(endPoint, response);
    return response;
  }

  Map<String, String> get header {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  checker(Map response, String key) {
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
        _handleBadRequest(decodedResponse, email, context);
      } else if (responseLogin.statusCode == 401) {
        await showDialog(
            context: context,
            builder: (context) {
              return CreatePassDialog(email: email);
            });
      } else {
        {
          message(
              message: 'Имейл эсвэл нууц үг буруу байна!', context: context);
        }
      }
      notifyListeners();
    } catch (e) {
      message(message: 'Интернет холболтоо шалгана уу!', context: context);
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
    
    await homeProvider.getSuppliers();

    if (decodedToken['supplier'] != null) {
      await prefs.setInt('suppID', decodedToken['supplier']);
    } else {
      message(message: 'Нийлүүлэгч сонгоно уу!', context: context);
    }

    Hive.box('auth').put('role', decodedToken['role']);
    await basketProvider.getBasket();
    await basketProvider.getBasketCount;
    _navigateBasedOnRole(decodedToken['role'], context);
    debugPrint(accessToken);
    tokerRefresher();
    notifyListeners();
  }

  // Нэвтрэх амжилтгүй
  void _handleBadRequest(
      Map<String, dynamic> res, String email, BuildContext context) {
    if (checker(res, 'no_password')) {
      showDialog(
          context: context,
          builder: (context) => CreatePassDialog(email: email));
    } else if (checker(res, 'noCmp') ||
        checker(res, 'noLic') ||
        checker(res, 'noLoc')) {
      message(
          message: 'Веб хуудсаар хандан бүртгэл гүйцээнэ үү!',
          context: context);
    } else if (checker(res, 'noRev')) {
      message(
          message: 'Бүртгэлийн мэдээллийг хянаж байна, түр хүлээнэ үү!',
          context: context);
    } else if (checker(res, 'password')) {
      message(context: context, message: '${res['password']}');
    } else if (checker(res, 'email')) {
      message(context: context, message: 'Имейл хаяг бүртгэлгүй байна!');
    } else if (checker(res, 'password_blocked')) {
      goto(const ResetPassword());
    }
  }

  // Хэрэглэгчийн эрхээс хамаарч дэлгэц харуулах
  void _navigateBasedOnRole(String role, BuildContext context) {
    gotoRemoveUntil(const IndexPharma(), context);
    switch (role) {
      case 'S':
        gotoRemoveUntil(const IndexPharma(), context);
        break;
      case 'PA':
        gotoRemoveUntil(const IndexPharma(), context);
        break;
      case 'D':
        gotoRemoveUntil(const IndexDeliveryMan(), context);
        break;
      default:
        message(message: 'Веб хуудсаар хандана уу', context: context);
    }
    getDeviceInfo();
  }

  //Токен шинэчлэх
  Future<void> refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rtoken = prefs.getString("refresh_token");
    Object body = jsonEncode({'refresh': rtoken!});
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
  Future<void> logout(BuildContext context) async {
    try {
      final response = await http.post(
        setUrl('auth/logout/'),
        headers: getHeader(await getAccessToken()),
      );
      if (response.statusCode == 200) {
        await _completeLogout();
        Get.offAll(() => const LoginPage());
      } else {
        await _completeLogout();
        message(message: 'Холболт саллаа.', context: context);
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
  }

  Future<void> _disposeProviders() async {
    try {
      HomeProvider().dispose();
      BasketProvider().dispose();
      PromotionProvider().dispose();
      JaggerProvider().dispose();
      IncomeProvider().dispose();
      ProductProvider().dispose();
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
        return {
          'v': 1,
        };
      } else if (response.statusCode == 400) {
        return {'v': 3};
      } else {
        return {'v': 2};
      }
    } catch (e) {
      return {'v': 2};
    }
  }

  // Бүртгүүлэх
  register(String email, String phone, String otp, String password) async {
    try {
      var body = jsonEncode(
        {'email': email, 'phone': phone, 'otp': otp, 'password': password},
      );
      final response = await apiPostWithoutToken('auth/register/', body);
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'v': 1};
      } else if (response.statusCode == 500) {
        return {'v': 2};
      } else if (response.statusCode == 400) {
        if (checker(data, 'otp') == true) {
          return {'v': 3};
        } else {
          return {'v': 0};
        }
      }
    } catch (e) {
      return {'v': 0};
    }
  }

  Future resetPassOtp(
      {required String email, required BuildContext context}) async {
    try {
      final response = await http.post(setUrl('auth/get_otp/'),
          headers: header, body: jsonEncode({'email': email}));
      notifyListeners();
      if (response.statusCode == 200) {
        message(context: context, message: 'Батлагаажуулах код илгээлээ');
        return true;
      } else {
        message(message: 'Амжилтгүй!', context: context);
        return false;
      }
    } catch (e) {
      message(context: context, message: 'Амжилтгүй!');
      return false;
    }
  }

  Future<void> createPassword(
      {required String email,
      required String otp,
      required String newPassword,
      required BuildContext context}) async {
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
        message(message: 'Нууц үг амжилттай үүслээ', context: context);
        goto(const LoginPage());
        notifyListeners();
      }
    } catch (e) {
      message(message: 'Амжилтгүй!', context: context);
    }
    notifyListeners();
  }

  String firebaseToken = '';
  getFireBaseToken(String newValue) {
    firebaseToken = newValue;
    notifyListeners();
  }

  getDeviceToken() async {
    String? deviceToken = '';
    FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
    if (Platform.isAndroid) {
      deviceToken = await firebaseMessage.getToken();
    } else {
      deviceToken = await firebaseMessage.getAPNSToken();
    }
    getFireBaseToken(deviceToken!);
    return deviceToken;
  }

  init(BuildContext context) async {
    String deviceToken = await getDeviceToken();
    final response = await http.post(setUrl('device_id/'),
        headers: header, body: jsonEncode({"deviceId": deviceToken}));
    // apiPost('device_id/', jsonEncode({"deviceId": deviceToken}));
    if (response.statusCode == 200) {}
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      String? title = remoteMessage.notification!.title;
      String? description = remoteMessage.notification!.body;
      Alert(
        context: context,
        type: AlertType.info,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Хаах",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          )
        ],
      ).show();
    });
  }

  Future<Map<String, String>> getDeviceInfo() async {
    await getDeviceToken();
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceData = {};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          "deviceId": firebaseToken,
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
          "deviceId": firebaseToken,
          "platform": "ios",
          "brand": "Apple",
          "model": iosInfo.name,
          "modelVersion": iosInfo.utsname.machine,
          "os": "iOS",
          "osVersion": iosInfo.systemVersion,
        };
      }
      final response = await apiPost(
          'device_id/',
          jsonEncode({
            'deviceId': deviceData['deviceId'],
            'platform': deviceData['platform'],
            'brand': deviceData['brand'],
            'model': deviceData['model'],
            'modelVersion': deviceData['modelVersion'],
            'os': deviceData['os'],
            'osVersion': deviceData['osVersion'],
          }));
      if (response.statusCode == 200) {
        debugPrint('Device info sent');
      } else {
        debugPrint('Device info not sent');
      }
      return deviceData;
    } catch (e) {
      debugPrint('$e');
    }
    return deviceData;
  }
}
