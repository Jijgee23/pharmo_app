import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class AppDetail extends StatefulWidget implements PreferredSizeWidget {
  const AppDetail({super.key});

  @override
  State<AppDetail> createState() => _AppDetailState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _AppDetailState extends State<AppDetail> {
  List<Widget> carouselItems = [
    Image.network('https://12bb6ecf-bda5-4c99-816b-12bda79f6bd9.selcdn.net/upload//Photo_Tovar/396999_2_1687352103.jpeg'),
    Image.network('https://iskamed.by/wp-content/uploads/1433.jpg'),
    Image.network('https://612611.selcdn.ru/prod-s3/resize_cache/1583648/8d98eab21f83652e055a2f8c91f3543a/iblock/2dd/2dddefb762666acf79f34cdeb455be4b/617f02e7aaece58849e3acf3e5651c89.png'),
  ];
  TextEditingController qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    // basketProvider.getBasket();
    final shoppingCartCC = context.watch<BasketProvider>().count;

    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
        title: Text(
          basketProvider.count.toString() + ' ' + shoppingCartCC.toString(),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return AlertDialog(
                        title: const Text('Захиалгууд'),
                        content: const ShoppingCart(),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Хаах'),
                          ),
                        ],
                      );
                    }));
              }),
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: badges.Badge(
              badgeContent: Text(
                "${basketProvider.count} $shoppingCartCC",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.blue,
              ),
              child: const Icon(
                Icons.shopping_basket,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
