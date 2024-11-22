// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/resetPass.dart';
import 'package:pharmo_app/views/delivery_man/main/jagger_home_page.dart';
import 'package:pharmo_app/views/pharmacy/main/pharma_home_page.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/auth/login_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/dialog_and_messages/create_pass_dialog.dart';

class AuthController extends ChangeNotifier {
  bool invisible = true;
  bool invisible2 = false;
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

  tokerRefresher() async {
    Timer.periodic(const Duration(minutes: 20), (timer) async {
      await refresh();
    });
  }

  Future<void> refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rtoken = prefs.getString("refresh_token");
    var response = await apiPost(
        'auth/refresh/',
        jsonEncode(<String, String>{
          'refresh': rtoken!,
        }));
    if (response.statusCode == 200) {
      String accessToken = json.decode(response.body)['access'];
      await prefs.setString('access_token', accessToken);
    }
  }

  apiPostWithoutToken() {}

  checkEmail(String email, BuildContext context) async {
    try {
      var response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reged/'),
        headers: header,
        body: jsonEncode(
          {'email': email},
        ),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final email = responseData['ema'];
        if (email == false) {
          message(
            message: 'Имейл хаяг бүртгэлгүй байна!',
            context: context,
          );
        }
      }
    } catch (e) {
      message(
        message: 'Интернет холболтоо шалгана уу!.',
        context: context,
      );
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      var responseLogin = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/login/'),
        headers: header,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('${jsonDecode(utf8.decode(responseLogin.bodyBytes))}');
      print(responseLogin.statusCode);
      if (responseLogin.statusCode == 200) {
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        final basketProvider =
            Provider.of<BasketProvider>(context, listen: false);
        final Map<String, dynamic> res = jsonDecode(responseLogin.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', res['access_token']);
        await prefs.setString('refresh_token', res['refresh_token']);
        String? accessToken = prefs.getString('access_token').toString();
        final decodedToken = JwtDecoder.decode(accessToken);
        homeProvider.getSuppliers();
        _userInfo = decodedToken;
        await prefs.setString('useremail', decodedToken['email']);
        await prefs.setInt('user_id', decodedToken['user_id']);
        await prefs.setString('userrole', decodedToken['role']);
        decodedToken['supplier'] != null
            ? await prefs.setInt('suppID', decodedToken['supplier'])
            : message(message: 'Нийлүүлэгч сонгоно уу!', context: context);
        Hive.box('auth').put('role', decodedToken['role']);
        await basketProvider.getBasket();
        await basketProvider.getBasketCount;
        Future.delayed(const Duration(milliseconds: 100), () {
          switch (decodedToken['role']) {
            case 'S':
              gotoRemoveUntil(const SellerHomePage(), context);
              break;
            case 'PA':
              gotoRemoveUntil(const PharmaHomePage(), context);
              break;
            case 'D':
              gotoRemoveUntil(const JaggerHomePage(), context);
            case 'A':
              message(message: 'Веб хуудсаар хандана уу', context: context);
            case 'B':
              message(message: 'Веб хуудсаар хандана уу', context: context);
            case 'P':
              message(message: 'Веб хуудсаар хандана уу', context: context);
            case 'PS':
              message(message: 'Веб хуудсаар хандана уу', context: context);
            case 'PM':
              message(message: 'Веб хуудсаар хандана уу', context: context);
          }
        }).then((e) => getDeviceInfo());
        debugPrint(accessToken);
        tokerRefresher();
        notifyListeners();
      } else if (responseLogin.statusCode == 400) {
        Map res = jsonDecode(utf8.decode(responseLogin.bodyBytes));
        if (checker(res, 'no_password', context) == true) {
          showDialog(
              context: context,
              builder: (context) {
                return CreatePassDialog(email: email);
              });
        } else if (checker(res, 'noCmp', context) == true) {
          message(
              message: 'Веб хуудсаар хандан бүртгэл гүйцээнэ үү!',
              context: context);
        } else if (checker(res, 'noLic', context) == true) {
          message(
              message: 'Веб хуудсаар хандан бүртгэл гүйцээнэ үү!',
              context: context);
        } else if (checker(res, 'noRev', context) == true) {
          message(
              message: 'Бүртгэлийн мэдээллийг хянаж байна, түр хүлээнэ үү!',
              context: context);
        } else if (checker(res, 'password', context) == true) {
          message(context: context, message: '${res['password']}');
        } else if (checker(res, 'noLoc', context) == true) {
          message(
              message: 'Веб хуудсаар хандан бүртгэл гүйцээнэ үү!',
              context: context);
        } else if (checker(res, 'email', context)) {
          message(context: context, message: 'Имейл хаяг бүртгэлгүй байна!');
        } else if (checker(res, 'password_blocked', context)) {
          goto(const ResetPassword());
        }
      } else if (responseLogin.statusCode == 401) {
        // goto(CreatePassword(email: email), context);
        await showDialog(
          context: context,
          builder: (context) {
            return CreatePassDialog(
              email: email,
            );
          },
        );
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
  }

  Future<void> logout(BuildContext context) async {
    try {
      final token = await getAccessToken();
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/logout/'),
        headers: getHeader(token),
      );
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('access_token');
        prefs.remove('refresh_token');
        HomeProvider().dispose();
        BasketProvider().dispose();
        PromotionProvider().dispose();
        JaggerProvider().dispose();
        BasketProvider().dispose();
        IncomeProvider().dispose();
        ProductProvider().dispose();
        PharmProvider().dispose();
        AuthController().dispose();
        MyOrderProvider().dispose();
        AddressProvider().dispose();
        Get.offAll(() => const LoginPage());
      } else {
        message(message: 'Холболт салсан.', context: context);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR LOGOUT ${e.toString()}');
    }
  }

  Future<void> signUpGetOtp(
      String email, String phone, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reg_otp/'),
        headers: header,
        body: jsonEncode(
          {
            'email': email,
            'phone': phone,
          },
        ),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        message(message: 'Батлагаажуулах код илгээлээ!', context: context);
        notifyListeners();
      }
    } catch (e) {
      message(message: 'Амжилтгүй!', context: context);
      notifyListeners();
    }
  }

  Map<String, String> get header {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  checker(Map response, String key, BuildContext context) {
    if (response.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> register(String email, String phone, String password, String otp,
      BuildContext context) async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}auth/register/'),
          headers: header,
          body: jsonEncode({
            'email': email,
            'phone': phone,
            'password': password,
            'otp': otp
          }));
      notifyListeners();
      if (response.statusCode == 200) {
        gotoRemoveUntil(const LoginPage(), context);
        message(message: 'Бүртгэл амжилттай үүслээ', context: context);
        notifyListeners();
      }
      if (response.statusCode == 500) {
        message(message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
        notifyListeners();
      }
    } catch (e) {
      message(message: 'Амжилтгүй!', context: context);
    }
    notifyListeners();
  }

  Future resetPassOtp(
      {required String email, required BuildContext context}) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/get_otp/'),
        headers: header,
        body: jsonEncode({
          'email': email,
        }),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        message(context: context, message: 'Батлагаажуулах код илгээлээ');
        notifyListeners();
        return true;
      } else {
        message(message: 'Амжилтгүй!', context: context);
        notifyListeners();
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
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reset/'),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}device_id/'),
        headers: getHeader(bearerToken),
        body: jsonEncode({"deviceId": deviceToken}));
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
    final bearerToken = await getAccessToken();
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
      final response =
          await http.post(Uri.parse('${dotenv.env['SERVER_URL']}device_id/'),
              headers: getHeader(bearerToken),
              body: jsonEncode({
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
