// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/product_provider.dart';
import 'package:pharmo_app/models/product_detail.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({super.key, required this.prod});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  TextEditingController qtyController =
      TextEditingController(text: 1.toString());
  late HomeProvider homeProvider;
  late ProductProvider productProvider;
  late ProductDetails detail;

  @override
  void initState() {
    super.initState();
    detail = ProductDetails(id: widget.prod.id);
    getProductDetail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProductDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      String bearerToken = "Bearer $token";
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}products/${widget.prod.id}/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          detail = ProductDetails.fromJson(data);
        });
      } else {
        debugPrint(response.statusCode.toString());
      }
    } catch (e) {
      //
    }
  }

  void addBasket() async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      if (qtyController.text.isEmpty || int.parse(qtyController.text) <= 0) {
        message(message: 'Барааны тоо хэмжээг оруулна уу.', context: context);
        return;
      } else {
        Map<String, dynamic> res = await basketProvider.addBasket(
            product_id: widget.prod.id,
            itemname_id: widget.prod.itemname_id,
            qty: int.parse(qtyController.text));
        if (res['errorType'] == 1) {
          basketProvider.getBasket();
          message(
              message: '${widget.prod.name} сагсанд нэмэгдлээ.',
              context: context);
          Navigator.pop(context);
        } else {
          message(message: res['message'], context: context);
        }
      }
    } catch (e) {
      message(message: 'Алдаа гарлаа!', context: context);
    }
  }

  splitURL(String url) {
    List<String> strings = url.split('.');
    return strings;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final basketProvider = Provider.of<BasketProvider>(context);
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: Container(
          width: size.width,
          height: size.height,
          color: AppColors.cleanWhite,
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  child: Row(
                    children: [
                      const ChevronBack(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(widget.prod.name.toString(),
                            style: Constants.headerTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '#${widget.prod.barcode.toString()}',
                    style:
                        const TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                ),
                const Divider(color: Colors.black),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.cleanWhite,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Бөөний үнэ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                  '${detail.salePrice != null ? detail.salePrice.toString() : '-'}₮',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          Container(
                            width: 2,
                            color: AppColors.cleanWhite,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Үндсэн үнэ'),
                          Text(
                            '${widget.prod.price.toString()}₮',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.black),
                InstaImageViewer(
                  imageUrl: widget.prod.image != null &&
                          splitURL(widget.prod.image!).length == 2
                      ? '${dotenv.env['IMAGE_URL']}${splitURL(widget.prod.image!)[0]}_1000x1000.${splitURL(widget.prod.image!)[1]}'
                      : 'https://precisionpharmacy.net/wp-content/themes/apexclinic/images/no-image/No-Image-Found-400x264.png',
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.center,
                        image: NetworkImage(widget.prod.image != null &&
                                splitURL(widget.prod.image!).length == 2
                            ? '${dotenv.env['IMAGE_URL']}${splitURL(widget.prod.image!)[0]}_300x300.${splitURL(widget.prod.image!)[1]}'
                            : 'https://precisionpharmacy.net/wp-content/themes/apexclinic/images/no-image/No-Image-Found-400x264.png'),
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.black),
                const Text(
                  'Барааны мэдээлэл:',
                ),
                const Divider(color: Colors.black),
                infoRow('Барааны дуусах хугацаа', detail.expDate ?? '-'),
                infoRow('Ерөнхий нэршил', detail.intName ?? '-'),
                infoRow('Тун хэмжээ', '-'),
                infoRow('Хөнгөлөлт', '-'),
                infoRow('Хэлбэр', '-'),
                infoRow('Олгох нөхцөл', '-'),
                infoRow('Улс', '-'),
                infoRow('Үйлдвэрлэгч', '-'),
                const SizedBox(height: 20),
                const Text('Урамшууллын мэдээлэл:'),
                const Divider(color: Colors.black),
                infoRow(
                    'Бөөний үнэ',
                    detail.salePrice != null
                        ? detail.salePrice.toString()
                        : '-'),
                infoRow('Бөөний тоо', '${detail.saleQty ?? '-'}'),
                infoRow('Хямдрал', '${detail.discount ?? '-'}'),
                infoRow(
                    'Хямдрал дуусах хугацаа', detail.discountExpireDate ?? '-')
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
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
            Expanded(
              flex: 7,
              child: InkWell(
                onTap: () => addBasket(),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                  ),
                  child: const Center(
                    child: Text(
                      'Сагсанд нэмэх',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  infoRow(String title, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        Text(text),
      ],
    );
  }
}
