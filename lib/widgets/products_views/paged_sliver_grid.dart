// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';
import 'package:provider/provider.dart';

class CustomGridView extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  const CustomGridView({super.key, required this.pagingController});

  @override
  Widget build(BuildContext context) {
    return PagedSliverGrid<int, dynamic>(
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
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
          return const MyIndicator();
        },
        firstPageProgressIndicatorBuilder: (context) {
          pagingController.refresh();
          return const MyIndicator();
        },
        animateTransitions: true,
        itemBuilder: (_, item, index) => ProductWidget(
          item: item,
          onTap: () => goto(ProductDetail(prod: item), context),
          onButtonTab: () => addBasket(item.id, item.itemname_id, context),
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
}
