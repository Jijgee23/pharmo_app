import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/screens/shopping_cart/select_branch.dart';
import 'package:pharmo_app/screens/shopping_cart/seller_select_branch.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  String? _userRole = '';
  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userrole');
    setState(() {
      _userRole = userRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);

    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PharmaHomePage()));
    }

    void purchase(int basketId) {
      if (_userRole == 'S') {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SelectSellerBranchPage()));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SelectBranchPage()));
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(_userRole);
        },
        child: const Icon(Icons.home),
      ),
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: AppColors.primary),
      //   centerTitle: true,
      //   title: const Text(
      //     'Миний сагс',
      //     style: TextStyle(fontSize: 16),
      //   ),
      //   actions: [
      //     Container(
      //       margin: const EdgeInsets.only(right: 15),
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
      //         },
      //         child: badges.Badge(
      //           badgeContent: Text(
      //             "${basketProvider.count}",
      //             style: const TextStyle(color: Colors.white, fontSize: 11),
      //           ),
      //           badgeStyle: const badges.BadgeStyle(
      //             badgeColor: Colors.blue,
      //           ),
      //           child: const Icon(
      //             Icons.shopping_basket,
      //             color: Colors.red,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      appBar: const CustomAppBar(
        title: 'Миний сагс',
      ),
      body: Consumer<BasketProvider>(
        builder: (context, provider, _) {
          final cartDatas = provider.shoppingCarts;
          final basket = provider.basket;
          return Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    cartDatas.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: cartDatas.length,
                              itemBuilder: (context, index) {
                                return ShoppingCartView(
                                    detail: cartDatas[index] ?? {});
                              },
                            ),
                          )
                        : const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                "Сагс хоосон байна ...",
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сагсанд ${provider.shoppingCarts.length} төрлийн бараа байна.',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                                text: 'Нийт тоо ширхэг: ',
                                style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 13.0),
                                children: [
                                  TextSpan(
                                      text: '${basket.totalCount}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)),
                                ]),
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                                text: 'Нийт төлөх дүн: ',
                                style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 13.0),
                                children: [
                                  TextSpan(
                                      text: '${basket.totalPrice} ₮',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.red)),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            clearBasket(basket.id);
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                          ),
                          label: const Text('Сагс хоослох'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            purchase(basket.id);
                          },
                          icon: const Icon(
                            Icons.paid_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Төлбөр төлөх',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
