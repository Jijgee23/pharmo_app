import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/widgets/others/indicator.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:pharmo_app/views/product/product_widget.dart';

class CustomGrid extends StatefulWidget {
  final PagingController<int, dynamic> pagingController;
  final bool? hasSale;
  const CustomGrid({
    super.key,
    required this.pagingController,
    this.hasSale,
  });

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  PagedGridView<int, dynamic>(
        showNewPageProgressIndicatorAsGridChild: true,
        showNewPageErrorIndicatorAsGridChild: true,
        showNoMoreItemsIndicatorAsGridChild: true,
        pagingController: widget.pagingController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 480 ? 3 : 2,
        ),
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          newPageErrorIndicatorBuilder: (context) => const SizedBox(),
          newPageProgressIndicatorBuilder: (context) => const MyIndicator(),
          noItemsFoundIndicatorBuilder: (context) => const NoResult(),
          noMoreItemsIndicatorBuilder: (context) => const SizedBox(),
          firstPageErrorIndicatorBuilder: (context) {
            widget.pagingController.refresh();
            return const NoItems();
          },
          firstPageProgressIndicatorBuilder: (context) {
            widget.pagingController.refresh();
            return const MyIndicator();
          },
          animateTransitions: true,
          itemBuilder: (_, item, index) =>
              ProductWidget(item: item, hasSale: widget.hasSale),
        ),
      
    );
  }
}

// class MyScroller extends StatelessWidget {
//   final Widget c;
//   const MyScroller({super.key, required this.c});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeProvider>(
//       builder: (context, home, child) => NotificationListener(
//         onNotification: (notification) {
//           if (notification is ScrollUpdateNotification &&
//               notification.scrollDelta! < 0) {
//             home.setScrolling(false);
//           } else if (notification is ScrollUpdateNotification &&
//               notification.scrollDelta! > 0) {
//             if (notification.metrics.atEdge) {
//               home.setScrolling(false);
//             } else {
//               home.setScrolling(true);
//             }
//           }
//           return true;
//         },
//         child: c,
//       ),
//     );
//   }
// }
