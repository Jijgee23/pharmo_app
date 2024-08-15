// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/main/jagger_home_page.dart';
import 'package:pharmo_app/views/pharmacy/main/pharma_home_page.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/auth/login_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/create_pass_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
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
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);
      await prefs.setString('access_token', accessToken);
      await prefs.setString('role', decodedToken['role']);
      await prefs.setString('useremail', decodedToken['email']);
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
        await prefs.setInt('suppID', decodedToken['supplier']);
        final shoppingCart =
            Provider.of<BasketProvider>(context, listen: false);
        shoppingCart.getBasket();
        Hive.box('auth').put('role', decodedToken['role']);
        notifyListeners();
        if (decodedToken['role'] == 'S') {
          gotoRemoveUntil(const SellerHomePage(), context);
        } else if (decodedToken['role'] == 'PA') {
          gotoRemoveUntil(const PharmaHomePage(), context);
        } else if (decodedToken['role'] == 'D') {
          gotoRemoveUntil(const JaggerHomePage(), context);
        } else {
          showFailedDialog(context);
          toggleVisibile();
          notifyListeners();
        }
        await prefs.setString('access_token', res['access_token']);
        await prefs.setString('refresh_token', res['refresh_token']);

        debugPrint(accessToken);

        notifyListeners();
      } else if (responseLogin.statusCode == 400) {
        final res = jsonDecode(utf8.decode(responseLogin.bodyBytes));
        List<dynamic> message = res['password'];
        showFailedMessage(context: context, message: message.toString().substring(1, message.toString().length - 1));
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

  void showFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
              child: Container(
                height: 250,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Таний эрх хүрэхгүй байна!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Icon(Icons.error_sharp,
                        color: AppColors.secondary, size: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.grey, width: 2),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Хаах',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
