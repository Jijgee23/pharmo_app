import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/product_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/ui_help/def_input_container.dart';
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

  final noImage =
      'https://st2.depositphotos.com/3904951/8925/v/450/depositphotos_89250312-stock-illustration-photo-picture-web-icon-in.jpg';

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
    List<String> infos = [
      'Барааны дуусах хугацаа',
      'Ерөнхий нэршил',
      'Тун хэмжээ',
      'Хөнгөлөлт',
      'Хэлбэр',
      'Мастер савалгааны тоо',
      'Олгох нөхцөл',
      'Улс',
      'Үйлдвэрлэгч'
    ];
    List<String> datas = [
      det['expDate'].toString(),
      det['intName'].toString(),
      '',
      '',
      '',
      det['master_box_qty'].toString(),
      '',
      '',
      det['mnfr'].toString()
    ];
    List<String> infos2 = [
      'Бөөний үнэ',
      'Бөөний тоо',
      'Хямдрал',
      'Хямдрал дуусах хугацаа'
    ];
    List<String> datas2 = [
      maybeNull(det['salePrice'].toString()),
      maybeNull(det['saleQty'].toString()),
      maybeNull(det['discount'].toString()),
      maybeNull(det['discountExpireDate'].toString())
    ];
    return Scaffold(
      body: (fetching)
          ? const Center(child: PharmoIndicator())
          : Consumer2<BasketProvider, HomeProvider>(
              builder: (context, basket, home, child) {
                bool isNotPharma = (home.userRole != 'PA');
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: white,
                    surfaceTintColor: white,
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
                    actions: [],
                  ),
                  body: Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.mediumFontSize),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        imageViewer(),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: ScrollController(),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: SelectableText(
                                    '#${maybeNull(widget.prod.barcode.toString())}',
                                    style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: Sizes.mediumFontSize),
                                  ),
                                ),
                                div,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    myTab(title: 'Барааны мэдээлэл', index: 0),
                                    myTab(title: 'Урамшуулал', index: 1),
                                  ],
                                ),
                                SizedBox(
                                  height: 180,
                                  child: TabBarView(
                                    controller: tabController,
                                    children: [
                                      myTabView(infos, datas),
                                      myTabView(infos2, datas2),
                                    ],
                                  ),
                                ),
                                if (isNotPharma) div,
                                if (isNotPharma)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DefInputContainer(
                                          ontap: () => chooseImageSource(),
                                          width: Sizes.width * 0.35,
                                          child: const Text('Зураг нэмэх',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600))),
                                      if (images.isNotEmpty)
                                        DefInputContainer(
                                            ontap: () => sendImage(home),
                                            width: Sizes.width * 0.35,
                                            child: const Text("Хадгалах",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600))),
                                    ],
                                  ),
                                if (isNotPharma)
                                  const SizedBox(height: Sizes.smallFontSize),
                                if (isNotPharma)
                                  if (images.isNotEmpty)
                                    DefInputContainer(
                                      child: Wrap(
                                        runSpacing: Sizes.smallFontSize,
                                        children: [
                                          ...images.map(
                                            (image) => Stack(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius: BorderRadius
                                                            .circular(Sizes
                                                                .smallFontSize)),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            Sizes
                                                                .smallFontSize),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: Sizes
                                                                .bigFontSize),
                                                    child: Image.file(image,
                                                        height:
                                                            Sizes.width * .2,
                                                        width:
                                                            Sizes.width * .2)),
                                                Positioned(
                                                    top: -10,
                                                    right: 0,
                                                    child: InkWell(
                                                        onTap: () =>
                                                            removeImage(image),
                                                        child: const Icon(
                                                            Icons.remove,
                                                            color: Colors.red)))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                const SizedBox(height: Sizes.bigFontSize),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            div,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                price(
                                    title: 'Үндсэн үнэ',
                                    value: maybeNull(
                                        widget.prod.price.toString())),
                                price(
                                    title: 'Бөөний үнэ',
                                    value: maybeNull(
                                        widget.prod.salePrice.toString()),
                                    cxs: CrossAxisAlignment.end),
                              ],
                            ),
                            CustomButton(
                              borderRadius: Sizes.smallFontSize,
                              padding: const EdgeInsets.symmetric(
                                  vertical: Sizes.mediumFontSize),
                              text: 'Сагслах',
                              ontap: () => showSheet(basket),
                            ),
                            const SizedBox(height: Sizes.mediumFontSize)
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  imageViewer() {
    if (det.containsKey('images') == true) {
      final pictures = det['images'] as List;
      return Container(
        padding: const EdgeInsets.all(Sizes.smallFontSize),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pictures
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: imageWidget('${dotenv.env['IMAGE_URL']}${p['url']}'),
                  ),
                )
                .toList(),
          ),
        ),
      );
    } else {
      return imageWidget(noImage);
    }
  }

  Widget imageWidget(String url) {
    return Image.network(
      url,
      height: Sizes.height * 0.25,
      width: Sizes.height * 0.25,
    );
  }

  sendImage(HomeProvider home) async {
    print(images.length);
    dynamic res = await home.uploadImage(id: widget.prod.id, images: images);
    message(res['message']);
    if (res['errorType'] == 0) {
      Navigator.pop(context);
    }
  }

  List<File> images = [];
  addImageToList(File image) {
    if (images.length > 5) {
      message('5 хүртэлт зураг оруулах боломжтой');
    } else {
      setState(() {
        images.add(image);
      });
    }
  }

  Future<void> pickLogo(ImageSource source) async {
    await Permission.storage.request();
    await Permission.camera.request();
    final pickedFile = await ImagePicker().pickImage(source: source);
    addImageToList(File(pickedFile!.path));
  }

  chooseImageSource() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Sizes.bigFontSize),
                topRight: Radius.circular(Sizes.bigFontSize))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              picker(
                  text: 'Зураг дарах',
                  icon: Icons.camera,
                  ontap: () =>
                      pickLogo(ImageSource.camera).then((g) => Get.back())),
              picker(
                  text: 'Зураг оруулах',
                  icon: Icons.image,
                  ontap: () =>
                      pickLogo(ImageSource.gallery).then((g) => Get.back())),
            ],
          ),
        ),
      ),
    );
  }

  Widget picker(
      {required String text,
      required IconData icon,
      required Function() ontap}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: Sizes.bigFontSize, horizontal: Sizes.bigFontSize * 2),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: Sizes.mediumFontSize),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  removeImage(File image) {
    setState(() {
      images.removeAt(images.indexOf(image));
    });
  }

  Widget price(
      {required String title, required String value, CrossAxisAlignment? cxs}) {
    return Column(
      crossAxisAlignment: cxs ?? CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: Sizes.smallFontSize + 2)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.mediumFontSize,
          ),
        ),
      ],
    );
  }

  Widget basketIcon(BasketProvider basket) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Center(
            child: Icon(
              Icons.shopping_cart,
              size: 24,
              color: theme.primaryColor,
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(15)),
            child: Text(
              basket.basket.totalCount.toString(),
              style: const TextStyle(
                color: white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
        initValue: '',
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
        Map<String, dynamic> res = await basketProvider.addProduct(
            product: widget.prod, qty: int.parse(initQTY));
        message(res['message']);
        if (res['errorType'] != 0) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
      message(wait);
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
          color: selected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.transparent : theme.primaryColor,
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

  Widget myTabView(
    List<String> list1,
    List<String> list2,
  ) {
    return Column(
      children: list1.map((i) => infoRow(i, list2[list1.indexOf(i)])).toList(),
    );
  }

  Widget infoRow(String title, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            softWrap: true,
            style: textStyle(color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            maybeNull(text),
            textAlign: TextAlign.end,
            maxLines: 2,
            softWrap: true,
            style: textStyle(),
          ),
        ),
      ],
    );
  }

  textStyle({Color? color}) {
    return TextStyle(
      color: color ?? Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: Sizes.smallFontSize + 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
