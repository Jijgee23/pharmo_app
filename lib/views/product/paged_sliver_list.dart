// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:pharmo_app/widgets/others/indicator.dart';
// import 'package:pharmo_app/widgets/others/no_items.dart';
// import 'package:pharmo_app/views/product/product_widget.dart';
// import 'package:pharmo_app/widgets/product_scrolls/paged_sliver_grid.dart';

// class CustomList extends StatelessWidget {
//   final PagingController<int, dynamic> pagingController;
//   const CustomList({super.key, required this.pagingController});

//   @override
//   Widget build(BuildContext context) {
//     return MyScroller(
//       c: PagedListView(
//         pagingController: pagingController,
//         builderDelegate: PagedChildBuilderDelegate<dynamic>(
//           firstPageErrorIndicatorBuilder: (context) {
//             pagingController.refresh();
//             return const MyIndicator();
//           },
//           firstPageProgressIndicatorBuilder: (context) {
//             pagingController.refresh();
//             return const MyIndicator();
//           },
//           noItemsFoundIndicatorBuilder: (context) => const NoItems(),
//           noMoreItemsIndicatorBuilder: (context) => const SizedBox(),
//           newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
//           newPageErrorIndicatorBuilder: (context) => const SizedBox(),
//           itemBuilder: (context, item, index) =>
//               ProductWidgetListView(item: item),
//         ),
//       ),
//     );
//   }
// }
