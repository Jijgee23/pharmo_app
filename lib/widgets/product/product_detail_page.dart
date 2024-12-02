import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/product_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({super.key, required this.prod});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin {
  TextEditingController qtyController =
      TextEditingController(text: 1.toString());
  late ProductProvider productProvider;
  late TabController tabController;
  bool fetching = false;
  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  Map<String, dynamic> det = {};

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging == false) {
        setState(() {});
      }
    });
    getProductDetail();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  getProductDetail() async {
    setFetching(true);
    try {
      final response = await apiGet('products/${widget.prod.id}/');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print(data);
        setState(() {
          det = data;
        });
      } else {
        debugPrint(response.statusCode.toString());
      }
    } catch (e) {
      //
    }
    setFetching(false);
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
            productId: widget.prod.id,
            itemnameId: widget.prod.itemnameId,
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
    final sh = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    final basketProvider = Provider.of<BasketProvider>(context);
    final hp = Provider.of<HomeProvider>(context);
    return (fetching)
        ? const Center(child: PharmoIndicator())
        : Scaffold(
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
                      const SizedBox(height: 50),
                      SizedBox(
                        child: Row(
                          children: [
                            back(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.prod.name.toString(),
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: sh * 0.012,
                                    fontWeight: FontWeight.bold),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 15),
                              child: InkWell(
                                onTap: () {
                                  Get.back();
                                  hp.changeIndex(hp.userRole == 'S' ? 3 : 2);
                                },
                                child: badges.Badge(
                                  badgeContent: Text(
                                    basketProvider.basket.totalCount.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  badgeStyle: const badges.BadgeStyle(
                                    badgeColor: AppColors.secondary,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '#${widget.prod.barcode.toString()}',
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 14),
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    Text(toPrice(['salePrice']),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Үндсэн үнэ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  toPrice(widget.prod.price),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
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
                          height: size.height * 0.23,
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
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // Or spaceBetween
                        children: [
                          myTab(title: 'Барааны мэдээлэл', index: 0),
                          myTab(title: 'Урамшуулал', index: 1),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            Column(
                              children: [
                                infoRow('Барааны дуусах хугацаа',
                                    det['expDate'] ?? ''),
                                infoRow('Ерөнхий нэршил', det['intName'] ?? ''),
                                infoRow('Тун хэмжээ', ''),
                                infoRow('Хөнгөлөлт', ''),
                                infoRow('Хэлбэр', ''),
                                infoRow(
                                    'Мастер савалгааны тоо',
                                    (det['master_box_qty'] == null)
                                        ? ''
                                        : det['master_box_qty'].toString()),
                                infoRow('Олгох нөхцөл', ''),
                                infoRow('Улс', ''),
                                infoRow(
                                    'Үйлдвэрлэгч',
                                    (det['mnfr'] != null)
                                        ? det['mnfr']['name']
                                        : ""),
                              ],
                            ),
                            Column(
                              children: [
                                infoRow(
                                    'Бөөний үнэ',
                                    det['salePrice'] != null
                                        ? det['salePrice'].toString()
                                        : ''),
                                infoRow(
                                    'Бөөний тоо', '${det['saleQty'] ?? ''}'),
                                infoRow('Хямдрал', '${det['discount'] ?? ''}'),
                                infoRow('Хямдрал дуусах хугацаа',
                                    det['discountExpireDate'] ?? '')
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IntrinsicWidth(
                              child: TextField(
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.done,
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 10),
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
                            Expanded(
                              child: InkWell(
                                onTap: () => addBasket(),
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.primary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Сагсанд нэмэх',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: sh * 0.014,
                                      ),
                                    ),
                                  ),
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

  myTab({String? title, required int index}) {
    bool selected = (index == tabController.index);
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () => setState(() {
        tabController.animateTo(index);
      }),
      child: Container(
        width: sw * 0.4,
        decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            title!,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: sh * 0.012),
          ),
        ),
      ),
    );
  }

  infoRow(String title, String text) {
    final fontsize = MediaQuery.of(context).size.height * 0.0133;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w700,
            fontSize: fontsize,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
          ),
        ),
      ],
    );
  }
}
