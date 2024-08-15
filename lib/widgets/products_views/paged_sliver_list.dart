import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget_list.dart';
import 'package:provider/provider.dart';

class CustomListView extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  const CustomListView({super.key, required this.pagingController});

  @override
  Widget build(BuildContext context) {
    return PagedSliverList(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
          firstPageErrorIndicatorBuilder: (context) {
            pagingController.refresh();
            return const MyIndicator();
          },
          firstPageProgressIndicatorBuilder: (context) {
            pagingController.refresh();
            return const MyIndicator();
          },
          noItemsFoundIndicatorBuilder: (context) => const NoItems(),
          itemBuilder: (context, item, index) => ProductWidgetListView(
                onTap: () => goto(ProductDetail(prod: item), context),
                item: item,
                onButtonTab: () =>
                    addBasket(item.id, item.itemname_id, context),
              ),
          newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
          newPageErrorIndicatorBuilder: (context) => const MyIndicator()),
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
