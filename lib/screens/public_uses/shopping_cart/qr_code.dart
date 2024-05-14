// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/screens/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatelessWidget {
  const QRCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(
          title: 'Бэлнээр төлөх',
        ),
        body: Consumer<BasketProvider>(
          builder: (context, provider, _) {
            return Container(
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
                        data: provider.qrCode.qrTxt.toString(),
                        size: 250,
                      )),
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
                              '${provider.qrCode.totalPrice} ₮',
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
                              provider.qrCode.totalCount.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 17),
                            ),
                          ]),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PharmaHomePage()),
                            (route) => true);
                        provider.getBasket();
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
                      onPressed: () async {
                        dynamic res = await provider.checkPayment();
                        if (res['errorType'] == 1) {
                          if (res['data'] == false) {
                            showFailedMessage(
                                message: 'Төлбөр төлөгдөөгүй байна.',
                                context: context);
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => OrderDone(
                                        orderNo: res['data']['orderNo']
                                            .toString())));
                            showSuccessMessage(
                                message: res['message'], context: context);
                          }
                        } else {
                          showFailedMessage(
                              message: res['message'], context: context);
                        }
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
            );
          },
        ));
  }
}
