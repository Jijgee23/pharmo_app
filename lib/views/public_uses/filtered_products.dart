// ignore_for_file: use_build_context_synchronously

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/widgets/no_items.dart';
import 'package:pharmo_app/widgets/product_widget.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class FilteredProducts extends StatefulWidget {
  final String? type;
  final int filterKey;
  final String title;
  const FilteredProducts(
      {super.key,
      required this.type,
      required this.filterKey,
      required this.title});

  @override
  State<FilteredProducts> createState() => _FilteredProductsState();
}

class _FilteredProductsState extends State<FilteredProducts> {
  final String noImageUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg';
  final int _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  late HomeProvider homeProvider;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      if (widget.type == 'category') {
        _fetchByCategory(widget.filterKey, pageKey);
      } else {
        _fetchByMnfrsOrVndrs(widget.type!, widget.filterKey, pageKey);
      }
    });
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () {
                goto(const ShoppingCart(), context);
              },
              child: badges.Badge(
                badgeContent: Text(
                  "${basketProvider.count}",
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.blue,
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            //
            PagedSliverGrid<int, dynamic>(
              showNewPageProgressIndicatorAsGridChild: false,
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              pagingController: _pagingController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              ),
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                animateTransitions: true,
                itemBuilder: (_, item, index) => ProductWidget(
                  item: item,
                  onTap: () {
                    goto(ProductDetail(prod: item), context);
                  },
                  onButtonTab: () => addBasket(item.id, item.itemname_id),
                ),
                noItemsFoundIndicatorBuilder: (context) {
                  return const NoItems();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _fetchByMnfrsOrVndrs(
      String type, int filters, int pageKey) async {
    try {
      final newItems =
          await homeProvider.filter(type, filters, pageKey, _pageSize);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchByCategory(int filters, int pageKey) async {
    try {
      final newItems =
          await homeProvider.filterCate(filters, pageKey, _pageSize);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void addBasket(int? id, int? itemnameId) async {
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
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }
}
