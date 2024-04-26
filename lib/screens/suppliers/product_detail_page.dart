// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({Key? key, required this.prod}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Widget> carouselItems = [
    Image.network(
        'https://12bb6ecf-bda5-4c99-816b-12bda79f6bd9.selcdn.net/upload//Photo_Tovar/396999_2_1687352103.jpeg'),
    Image.network('https://iskamed.by/wp-content/uploads/1433.jpg'),
    Image.network(
        'https://612611.selcdn.ru/prod-s3/resize_cache/1583648/8d98eab21f83652e055a2f8c91f3543a/iblock/2dd/2dddefb762666acf79f34cdeb455be4b/617f02e7aaece58849e3acf3e5651c89.png'),
  ];
  TextEditingController qtyController = TextEditingController();
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
    print(_userRole);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addBasket() async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      if (qtyController.text.isEmpty || int.parse(qtyController.text) <= 0) {
        showFailedMessage(
            message: 'Барааны тоо хэмжээг оруулна уу.', context: context);
        return;
      }
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: widget.prod.id,
          itemname_id: widget.prod.itemname_id,
          qty: int.parse(qtyController.text));
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
        showSuccessMessage(message: res['message'], context: context);
        if (_userRole == 'S') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PharmaHomePage(),
            ),
          );
        }
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final basketProvider = Provider.of<BasketProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text(
      //     'Барааны дэлгэрэнгүй',
      //     style: TextStyle(fontSize: 18),
      //   ),
      //   actions: [
      //     IconButton(
      //         icon: const Icon(
      //           Icons.notifications,
      //           color: Colors.blue,
      //         ),
      //         onPressed: () {}),
      //     Container(
      //       margin: const EdgeInsets.only(right: 15),
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
      //         },
      //         child: badges.Badge(
      //           badgeContent: Text(
      //             '${basketProvider.count}',
      //             style: const TextStyle(color: Colors.white, fontSize: 10),
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
      //     )
      //   ],
      // ),
      appBar: const CustomAppBar(
        title: 'Барааны дэлгэрэнгүй',
      ),
      body: ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: CarouselSlider(
                    items: carouselItems,
                    options: CarouselOptions(
                      height: size.height *
                          0.2, // Customize the height of the carousel
                      autoPlay: true, // Enable auto-play
                      enlargeCenterPage:
                          true, // Increase the size of the center item
                      enableInfiniteScroll: true, // Enable infinite scroll
                      onPageChanged: (index, reason) {
                        // Optional callback when the page changes
                        // You can use it to update any additional UI components
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.prod.name.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('Баркод: ${widget.prod.barcode}'),
                      Text('Үнэ: ${widget.prod.price}₮'),
                      Text('Барааны дуусах хугацаа: ${widget.prod.expDate}'),
                      Text('Бөөний үнэ: ${widget.prod.discount}'),
                      Text('Бөөний тоо: ${widget.prod.in_stock}'),
                      Text('Хямдрал: ${widget.prod.sale_price}'),
                      Text('Үйлдвэрлэгч: ${widget.prod.supplier}'),
                      Text('Тоо ширхэг: ${basketProvider.count}'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        height: 50,
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'Тоо хэмжээ',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.5,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            addBasket();
                          },
                          icon: const Icon(
                            color: Colors.white,
                            Icons.add,
                          ),
                          label: const Text(
                            'Сагсанд нэмэх',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
