// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/screens/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}ci/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: homeProvider.orderType == 'NODELIVERY' 
            ? homeProvider.note == null
                ? jsonEncode({
                    'userId': homeProvider.selectedCustomerId,
                  })
                : jsonEncode({
                    'userId': homeProvider.selectedCustomerId,
                    'note': homeProvider.note,
                  })
            : homeProvider.note == null
                ? jsonEncode({
                    'userId': homeProvider.selectedCustomerId,
                    'branchId': homeProvider.selectedBranchId,
                  })
                : jsonEncode({
                    'userId': homeProvider.selectedCustomerId,
                    'branchId': homeProvider.selectedBranchId,
                    'note': homeProvider.note,
                  }),
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          qrData = res;
          if (res['urls'] != null) {
            urls = res['urls'];
          }
        });
      }
    } catch (e) {
      showFailedMessage(
          message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
      debugPrint(e.toString());
    }
  }

  checkPayment() async {
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
        dynamic response = jsonDecode(utf8.decode(resQR.bodyBytes));
        //  basketProvider.clearBasket(basket_id: homeProvider.basketId!);
        if (response['isPaid'] == true) {
          clearBasket(homeProvider.basketId!);
          showSuccessMessage(
              context: context, message: 'Төлбөр төлөгдсөн байна');
          gotoRemoveUntil(
              OrderDone(orderNo: response['orderNo'].toString()), context);
        }
        if (response == false) {
          showFailedMessage(
              context: context, message: 'Төлбөр төлөгдөөгүй байна!');
        }
      }
      if (resQR.statusCode == 404) {
        showFailedMessage(
            context: context, message: 'Сагсны мэдээлэл олдоогүй!');
      }
    } catch (e) {
      debugPrint(e.toString());
      // showFailedMessage(context: context, message: 'Алдаа гарлаа!');
    }
  }

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    createQR();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BasketProvider, HomeProvider>(
      builder: (_, basketprovider, homeprovider, child) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Бэлнээр төлөх',
          ),
          body: Container(
            margin: const EdgeInsets.all(20),
            child: Column(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Доорх QR кодыг уншуулж төлбөр төлснөөр захиалга баталгаажна.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: QrImageView(
                        data: qrData['qrTxt'].toString(),
                        size: 250,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
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
                                fontWeight: FontWeight.w600, fontSize: 17),
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
                                color: Colors.red),
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
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 0),
                        child: SingleChildScrollView(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (var i in urls)
                                InkWell(
                                  onTap: () async {
                                    bool found = await canLaunchUrl(
                                        Uri.parse(i['link']));
                                    if (found) {
                                      await launchUrl(Uri.parse(i['link']),
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      showFailedMessage(
                                          message: i['description'] +
                                              ' банкны апп олдсонгүй.',
                                          context: context);
                                    }
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.all(5),
                                    child: Image.network(i['logo']),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      gotoRemoveUntil(const SellerHomePage(), context);
                      basketProvider.getBasket();
                    },
                    icon: const Icon(
                      color: Colors.white,
                      Icons.home,
                      size: 24.0,
                    ),
                    label: const Text(
                      'Нүүр хуудас',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      checkPayment();
                    },
                    icon: const Icon(
                      color: Colors.white,
                      Icons.home,
                      size: 24.0,
                    ),
                    label: const Text(
                      'Төлбөр шалгах',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              )
            ]),
          ),
        );
      },
    );
  }
}
