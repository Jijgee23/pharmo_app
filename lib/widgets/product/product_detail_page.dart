import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/product_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/cart/cart_item.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class ProductDetail extends StatefulWidget {
  final Product prod;

  const ProductDetail({super.key, required this.prod});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin {
  TextEditingController qtyController = TextEditingController();
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

  splitURL(String url) {
    List<String> strings = url.split('.');
    return strings;
  }

  final fontsize = Sizes.height * 0.015;
  String initQTY = 'Тоо ширхэг';
  setInitQyu(String n) {
    setState(() {
      initQTY = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final div = Divider(color: theme.primaryColor, thickness: .7);
    return Scaffold(
      body: (fetching)
          ? const Center(child: PharmoIndicator())
          : Consumer<BasketProvider>(
              builder: (context, basket, child) => Scaffold(
                appBar: CustomAppBar(
                  leading: const ChevronBack(),
                  title: Text(
                    widget.prod.name.toString(),
                    softWrap: true,
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: Sizes.smallFontSize * 1.2,
                        fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                body: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: EdgeInsets.all(Sizes.width * 0.03),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '#${widget.prod.barcode.toString()}',
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: Sizes.mediulFontSize),
                          ),
                        ),
                        div,
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
                                      Text(
                                        'Бөөний үнэ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                Sizes.smallFontSize * 1.2),
                                      ),
                                      Text(toPrice(['salePrice']),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: Sizes.mediulFontSize,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Үндсэн үнэ',
                                      style: TextStyle(
                                          fontSize: Sizes.smallFontSize * 1.2)),
                                  Text(
                                    toPrice(widget.prod.price),
                                    style: TextStyle(
                                        fontSize: Sizes.mediulFontSize,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        div,
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: InstaImageViewer(
                            imageUrl: widget.prod.image != null &&
                                    splitURL(widget.prod.image!).length == 2
                                ? '${dotenv.env['IMAGE_URL']}${splitURL(widget.prod.image!)[0]}_1000x1000.${splitURL(widget.prod.image!)[1]}'
                                : 'https://st2.depositphotos.com/3904951/8925/v/450/depositphotos_89250312-stock-illustration-photo-picture-web-icon-in.jpg',
                            child: Container(
                              height: Sizes.height * 0.23,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  alignment: Alignment.center,
                                  image: NetworkImage(widget.prod.image !=
                                              null &&
                                          splitURL(widget.prod.image!).length ==
                                              2
                                      ? '${dotenv.env['IMAGE_URL']}${splitURL(widget.prod.image!)[0]}_300x300.${splitURL(widget.prod.image!)[1]}'
                                      : 'https://st2.depositphotos.com/3904951/8925/v/450/depositphotos_89250312-stock-illustration-photo-picture-web-icon-in.jpg'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        div,
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // Or spaceBetween
                          children: [
                            myTab(title: 'Барааны мэдээлэл', index: 0),
                            myTab(title: 'Урамшуулал', index: 1),
                          ],
                        ),
                        SizedBox(
                          height: Sizes.height * 0.25,
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              Column(
                                children: [
                                  infoRow('Барааны дуусах хугацаа',
                                      det['expDate'] ?? ''),
                                  infoRow(
                                      'Ерөнхий нэршил', det['intName'] ?? ''),
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
                                  infoRow(
                                      'Хямдрал', '${det['discount'] ?? ''}'),
                                  infoRow('Хямдрал дуусах хугацаа',
                                      det['discountExpireDate'] ?? '')
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: Sizes.width * 0.03),
                  child: CustomButton(
                    text: 'Сагсанд нэмэх',
                    ontap: () => showSheet(basket),
                  ),
                ),
              ),
            ),
    );
  }

  showSheet(BasketProvider basket) {
    Get.bottomSheet(
      ChangeQtyPad(
        title: 'Тоо ширхэг оруулна уу?',
        onSubmit: () async {
          setInitQyu(basket.qty.text);
          addBasket();
        },
        initValue: '0',
      ),
    );
  }

  void addBasket() async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      if (initQTY == 'Тоо ширхэг' || initQTY.isEmpty || initQTY == '') {
        message('Тоон утга оруулна уу!');
      } else if (int.parse(initQTY) <= 0) {
        message('0 ба түүгээс бага байж болохгүй!');
      } else {
        Map<String, dynamic> res = await basketProvider.addBasket(
            productId: widget.prod.id,
            itemnameId: widget.prod.itemnameId,
            qty: int.parse(initQTY));
        if (res['errorType'] == 1) {
          basketProvider.getBasket();
          message('${widget.prod.name} сагсанд нэмэгдлээ.');
        } else {
          message(res['message']);
        }
      }
    } catch (e) {
      print(e);
      message('Алдаа гарлаа!');
    }
    Navigator.pop(context);
  }

  myTab({String? title, required int index}) {
    bool selected = (index == tabController.index);
    final sw = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () => setState(() {
        tabController.animateTo(index);
      }),
      child: Container(
        width: sw * 0.4,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? Colors.transparent : Theme.of(context).primaryColor,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            title!,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: Sizes.smallFontSize * 1.2),
          ),
        ),
      ),
    );
  }

  infoRow(String title, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: Sizes.mediulFontSize)),
        Text(text,
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: Sizes.mediulFontSize)),
      ],
    );
  }
}
