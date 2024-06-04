// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/screens/public_uses/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class FilteredProducts extends StatefulWidget {
  final int filterKey;
  final String title;
  const FilteredProducts(
      {super.key, required this.filterKey, required this.title});

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
      _fetchPageFilter(widget.filterKey, pageKey);
    });
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);

    return Scaffold(
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
      body: CustomScrollView(
        slivers: [
          PagedSliverGrid<int, dynamic>(
            showNewPageProgressIndicatorAsGridChild: false,
            showNewPageErrorIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: _pagingController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              animateTransitions: true,
              itemBuilder: (_, item, index) => InkWell(
                onTap: () {
                  goto(ProductDetail(prod: item), context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: item.image != null
                                  ? NetworkImage(
                                      '${dotenv.env['SERVER_URL']}${item.image.toString().substring(1)}')
                                  : NetworkImage(noImageUrl),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        item.name,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.price.toString()} ₮',
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            onPressed: () {
                              addBasket(item.id, item.itemname_id);
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _fetchPageFilter(int filters, int pageKey) async {
    try {
      final newItems = await homeProvider.filter(filters, pageKey, _pageSize);
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
