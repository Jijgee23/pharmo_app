import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/index_pharmacy.dart';
import 'package:provider/provider.dart';

class OrderDone extends StatefulWidget {
  final String orderNo;
  const OrderDone({super.key, required this.orderNo});

  @override
  State<OrderDone> createState() => _OrderDoneState();
}

class _OrderDoneState extends State<OrderDone> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      goHome(Provider.of<BasketProvider>(context, listen: false));
    });
    super.initState();
  }

  goHome(BasketProvider provider) async {
    final HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.changeIndex(0);
    await provider.clearBasket();
    await provider.getBasket();
    gotoRemoveUntil(const IndexPharma());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 850.0;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: SizedBox(
          width: screenWidth <= maxWidth ? screenWidth : maxWidth,
          child: Consumer<BasketProvider>(
            builder: (context, provider, _) {
              return Stack(children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 130, bottom: 25),
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 180,
                          child: Image.asset('assets/stickers/verified.gif'),
                        ),
                      ),
                      const Text(
                        'Таны захиалга амжилттай үүслээ.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Таны захиалгы дугаар : ',
                              ),
                              Text(
                                widget.orderNo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                      ),
                      Container(
                        width: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 39),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:theme.primaryColor),
                        child: InkWell(
                          onTap: () => goHome(provider),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_filled,
                                    color: AppColors.cleanWhite),
                                SizedBox(width: 10),
                                Text(
                                  'Нүүр хуудас',
                                  style: TextStyle(
                                      color: AppColors.cleanWhite,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
