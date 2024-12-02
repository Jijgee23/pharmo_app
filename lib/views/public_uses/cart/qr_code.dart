// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/public_uses/cart/order_done.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  // Timer? _timer;
  late BasketProvider basketProvider;
  @override
  void initState() {
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // startCheckingPayment();
    super.initState();
  }

  // void startCheckingPayment() {
  //   _timer = Timer.periodic(
  //     const Duration(seconds: 3),
  //     (Timer timer) async {
  //       dynamic res = await basketProvider.checkPayment();
  //       print(_timer!.isActive.toString());
  //       if (res['errorType'] == 1) {
  //         if (res['data'] == false) {
  //         } else {
  //           gotoRemoveUntil(
  //               OrderDone(orderNo: res['data']['orderNo']), context);
  //           _timer?.cancel();
  //         }
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const SideMenuAppbar(title: 'Бэлнээр төлөх'),
        body: Consumer<BasketProvider>(
          builder: (context, provider, _) {
            List? urls = provider.qrCode.urls;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(children: [
                Expanded(
                  child: SingleChildScrollView(
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
                        Center(
                            child: QrImageView(
                          data: provider.qrCode.qrTxt.toString(),
                          size: 200,
                        )),
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
                                provider.qrCode.totalCount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 17),
                              ),
                            ]),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: SingleChildScrollView(
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: urls!
                                    .map((el) => InkWell(
                                          onTap: () async {
                                            bool found = await canLaunchUrl(
                                                Uri.parse(el['link']));
                                            if (found) {
                                              await launchUrl(
                                                  Uri.parse(el['link']),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } else {
                                              message(
                                                  message: el['description'] +
                                                      ' апп олдсонгүй.',
                                                  context: context);
                                            }
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.all(5),
                                            child: Image.network(el['logo']),
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
                    Button(
                        text: 'Төлбөр шалгах',
                        color: AppColors.primary,
                        onTap: () async {
                          dynamic res = await provider.checkPayment();
                          if (res['errorType'] == 1) {
                            if (res['data'] == false) {
                              message(
                                  message: 'Төлбөр төлөгдөөгүй байна.',
                                  context: context);
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => OrderDone(
                                          orderNo: res['data']['orderNo']
                                              .toString())));
                              message(
                                  message: res['message'], context: context);
                            }
                          } else {
                            message(message: res['message'], context: context);
                          }
                        }),
                  ],
                )
              ]),
            );
          },
        ));
  }
}
