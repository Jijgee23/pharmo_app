import 'package:pharmo_app/views/promotion/marked_promo_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmo_app/application/application.dart';

class BuyingPromoOnDialog extends StatefulWidget {
  final MarkedPromo promo;
  const BuyingPromoOnDialog({super.key, required this.promo});

  @override
  State<BuyingPromoOnDialog> createState() => _BuyingPromoOnDialogState();
}

class _BuyingPromoOnDialogState extends State<BuyingPromoOnDialog> {
  int selectedBranch = 0;
  final TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;
    bool hasBundle = (promo.bundles != null);
    bool hasGift = (promo.gift != null);
    var myColor = Colors.red.shade600;
    var box = const SizedBox(height: 10);
    return Consumer2<PromotionProvider, HomeProvider>(
      builder: (context, promotionProvider, home, child) => Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () =>
                          promotionProvider.hidePromo(promo.id!, context),
                      child: text('Дахиж харахгүй', color: black)),
                ),
                text(promo.name!),
                if (promo.desc != null) text(promo.desc!),
                if (hasBundle)
                  Column(
                    children: [
                      text('Багц:'),
                      const SizedBox(height: 10),
                      if (hasBundle)
                        GridView.builder(
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
                                promo.bundles?[index], noImage, context);
                          },
                          itemCount: promo.bundles?.length,
                        ),
                    ],
                  ),
                if (hasBundle)
                  Column(
                    children: [
                      text('Багцийн үнэ:'),
                      text(maybeNull(promo.bundlePrice.toString())),
                      box,
                    ],
                  ),
                if (hasGift)
                  Column(
                    children: [
                      Icon(Icons.add, color: Colors.grey.shade900, size: 30),
                      box,
                      text('Бэлэг:'),
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
                          return product(promo.gift?[index], noImage, context);
                        },
                        itemCount: promo.gift?.length,
                      )
                    ],
                  ),
                if (promo.endDate != null)
                  SectionCard(
                    title: 'Урамшуулал дуусах хугацаа',
                    child: Column(
                      children: [
                        box,
                        text(promo.endDate!.substring(0, 10),
                            color: myColor, size: 20),
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: CustomButton(
                    ontap: () => promotionProvider.setOrderStarted(),
                    text:
                        promotionProvider.orderStarted ? 'Цуцлах' : 'Захиалах',
                  ),
                ),
                if (promotionProvider.orderStarted)
                  Column(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text('Нийт тоо, ширхэг:'),
                              text(solveQTY().toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text('Үнийн дүн:'),
                              text(toPrice(promotionProvider
                                  .promoDetail.bundlePrice
                                  .toString())),
                            ],
                          )
                        ],
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
                                    : context.theme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    promotionProvider.setDelivery(false),
                                child: const Center(child: Text('Хүргэлтээр')),
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
                                    : context.theme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    promotionProvider.setDelivery(true),
                                child: const Center(child: Text('Очиж авах')),
                              ),
                            ),
                          )
                        ],
                      ),
                      box,
                      promotionProvider.delivery
                          ? const SizedBox()
                          : SectionCard(
                              title: 'Салбар сонгох',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    : context.theme.primaryColor,
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
                                    : context.theme.primaryColor,
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
                          child: Text('Нэмэлт тайлбар',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor))),
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
                                    onTap: () => promotionProvider
                                        .setBank(!promotionProvider.useBank),
                                    child: const Text(
                                      'Банкны аппаар төлөх',
                                      style: TextStyle(color: AppColors.main),
                                    )),
                                !promotionProvider.useBank
                                    ? const SizedBox()
                                    : SizedBox(
                                        width: double.infinity,
                                        child: Scrollbar(
                                          thickness: 1,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                                children:
                                                    promotionProvider
                                                                .qrData.urls !=
                                                            null
                                                        ? promotionProvider
                                                            .qrData.urls!
                                                            .map((e) => InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .blue
                                                                          .shade100,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  onTap:
                                                                      () async {
                                                                    bool found =
                                                                        await canLaunchUrl(
                                                                            Uri.parse(e.link!));
                                                                    if (found) {
                                                                      await launchUrl(
                                                                          Uri.parse(e
                                                                              .link!),
                                                                          mode:
                                                                              LaunchMode.externalApplication);
                                                                    } else {
                                                                      messageWarning(
                                                                          '${e.description!} банкны апп олдсонгүй.');
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                          margin: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          child:
                                                                              Image.network(
                                                                            e.logo!,
                                                                            width:
                                                                                60,
                                                                          )),
                                                                ))
                                                            .toList()
                                                        : []),
                                          ),
                                        ),
                                      ),
                                box,
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: CustomButton(
                                    ontap: () =>
                                        promotionProvider.checkPayment(context),
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
                  : context.theme.primaryColor,
            ),
            Constants.boxH10,
            Text(e.name),
          ],
        ),
      ),
    );
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
}

product(e, String noImage, BuildContext context) {
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [Constants.defaultShadow]),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    scale: 1,
                    image: NetworkImage(noImage),
                  ),
                ),
              ),
            ),
            Text(
              e['name'] != null ? e['name'].toString() : '-',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
      ),
      Positioned(
        right: 3,
        top: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'x ${e['qty']}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
    ],
  );
}
