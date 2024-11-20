// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget_list.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';

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
                onTap: () => goto(ProductDetail(prod: item)),
                item: item,
                onButtonTab: () =>
                    Get.bottomSheet(AddBasketSheet(product: item)),
              ),
          newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
          newPageErrorIndicatorBuilder: (context) => const MyIndicator()),
    );
  }
}
