// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';
import 'package:provider/provider.dart';

class CustomGridView extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  final bool? hasSale;
  const CustomGridView(
      {super.key, required this.pagingController, this.hasSale});

  @override
  Widget build(BuildContext context) {
    return PagedSliverGrid<int, dynamic>(
      showNewPageProgressIndicatorAsGridChild: true,
      showNewPageErrorIndicatorAsGridChild: true,
      showNoMoreItemsIndicatorAsGridChild: true,
      pagingController: pagingController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 480 ? 3 : 2,
      ),
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        newPageErrorIndicatorBuilder: (context) => const MyIndicator(),
        newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
        noItemsFoundIndicatorBuilder: (context) => const NoItems(),
        firstPageErrorIndicatorBuilder: (context) {
          pagingController.refresh();
          return const NoItems();
        },
        firstPageProgressIndicatorBuilder: (context) {
          pagingController.refresh();
          return const MyIndicator();
        },
        animateTransitions: true,
        itemBuilder: (_, item, index) => ProductWidget(
          item: item,
          hasSale: hasSale,
          onTap: () => goto(ProductDetail(prod: item)),
          onButtonTab: () => Get.bottomSheet(
            AddBasketSheet(product: item),
          ),
        ),
      ),
    );
  }
}

class AddBasketSheet extends StatelessWidget {
  final Product product;
  const AddBasketSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final TextEditingController qty = TextEditingController();
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
                  '${product.name!} /${toPrice(product.price)}/',
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
                  addBasket(product, context, int.parse(qty.text))
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

  Future addBasket(dynamic item, BuildContext context, int qty) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: item.id, itemname_id: item.itemname_id, qty: qty);
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
        message(message: '${item.name} сагсанд нэмэгдлээ', context: context);
      } else {
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(message: 'Алдаа гарлаа', context: context);
    }
  }
}
