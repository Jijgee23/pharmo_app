// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerQRCode extends StatefulWidget {
  const SellerQRCode({super.key});

  @override
  State<SellerQRCode> createState() => _SellerQRCodeState();
}

class _SellerQRCodeState extends State<SellerQRCode> {
  Map qrData = {};
  List urls = [];
  bool isPayed = false;
  String orderId = '';
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  clearBasket(int basketId) {
    basketProvider.clearBasket(basket_id: basketId);
    basketProvider.getBasket();
  }

  createQR() async {
    try {
      final btoken = await getAccessToken();
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}ci/'),
        headers: getHeader(btoken),
        body: jsonEncode(
          {
            'customer_id': homeProvider.selectedCustomerId,
            'note': homeProvider.note
          },
        ),
      );
      int stcode = response.statusCode;
      if (stcode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          qrData = res;
          if (res['urls'] != null) {
            urls = res['urls'];
          }
        });
      } else if (stcode == 404) {
        message(context: context, message: 'Нийлүүлэгч Qpay холбоогүй');
      } else if (stcode == 400) {
        final text = jsonDecode(utf8.decode(response.bodyBytes));
        if (message is String) {
          if (text == 'qpay') {
            message(
                message: 'Нийлүүлэгч Qpay холбоогүй байна', context: context);
          } else if (text == 'bad qpay') {
            message(
                message: 'Нийлүүлэгчийн Qpay тохиргоо алдаатай.',
                context: context);
          } else if (text == "min") {
            message(
                message: 'Төлбөрийн дүн 10 төг буюу түүнээс дээш байх.',
                context: context);
          } else if (text == 'empty') {
            message(
                message: 'Захиалганд бараа байхгүй буюу сагс хоосон.',
                context: context);
          }
          Navigator.pop(context);
        } else {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          List<dynamic> msg = data['branchId'];
          if (msg[0] == 'Branch not found!') {
            message(message: 'Салбарын  мэдээлэл буруу.', context: context);
          } else if (msg[0] == 'User not found') {
            message(message: 'Захиалагчийн мэдээлэл буруу', context: context);
          }
          Navigator.pop(context);
        }
      } else if (stcode == 500) {
        message(message: 'Серверийн алдаа', context: context);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(
        e.toString(),
      );
    }
  }

  Future<bool> checkPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final resQR = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}cp/?userId=${homeProvider.selectedCustomerId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (resQR.statusCode == 200) {
        final response = jsonDecode(utf8.decode(resQR.bodyBytes));
        if (response is bool) {
          if (!response) {
            message(context: context, message: 'Төлбөр төлөгдөөгүй байна!');
          } else {
            message(context: context, message: 'Төлбөр амжилттай хийгдлээ!');
            clearBasket(homeProvider.basketId!);
          }
        } else {
          if (response['isPaid'].toString() == 'true') {
            message(context: context, message: 'Төлбөр амжилттай хийгдлээ!');
            clearBasket(homeProvider.basketId!);
            gotoRemoveUntil(
                OrderDone(
                  orderNo: response['orderNo'],
                ),
                context);
          } else {
            message(context: context, message: 'Төлбөр төлөгдөөгүй байна!');
          }
        }
      } else if (resQR.statusCode == 404) {
        final response = jsonDecode(utf8.decode(resQR.bodyBytes));
        if (response == 'invoice') {
          message(context: context, message: 'Нэхэмжлэх үүсээгүй!');
        } else if (response == 'token') {
          message(context: context, message: 'Нэхэмжлэх үүсээгүй!');
        } else if (response == 'basket') {
          message(context: context, message: 'Сагсны мэдээлэл олдоогүй!');
        } else {
          message(context: context, message: 'Серверийн алдаа!');
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    basketProvider.getBasket();
    createQR();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BasketProvider, HomeProvider>(
      builder: (_, basketprovider, homeprovider, child) {
        return Scaffold(
          appBar: const SideMenuAppbar(title: 'Бэлнээр төлөх'),
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              'Доорх QR кодыг уншуулж төлбөр төлснөөр захиалга баталгаажна.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: QrImageView(
                              data: qrData['qrTxt'].toString(),
                              size: 200,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Төлбөрийн хэлбэр : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Бэлнээр',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                                ),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Нийт үнэ : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  '${qrData['totalPrice']} ₮',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: AppColors.secondary),
                                ),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Нийт тоо ширхэг: ',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                '${qrData['totalCount']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 17),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: SingleChildScrollView(
                              child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: urls
                                      .map((i) => InkWell(
                                            onTap: () async {
                                              bool found = await canLaunchUrl(
                                                  Uri.parse(i['link']));
                                              if (found) {
                                                await launchUrl(
                                                    Uri.parse(i['link']),
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              } else {
                                                message(
                                                    message: i['description'] +
                                                        ' апп олдсонгүй.',
                                                    context: context);
                                              }
                                            },
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              margin: const EdgeInsets.all(5),
                                              child: Image.network(i['logo']),
                                            ),
                                          ))
                                      .toList()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(text: 'Төлбөр шалгах', onTap: () => checkPayment())
                    ],
                  )
                ]),
          ),
        );
      },
    );
  }
}
