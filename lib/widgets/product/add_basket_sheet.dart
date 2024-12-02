import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

class AddBasketSheet extends StatefulWidget {
  final Product product;
  const AddBasketSheet({super.key, required this.product});

  @override
  State<AddBasketSheet> createState() => _AddBasketSheetState();
}

class _AddBasketSheetState extends State<AddBasketSheet> {
  late TextEditingController qty;

  @override
  void initState() {
    super.initState();
    qty = TextEditingController();
  }

  @override
  void dispose() {
    qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.product.name!} /${toPrice(widget.product.price)}/',
                  softWrap: true,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontSize: fs,
                  ),
                ),
                InkWell(
                  onTap: Get.back,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade700,
                        ),
                        borderRadius: BorderRadius.circular(50)),
                    child: Image.asset(
                      'assets/cross-small.png',
                      height: 16,
                      color: Colors.black.withOpacity(.5),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              autofocus: true,
              textAlign: TextAlign.end,
              controller: qty,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontSize: fs,
              ),
              decoration: InputDecoration(
                hintText: 'Тоо ширхэг оруулна уу!',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CustomButton(
              text: 'Сагсанд нэмэх',
              ontap: () {
                if (qty.text.isNotEmpty && int.parse(qty.text) > 0) {
                  addBasket(widget.product, context, int.parse(qty.text))
                      .then((e) => Get.back());
                } else if (qty.text.isEmpty) {
                  message(message: 'Тоо ширхэг оруулна уу!', context: context);
                } else {
                  message(
                      message: 'Тоо ширхэг 0 байж болохгүй!', context: context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future addBasket(dynamic item, BuildContext context, int qty) async {
  //   try {
  //     final basketProvider =
  //         Provider.of<BasketProvider>(context, listen: false);
  //     Map<String, dynamic> res = await basketProvider.addBasket(
  //         productId: item.id, itemnameId: item.itemnameId, qty: qty);
  //     if (res['errorType'] == 1) {
  //       basketProvider.getBasket();
  //       message(message: '${item.name} сагсанд нэмэгдлээ', context: context);
  //     } else {
  //       message(message: res['message'], context: context);
  //     }
  //   } catch (e) {
  //     message(message: 'Алдаа гарлаа', context: context);
  //     print('addbasket error: $e');
  //   }
  // }
  Future<void> addBasket(dynamic item, BuildContext context, int qty) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
        productId: item.id,
        itemnameId: item.itemnameId,
        qty: qty,
      );
      switch (res['errorType']) {
        case 1:
          basketProvider.getBasket();
          message(message: '${item.name} сагсанд нэмэгдлээ', context: context);
          break;

        default:
          message(message: res['message'], context: context);
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('Stack Trace: $stackTrace');
      message(message: 'Алдаа гарлаа. Дахин оролдоно уу!', context: context);
    }
  }
}
