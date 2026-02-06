import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmo_app/application/application.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cart, _) {
      List? urls = cart.qrCode.urls;
      return Scaffold(
        appBar: const SideAppBar(text: 'Бэлнээр төлөх'),
        body: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 10,
                    children: [
                      Text(
                        'Доорх QR кодыг уншуулж төлбөр төлснөөр захиалга баталгаажна.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: theme.primaryColor),
                      ),
                      Center(
                          child: QrImageView(
                        data: cart.qrCode.qrTxt.toString(),
                        size: 200,
                      )),
                      info('Төлөх дүн:', toPrice(cart.qrCode.totalPrice),
                          color: secondary),
                      info('Нийт тоо ширхэг:',
                          cart.qrCode.totalCount.toString()),
                      Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children:
                                    urls!.map((el) => bankIcon(el)).toList()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 20),
          height: 60,
          child: CustomButton(
            text: 'Төлбөр шалгах',
            ontap: () async => await cart.checkPayment(),
          ),
        ),
      );
    });
  }

  Widget bankIcon(dynamic el) {
    return InkWell(
      onTap: () async {
        bool found = await canLaunchUrl(Uri.parse(el['link']));
        if (found) {
          await launchUrl(Uri.parse(el['link']),
              mode: LaunchMode.externalApplication);
        } else {
          messageWarning(el['description'] + ' апп олдсонгүй.');
        }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: NetworkImage(el['logo']))),
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(top: 5),
      ),
    );
  }

  info(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: color ?? black)),
      ],
    );
  }
}
