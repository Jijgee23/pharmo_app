import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/sector.dart';

// ignore: must_be_immutable
class MarkedPromoWidget extends StatefulWidget {
  MarkedPromo promo;
  MarkedPromoWidget({super.key, required this.promo});

  @override
  State<MarkedPromoWidget> createState() => _MarkedPromoWidgetState();
}

class _MarkedPromoWidgetState extends State<MarkedPromoWidget> {
  int selectedBranch = 0;
  late PromotionProvider promotionProvider;
  MarkedPromo detail = MarkedPromo();
  final TextEditingController note = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      promotionProvider.dis();
      note.dispose();
    });
  }

  @override
  void initState() {
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    solveTotal();
    super.initState();
  }

  solveQTY() {
    int blenght =
        widget.promo.bundles != null ? widget.promo.bundles!.length : 0;
    int glength = widget.promo.gift != null ? widget.promo.gift!.length : 0;
    int qty = blenght + glength;
    return qty;
  }

  solveTotal() {
    double total = 0;
    double tbundle = widget.promo.bundles!.fold(
        0.0,
        (previousValue, element) =>
            total = total + (element['price'] * element['qty']));
    return tbundle;
  }

  @override
  Widget build(BuildContext context) {
    String noImage =
        'https://st4.depositphotos.com/14953852/24787/v/380/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    var box = const SizedBox(height: 10);
    final promo = widget.promo;
    return Consumer2<HomeProvider, PromotionProvider>(
      builder: (_, home, promotionProvider, child) => Scaffold(
        backgroundColor: theme.primaryColor,
        extendBody: true,
        body: DefaultBox(
          title: promo.name!,
          child: SingleChildScrollView(
            child: Column(
              children: [
                (promo.desc != null)
                    ? Box(
                        child: Text(promo.desc!),
                      )
                    : const SizedBox(),
                promo.bundles != null
                    ? Box(
                        child: Column(
                          children: [
                            const Text('Багц:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            box,
                            promo.bundles != null
                                ? GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return product(
                                          promo.bundles?[index], noImage);
                                    },
                                    itemCount: promo.bundles?.length,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(),
                (promo.bundlePrice != null)
                    ? Box(
                        child: Column(
                          children: [
                            const Text('Багцийн үнэ:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                promo.bundlePrice != null
                                    ? promo.bundlePrice.toString()
                                    : '-',
                                style: textStyle),
                            box,
                          ],
                        ),
                      )
                    : const SizedBox(),
                (promo.gift != null)
                    ? Box(
                        child: Column(
                          children: [
                            Icon(Icons.add,
                                color: Colors.grey.shade900, size: 30),
                            box,
                            const Text('Бэлэг:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            box,
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return product(promo.gift?[index], noImage);
                              },
                              itemCount: promo.gift?.length,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
                promo.endDate != null
                    ? Box(
                        child: Column(
                          children: [
                            box,
                            const Text('Урамшуулал дуусах хугацаа:'),
                            Text(promo.endDate!.substring(0, 10),
                                style: textStyle),
                          ],
                        ),
                      )
                    : const SizedBox(),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: CustomButton(
                    ontap: () => promotionProvider.setOrderStarted(),
                    text:
                        promotionProvider.orderStarted ? 'Цуцлах' : 'Захиалах',
                  ),
                ),
                (promotionProvider.orderStarted == false)
                    ? const SizedBox()
                    : Column(
                        children: [
                          Box(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Нийт тоо, ширхэг:'),
                                    Text(solveQTY().toString()),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Үнийн дүн:'),
                                    Text(
                                        '${promotionProvider.promoDetail.bundlePrice.toString()}₮'),
                                  ],
                                )
                              ],
                            ),
                          ),
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: promotionProvider.delivery
                                        ? Colors.grey.shade300
                                        : theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        promotionProvider.setDelivery(false),
                                    child:
                                        const Center(child: Text('Хүргэлтээр')),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: !promotionProvider.delivery
                                        ? Colors.grey.shade300
                                        : theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        promotionProvider.setDelivery(true),
                                    child:
                                        const Center(child: Text('Очиж авах')),
                                  ),
                                ),
                              )
                            ],
                          ),
                          box,
                          promotionProvider.delivery
                              ? const SizedBox()
                              : Box(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: home.branches
                                        .map((e) => branch(e))
                                        .toList(),
                                  ),
                                ),
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: !promotionProvider.isCash
                                        ? Colors.grey.shade300
                                        :theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      promotionProvider.setPayType();
                                      promotionProvider.setIsCash(true);
                                    },
                                    child: const Center(child: Text('Бэлнээр')),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: promotionProvider.isCash
                                        ? Colors.grey.shade300
                                        : theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      promotionProvider.setPayType();
                                      promotionProvider.setIsCash(false);
                                    },
                                    child: const Center(child: Text('Зээлээр')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          box,
                          InkWell(
                              borderRadius: BorderRadius.circular(10),
                              splashColor: Colors.blue.shade100,
                              onTap: () => promotionProvider
                                  .setHasnote(!promotionProvider.hasNote),
                              child:  Text('Нэмэлт тайлбар',
                                  style: TextStyle(color: theme.primaryColor))),
                          box,
                          !promotionProvider.hasNote
                              ? const SizedBox()
                              : CustomTextField(
                                  hintText: 'Тайлбар', controller: note),
                          box,
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: CustomButton(
                              ontap: () {
                                promotionProvider.orderPromo(widget.promo.id!,
                                    selectedBranch, note.text, context);
                              },
                              text: 'Баталгаажуулах',
                            ),
                          ),
                          box,
                          !promotionProvider.showQr
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    const Text(
                                      'Дараах QR кодыг уншуулж төлбөр төлснөөр захиалга баталгаажна',
                                      textAlign: TextAlign.center,
                                    ),
                                    Center(
                                        child: QrImageView(
                                      data: promotionProvider.qrData.qrTxt!,
                                      size: 250,
                                    )),
                                    InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        splashColor: Colors.blue.shade100,
                                        onTap: () => promotionProvider.setBank(
                                            !promotionProvider.useBank),
                                        child: const Text(
                                          'Банкны аппаар төлөх',
                                          style:
                                              TextStyle(color: AppColors.main),
                                        )),
                                    !promotionProvider.useBank
                                        ? const SizedBox()
                                        : SizedBox(
                                            width: double.infinity,
                                            child: Scrollbar(
                                              thickness: 1,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                    children:
                                                        promotionProvider.qrData
                                                                    .urls !=
                                                                null
                                                            ? promotionProvider
                                                                .qrData.urls!
                                                                .map(
                                                                    (e) =>
                                                                        InkWell(
                                                                          splashColor: Colors
                                                                              .blue
                                                                              .shade100,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          onTap:
                                                                              () async {
                                                                            bool
                                                                                found =
                                                                                await canLaunchUrl(Uri.parse(e.link!));
                                                                            if (found) {
                                                                              await launchUrl(Uri.parse(e.link!), mode: LaunchMode.externalApplication);
                                                                            } else {
                                                                              message('${e.description!} банкны апп олдсонгүй.');
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                              margin: const EdgeInsets.all(10),
                                                                              child: Image.network(
                                                                                e.logo!,
                                                                                width: 60,
                                                                              )),
                                                                        ))
                                                                .toList()
                                                            : []),
                                              ),
                                            ),
                                          ),
                                    box,
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: CustomButton(
                                        ontap: () => promotionProvider
                                            .checkPayment(context),
                                        text: 'Төлбөр шалгах',
                                      ),
                                    ),
                                    box,
                                  ],
                                ),
                        ],
                      )
              ],
            ),
          ),
        ),

        //
        //     )),
        //   ),
        // ),
      ),
    );
  }

  Widget branch(Sector e) {
    return InkWell(
      onTap: () => setState(() => selectedBranch = e.id),
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
        decoration: BoxDecoration(
          boxShadow: [Constants.defaultShadow],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home,
              color: selectedBranch == e.id
                  ? AppColors.secondary
                  : Theme.of(context).primaryColor,
            ),
            Constants.boxH10,
            Text(e.name!),
          ],
        ),
      ),
    );
  }

  Container product(e, String noImage) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [Constants.defaultShadow],
        color: Colors.white
      ),
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    scale: 1,
                    image: NetworkImage(noImage),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              e['name'] != null ? e['name'].toString() : '-',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${e['price'] != null ? e['price'].toString() : '-'} ₮',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
