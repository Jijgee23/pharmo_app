import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';

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
          item: item,
        ),
        newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
        newPageErrorIndicatorBuilder: (context) => const MyIndicator(),
      ),
    );
  }
}

class CustomList extends StatelessWidget {
  final PagingController<int, dynamic> pagingController;
  const CustomList({super.key, required this.pagingController});

  @override
  Widget build(BuildContext context) {
    return PagedListView(
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
          item: item,
        ),
        newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
        newPageErrorIndicatorBuilder: (context) => const MyIndicator(),
      ),
    );
  }
}
