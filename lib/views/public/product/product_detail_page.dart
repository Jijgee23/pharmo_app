import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/utilities/api.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/controller/models/products.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
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
  late TabController tabController;
  bool fetching = false;
  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  bool playing = true;
  togglePlay() {
    setState(() {
      playing = !playing;
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
      final response = await api(Api.get, 'products/${widget.prod.id}/');
      if (response!.statusCode == 200) {
        Map<String, dynamic> data = convertData(response);
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

  final CarouselSliderController slideController = CarouselSliderController();
  int maxLines = 2;

  @override
  Widget build(BuildContext context) {
    final div = Divider(color: theme.primaryColor, thickness: .7);

    final details = {
      'Барааны дуусах хугацаа': det['expDate'].toString(),
      'Ерөнхий нэршил': det['intName'].toString(),
      'Тун хэмжээ': '',
      'Хөнгөлөлт': '',
      'Хэлбэр': '',
      'Мастер савалгааны тоо': det['master_box_qty'].toString(),
      'Олгох нөхцөл': '',
      'Улс': '',
      'Үйлдвэрлэгч': det['vndr'] != null ? det['vndr']['name'] : '',
      'Бөөний үнэ': toPrice(det['sale_price'].toString()),
      'Бөөний тоо': det['sale_qty'].toString(),
      'Хямдрал': toPrice(det['discount'].toString()),
      'Хямдрал дуусах хугацаа': det['discount_expiredate'].toString()
    };

    return Consumer2<BasketProvider, HomeProvider>(
      builder: (context, basket, home, child) {
        bool isNotPharma =
            (LocalBase.security != null && LocalBase.security!.role != 'PA');
        if (fetching) {
          return const Center(child: PharmoIndicator());
        } else {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [imageBar(context, basket, home, isNotPharma)];
              },
              body: Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nameBuilder(),
                      if (widget.prod.barcode != null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: SelectableText(
                            '#${widget.prod.barcode.toString()}',
                            style: const TextStyle(
                                color: black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      div,
                      ...details.entries.map((det) =>
                          DetailText(title: det.key, value: det.value)),
                      if (isNotPharma)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DefInputContainer(
                                ontap: () => chooseImageSource(),
                                width: Sizes.width * 0.35,
                                child: const Text('Зураг нэмэх',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600))),
                            if (images.isNotEmpty)
                              DefInputContainer(
                                  ontap: () => sendImage(home),
                                  width: Sizes.width * 0.35,
                                  child: const Text("Хадгалах",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600))),
                          ],
                        ),
                      if (isNotPharma) const SizedBox(height: 10),
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Sizes.smallFontSize)),
                                          padding: const EdgeInsets.all(
                                              Sizes.smallFontSize),
                                          margin: const EdgeInsets.only(
                                              right: Sizes.bigFontSize),
                                          child: Image.file(image,
                                              height: Sizes.width * .2,
                                              width: Sizes.width * .2)),
                                      Positioned(
                                        top: -10,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => removeImage(image),
                                          child: const Icon(Icons.remove,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
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
                                  value: toPrice(widget.prod.price.toString())),
                              price(
                                  title: 'Бөөний үнэ',
                                  value:
                                      toPrice(widget.prod.salePrice.toString()),
                                  cxs: CrossAxisAlignment.end),
                            ],
                          ),
                          const SizedBox(height: Sizes.mediumFontSize),
                          CustomButton(
                            borderRadius:
                                Sizes.bigFontSize + Sizes.smallFontSize,
                            padding: const EdgeInsets.symmetric(
                                vertical: Sizes.mediumFontSize),
                            text: 'Сагслах',
                            ontap: () => showSheet(basket),
                          ),
                          const SizedBox(height: Sizes.mediumFontSize)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  SliverAppBar imageBar(BuildContext context, BasketProvider basket,
      HomeProvider home, bool isNotPharma) {
    return SliverAppBar(
      leading: const ChevronBack(),
      expandedHeight: context.width * 0.6,
      backgroundColor: white,
      actions: [addIcon(basket), basketIcon(basket)],
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: imageViewer(home, isNotPharma),
        ),
      ),
    );
  }

  InkWell nameBuilder() {
    return InkWell(
      onTap: () => setState(() {
        if (maxLines == 2) {
          maxLines = 5;
        } else {
          maxLines = 2;
        }
      }),
      child: Text(
        widget.prod.name.toString(),
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xff3F414E),
          fontSize: 28,
          fontWeight: FontWeight.w700,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  imageViewer(HomeProvider home, bool isNotPharma) {
    if (det.containsKey('images') == true) {
      final pictures = det['images'] as List;
      return Center(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(Sizes.smallFontSize),
              child: CarouselSlider(
                carouselController: slideController,
                items: pictures
                    .map(
                      (p) => Stack(
                        children: [
                          imageWidget('${dotenv.env['IMAGE_URL']}$p'),
                          if (isNotPharma == true)
                            Positioned(
                              right: 3,
                              bottom: 3,
                              child: InkWell(
                                onTap: () => deleteImage(home, p),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.delete,
                                      color: white, size: 30),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  viewportFraction: 1,
                  autoPlay: pictures.length > 1,
                  autoPlayAnimationDuration: duration,
                  pauseAutoPlayOnTouch: true,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return imageWidget(noImage);
    }
  }

  Widget imageWidget(String url) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(10)),
      child: Image.network(
        url,
        height: Sizes.height * 0.25,
        width: Sizes.height * 0.25,
        fit: BoxFit.cover,
      ),
    );
  }

  sendImage(HomeProvider home) async {
    print(images.length);
    dynamic res = await home.uploadImage(id: widget.prod.id, images: images);
    message(res['message']);
    if (res['errorType'] == 0) {
      await getProductDetail();
      home.refresh(context);
      clearImages();
    }
  }

  List<File> images = [];

  Future<void> pickLogo(ImageSource source) async {
    try {
      if (await Permission.camera.isDenied ||
          await Permission.storage.isDenied) {
        await Permission.camera.request();
        await Permission.storage.request();
      }
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        File i = await compressImage(imageFile);
        if (images.length > 5) {
          message('5 хүртэлт зураг оруулах боломжтой');
        } else {
          setState(() {
            images.add(i);
          });
        }
      } else {
        message("Зураг сонгоно уу!");
      }
    } catch (e) {
      message("Зураг сонгох үед алдаа гарлаа! ${e.toString()}");
    }
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
                  ontap: () {
                    pickLogo(ImageSource.camera);
                    Navigator.pop(context);
                  }),
              picker(
                  text: 'Зураг оруулах',
                  icon: Icons.image,
                  ontap: () {
                    pickLogo(ImageSource.gallery);
                    Navigator.pop(context);
                  })
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

  clearImages() {
    setState(() {
      images.clear();
    });
  }

  deleteImage(HomeProvider home, int id) async {
    dynamic res = await home.deleteImages(id: widget.prod.id, imageID: id);
    message(res['message']);
    if (res['errorType'] == 0) {
      await getProductDetail();
      home.refresh(context);
    }
  }

  Widget price(
      {required String title, required String value, CrossAxisAlignment? cxs}) {
    return Column(
      crossAxisAlignment: cxs ?? CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget basketIcon(BasketProvider basket) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.only(right: 10),
          child: const Center(
            child: Icon(
              Icons.shopping_cart,
              size: 24,
              color: white,
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
              basket == null ? '0' : basket.basket!.totalCount.toString(),
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

  Widget addIcon(BasketProvider basket) {
    return InkWell(
      onTap: () => showSheet(basket),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        margin: const EdgeInsets.only(right: 10),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 24,
            color: white,
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
        await basketProvider
            .addProduct(widget.prod.id, widget.prod.name!, int.parse(initQTY))
            .then(
              (v) => Navigator.pop(context),
            );
      }
    } catch (e) {
      print(e);
      message(wait);
    }
    Navigator.pop(context);
  }
}

class DetailText extends StatefulWidget {
  final String title;
  final String? value;
  const DetailText({super.key, required this.title, this.value});

  @override
  State<DetailText> createState() => _DetailTextState();
}

class _DetailTextState extends State<DetailText> {
  @override
  Widget build(BuildContext context) {
    bool isNotNull =
        widget.value != null && widget.value != '' && widget.value != "null";
    if (isNotNull) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(widget.title, color: black.withOpacity(.8)),
            if (isNotNull) text(maybeNull(widget.value), fs: 14)
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  text(String text, {Color? color, double? fs}) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      softWrap: true,
      style: TextStyle(
        color: color ?? Colors.grey.shade600,
        fontWeight: FontWeight.bold,
        fontSize: fs ?? 16,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
