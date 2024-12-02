// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';

class CustomGridView extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  final bool? hasSale;
  const CustomGridView({
    super.key,
    required this.pagingController,
    this.hasSale,
  });

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
        itemBuilder: (_, item, index) =>
            ProductWidget(item: item, hasSale: hasSale),
      ),
    );
  }
}

class CustomGrid extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  final bool? hasSale;
  const CustomGrid({
    super.key,
    required this.pagingController,
    this.hasSale,
  });

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, dynamic>(
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
        itemBuilder: (_, item, index) =>
            ProductWidget(item: item, hasSale: hasSale),
      ),
    );
  }
}
