
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Consumer2<HomeProvider, PromotionProvider>(
      builder: (_, home, promotionProvider, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ChevronBack(),
              Text(widget.promo.name!,
                  style: const TextStyle(fontSize: 16, color: AppColors.main)),
              (widget.promo.isMarked == true)
                  ? InkWell(
                      onTap: () => promotionProvider
                          .hidePromo(widget.promo.id!, context)
                          .then((e) => Navigator.pop(context)),
                      child: const Text('Дахиж харахгүй',
                          style: TextStyle(fontSize: 14)),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        body: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.promo.desc != null
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(widget.promo.desc ?? ''),
                      )
                    : const SizedBox(),
                widget.promo.bundles != null
                    ? Column(
                        children: [
                          const Text('Багц:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          box,
                          widget.promo.bundles != null
                              ? GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return product(
                                        widget.promo.bundles?[index], noImage);
                                  },
                                  itemCount: widget.promo.bundles?.length,
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const SizedBox(),
                box,
                widget.promo.bundlePrice != null
                    ? Column(
                        children: [
                          const Text('Багцийн үнэ:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              widget.promo.bundlePrice != null
                                  ? widget.promo.bundlePrice.toString()
                                  : '-',
                              style: textStyle),
                          box,
                        ],
                      )
                    : const SizedBox(),
                widget.promo.gift != null
                    ? Column(
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
                              return product(
                                  widget.promo.gift?[index], noImage);
                            },
                            itemCount: widget.promo.gift?.length,
                          )
                        ],
                      )
                    : const SizedBox(),
                widget.promo.endDate != null
                    ? Column(
                        children: [
                          box,
                          const Text('Урамшуулал дуусах хугацаа:'),
                          Text(widget.promo.endDate!.substring(0, 10),
                              style: textStyle),
                        ],
                      )
                    : const SizedBox(),
                box,
                InkWell(
                  onTap: () => promotionProvider.setOrderStarted(),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                            promotionProvider.orderStarted
                                ? 'Цуцлах'
                                : 'Захиалах',
                            style: const TextStyle(color: Colors.white)),
                      )),
                ),
                box,
                (promotionProvider.orderStarted == false)
                    ? const SizedBox()
                    : Column(
                        children: [
                          Column(
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
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: promotionProvider.delivery
                                      ? Colors.grey.shade300
                                      : AppColors.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      promotionProvider.setDelivery(false),
                                  child: const Text('Хүргэлтээр'),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: !promotionProvider.delivery
                                      ? Colors.grey.shade300
                                      : AppColors.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      promotionProvider.setDelivery(true),
                                  child: const Text('Очиж авах'),
                                ),
                              )
                            ],
                          ),
                          box,
                          promotionProvider.delivery
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: home.branches
                                      .map(
                                        (e) => Column(
                                          children: [
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              splashColor:
                                                  Colors.green.shade100,
                                              onTap: () => setState(
                                                  () => selectedBranch = e.id),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.home,
                                                      color:
                                                          selectedBranch == e.id
                                                              ? Colors.green
                                                              : Colors.grey
                                                                  .shade300,
                                                    ),
                                                    Text(e.name!),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5)
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                          box,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: !promotionProvider.isCash
                                      ? Colors.grey.shade300
                                      : AppColors.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    promotionProvider.setPayType();
                                    promotionProvider.setIsCash(true);
                                  },
                                  child: const Text('Бэлнээр'),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: promotionProvider.isCash
                                      ? Colors.grey.shade300
                                      : AppColors.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    promotionProvider.setPayType();
                                    promotionProvider.setIsCash(false);
                                  },
                                  child: const Text('Зээлээр'),
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
                              child: const Text('Нэмэлт тайлбар',
                                  style: TextStyle(color: AppColors.main))),
                          box,
                          !promotionProvider.hasNote
                              ? const SizedBox()
                              : CustomTextField(
                                  hintText: 'Тайлбар', controller: note),
                          box,
                          InkWell(
                            onTap: () {
                              promotionProvider.orderPromo(widget.promo.id!,
                                  selectedBranch, note.text, context);
                            },
                            child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.main,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('Баталгаажуулах',
                                      style: TextStyle(color: Colors.white)),
                                )),
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
                                                                              showFailedMessage(message: '${e.description!} банкны апп олдсонгүй.', context: context);
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
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      decoration: BoxDecoration(
                                          color: AppColors.main,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: InkWell(
                                        onTap: () {
                                          promotionProvider
                                              .checkPayment(context);
                                        },
                                        child: const Center(
                                            child: Text(
                                          'Төлбөр шалгах',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    ),
                                    box,
                                  ],
                                ),
                        ],
                      )
              ],
            )),
          ),
        ),
      ),
    );
  }

  Container product(e, String noImage) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.secondary),
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
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
        ));
  }
}
