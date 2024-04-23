import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';

class OrderDone extends StatelessWidget {
  final String orderNo;
  const OrderDone({super.key, required this.orderNo});

  @override
  Widget build(BuildContext context) {
    //  final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 850.0;

    return Scaffold(
        appBar: const CustomAppBar(
          title: 'Миний захиалга',
        ),
        body: SizedBox(
            width: double.infinity,
            child: Center(
                child: SizedBox(
              width: screenWidth <= maxWidth ? screenWidth : maxWidth,
              child: Consumer<BasketProvider>(
                builder: (context, provider, _) {
                  return Stack(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 130, bottom: 25),
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 180,
                            child: Image.asset('assets/order_success.jpg'),
                          ),
                        ),
                        const Text(
                          'Таны захиалга амжилттай үүслээ.',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text(
                              'Таны захиалгы дугаар : ',
                            ),
                            Text(
                              '$orderNo',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PharmaHomePage()), (route) => true);
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
                          ],
                        )
                      ],
                    ),
                  ]);
                },
              ),
            ))));
  }
}
