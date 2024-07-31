import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MarkedPromoWidget extends StatelessWidget {
  MarkedPromo promo;
  MarkedPromoWidget({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    String noImage =
        'https://st4.depositphotos.com/14953852/24787/v/380/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    var box = const SizedBox(height: 10);
    return Consumer<BasketProvider>(
      builder: (_, basket, child) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 20,
          title: Text(promo.name!,
              style: const TextStyle(fontSize: 16, color: AppColors.main)),
          centerTitle: true,
          leading: const ChevronBack(),
        ),
        body: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Center(child: Text(promo.desc ?? '-')),
                ),
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return product(promo.bundles?[index], noImage);
                        },
                        itemCount: promo.bundles?.length,
                      )
                    : const SizedBox(),
                box,
                const Text('Багцийн үнэ:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    promo.bundlePrice != null
                        ? promo.bundlePrice.toString()
                        : '-',
                    style: textStyle),
                box,
                Icon(Icons.add, color: Colors.grey.shade900, size: 30),
                box,
                const Text('Бэлэг:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                box,
                promo.gift != null
                    ? GridView.builder(
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
                    : const SizedBox(),
                box,
                const Text('Урамшуулал дуусах хугацаа:'),
                Text(
                    promo.endDate != null
                        ? promo.endDate!.substring(0, 10)
                        : '-',
                    style: textStyle),
                box,
                CustomButton(
                    text: 'Захиалах',
                    ontap: () {
                      //   basket.clearBasket(basket_id: basket.basket.id);
                      promo.bundles
                          ?.map((e) => addBasket(e['id'], e['qtyId'], context));
                      // promo.gift?.map(
                      //     (e) => basket.addBasket(qty: 1, product_id: e['id']));
                      // goto(const ShoppingCart(), context);
                      goto(const ShoppingCart(), context);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addBasket(int? id, int? itemnameId, BuildContext context) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: id, itemname_id: itemnameId, qty: 1);
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа', context: context);
    }
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
