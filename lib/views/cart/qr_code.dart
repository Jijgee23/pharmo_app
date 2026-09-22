import 'package:pharmo_app/application/application.dart';

class QRCode extends StatelessWidget {
  const QRCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qrData = cart.qrCode;
        return QrPaymentScreen(
          title: 'Бэлнээр төлөх',
          qrText: qrData.qrTxt.toString(),
          priceLabel: toPrice(qrData.totalPrice),
          countLabel: qrData.totalCount?.toInt().toString() ?? '0',
          bankUrls: qrData.urls ?? [],
          canPop: true,
          onPrimary: () async => await cart.checkPayment(),
        );
      },
    );
  }
}
