// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({super.key, required this.prod});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  List<Widget> carouselItems = [
    Image.network(
        'https://12bb6ecf-bda5-4c99-816b-12bda79f6bd9.selcdn.net/upload//Photo_Tovar/396999_2_1687352103.jpeg'),
    Image.network('https://iskamed.by/wp-content/uploads/1433.jpg'),
  ];
  TextEditingController qtyController = TextEditingController();
  final _focusNode = FocusNode();
  late HomeProvider homeProvider;
  @override
  void initState() {
    super.initState();
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
        Navigator.pop(context);
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
      backgroundColor: AppColors.cleanWhite,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: widget.prod.name.toString(),
      ),
      body: ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: CarouselSlider(
                    items: carouselItems,
                    options: CarouselOptions(
                      height: size.height * 0.2,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {},
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _focusNode.unfocus();
                      },
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          controller: qtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.secondary, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Тоо хэмжээ',
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => addBasket(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.secondary,
                        ),
                        child: const Center(
                          child: Row(
                            children: [
                              Text(
                                'Сагсанд нэмэх',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Баркод:'),
                          Text('${widget.prod.barcode}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Үнэ:'),
                          Text('${widget.prod.price}₮'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Барааны дуусах хугацаа:'),
                          Text(widget.prod.expDate ?? '-'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Бөөний үнэ:'),
                          Text(widget.prod.discount ?? '-'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Бөөний тоо:'),
                          Text('${widget.prod.in_stock ?? '-'}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Хямдрал:'),
                          Text(widget.prod.sale_price ?? '-'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Нийүүлэгч:'),
                          Text('${widget.prod.supplier ?? '-'}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Тоо ширхэг:'),
                          Text('${basketProvider.count}'),
                        ],
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

