// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/jagger_home_page.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/screens/auth/login_page.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<Map<String, String>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceData = {};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          "deviceId": androidInfo.id,
          "platform": "Android",
          "brand": androidInfo.brand,
          "model": androidInfo.model,
          "modelVersion": androidInfo.device,
          "os": "Android",
          "osVersion": androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          "deviceId": iosInfo.identifierForVendor ?? "unknown",
          "platform": "iOS",
          "brand": "Apple",
          "model": iosInfo.name,
          "modelVersion": iosInfo.utsname.machine,
          "os": "iOS",
          "osVersion": iosInfo.systemVersion,
        };
      }
      return deviceData;
    } catch (e) {
      debugPrint(e.toString());
    }
    return deviceData;
  }

  Future<void> refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rtoken = prefs.getString("refresh_token");
    var response = await http.post(
      Uri.parse('${dotenv.env['SERVER_URL']}auth/refresh/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': rtoken!,
      },
      body: jsonEncode(<String, String>{
        'refresh': rtoken,
      }),
    );
    if (response.statusCode == 200) {
      String? accessToken = json.decode(response.body)['access'];
      await prefs.setString('access_token', accessToken!);
    }
  }

  Future<bool> checkEmail(String email, BuildContext context) async {
    try {
      var response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reged/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {'email': email},
        ),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final isPasswordCreated = responseData['pwd'];
        final email = responseData['ema'];
        if (email == false) {
          showFailedMessage(
            message: 'Имейл хаяг бүртгэлгүй байна!',
            context: context,
          );
          return false;
        } else {
          if (email == emailController.text && isPasswordCreated) {
            notifyListeners();
            return Future.value(true);
          } else {
            if (!isPasswordCreated && email == emailController.text) {
              await showDialog(
                context: context,
                builder: (context) {
                  return CreatePassDialog(
                    email: email,
                  );
                },
              );
            }
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      showFailedMessage(
        message: 'Интернет холболтоо шалгана уу!.',
        context: context,
      );
      return Future.value(false);
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      var responseLogin = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (responseLogin.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(responseLogin.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', res['access_token']);
        String? accessToken = prefs.getString('access_token').toString();
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        _userInfo = decodedToken;
        await prefs.setString('refresh_token', res['refresh_token']);
        await prefs.setString('useremail', decodedToken['email']);
        await prefs.setInt('user_id', decodedToken['user_id']);
        await prefs.setString('userrole', decodedToken['role']);
        final shoppingCart =
            Provider.of<BasketProvider>(context, listen: false);
        shoppingCart.getBasket();
        // await prefs.setString('basket_count', count.toString());

        notifyListeners();
        if (decodedToken['role'] == 'S') {
          gotoRemoveUntil(const SellerHomePage(), context);
        }
        if (decodedToken['role'] == 'PA') {
          gotoRemoveUntil(const PharmaHomePage(), context);
        }
        if (decodedToken['role'] == 'D') {
          gotoRemoveUntil(const JaggerHomePage(), context);
        }
        await prefs.setString('access_token', res['access_token']);
        await prefs.setString('refresh_token', res['refresh_token']);
        if (kDebugMode) {
          print(accessToken);
        }
        notifyListeners();
      } else if (responseLogin.statusCode == 400) {
        final res = jsonDecode(utf8.decode(responseLogin.bodyBytes));
        List<dynamic> message = res['password'];
        showFailedMessage(context: context, message: message.toString());
      } else {
        {
          showFailedMessage(message: 'Нууц үг буруу байна!', context: context);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['SERVER_URL']}auth/logout/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    notifyListeners();
    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('access_token');
      prefs.remove('refresh_token');
      gotoRemoveUntil(const LoginPage(), context);
    }
    notifyListeners();
  }

  Future<void> signUpGetOtp(
      String email, String phone, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reg_otp/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            'email': email,
            'phone': phone,
          },
        ),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        showSuccessMessage(
            message: 'Батлагаажуулах код илгээлээ!', context: context);
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(message: 'Амжилтгүй!', context: context);
      notifyListeners();
    }
  }

  Future<void> register(String email, String phone, String password, String otp,
      BuildContext context) async {
    try {
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}auth/register/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'phone': phone,
            'password': password,
            'otp': otp
          }));
      notifyListeners();
      if (response.statusCode == 200) {
        gotoRemoveUntil(const LoginPage(), context);
        showSuccessMessage(
            message: 'Бүртгэл амжилттай үүслээ', context: context);
        notifyListeners();
      }
      if (response.statusCode == 500) {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(message: 'Амжилтгүй!', context: context);
    }
    notifyListeners();
  }

  Future<void> resetPassOtp(String email, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/get_otp/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        showSuccessMessage(
            context: context, message: 'Батлагаажуулах код илгээлээ');
        notifyListeners();
      } else {
        showFailedMessage(message: 'Амжилтгүй!', context: context);
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      showFailedMessage(context: context, message: 'Амжилтгүй!');
    }
    notifyListeners();
  }

  Future<void> createPassword(String email, String otp, String newPassword,
      BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}auth/reset/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_pwd': newPassword,
        }),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        showSuccessMessage(
            message: 'Нууц үг амжилттай үүслээ', context: context);
        notifyListeners();
      }
    } catch (e) {
      showFailedMessage(message: 'Амжилтгүй!', context: context);
    }
    notifyListeners();
  }
}
