// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_list.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _pageController = PageController();
  IconData viewIcon = Icons.grid_view;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  late PromotionProvider promotionProvider;
  late PagingController<int, dynamic> pagingController;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    _pageController = PageController(initialPage: 0);
    basketProvider.getBasket();
    promotionProvider.getMarkedPromotion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeProvider.paging();
      homeProvider.refreshCntrl();
      if (promotionProvider.markedPromotions.isNotEmpty) {
        homeProvider.showMarkedPromos(context, promotionProvider);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        homeProvider.refreshCntrl();
      }),
      child: Consumer3<HomeProvider, BasketProvider, PromotionProvider>(
        builder: (_, homeProvider, basketProvider, promotionProvider, child) {
          final pagingController = homeProvider.pagingController;
          final search = homeProvider.searchController;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                toolbarHeight: 40,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: CustomSearchBar(
                        searchController: search,
                        onChanged: (value) {
                          Future.delayed(const Duration(milliseconds: 1500),
                              () {
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              if (search.text.isNotEmpty) {
                                homeProvider.changeSearching(true);
                                homeProvider.changeQueryValue(value);
                                homeProvider.refresh(
                                    context, homeProvider, promotionProvider);
                                homeProvider.pagingController.refresh();
                              } else {
                                homeProvider.changeSearching(false);
                                homeProvider.pagingController
                                    .removePageRequestListener((pageKey) {});
                                homeProvider.refresh(
                                    context, homeProvider, promotionProvider);
                              }
                            });
                          });
                        },
                        title: '${homeProvider.searchType} хайх',
                        suffix: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Icon(Icons.keyboard_arrow_down_rounded)),
                        onTapSuffux: () {
                          showMenu(
                                  surfaceTintColor: Colors.white,
                                  context: context,
                                  position: const RelativeRect.fromLTRB(
                                      150, 140, 0, 0),
                                  items: homeProvider.stype
                                      .map((e) => PopupMenuItem(
                                          onTap: () {
                                            homeProvider.setQueryTypeName(e);
                                            int index =
                                                homeProvider.stype.indexOf(e);
                                            if (index == 0) {
                                              homeProvider.setQueryType('name');
                                            } else if (index == 1) {
                                              homeProvider
                                                  .setQueryType('barcode');
                                            } else {
                                              homeProvider
                                                  .setQueryType('intName');
                                            }
                                          },
                                          child: Text(e)))
                                      .toList())
                              .then((value) {});
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => homeProvider.switchView(),
                        child: Icon(
                            homeProvider.isList ? Icons.grid_view : Icons.list),
                      ),
                    ),
                  ],
                ),
              ),
              homeProvider.searching
                  ? !homeProvider.isList
                      ? CustomGridView(pagingController: pagingController)
                      : CustomListView(pagingController: pagingController)
                  : !homeProvider.isList
                      ? CustomGridView(pagingController: pagingController)
                      : CustomListView(
                          pagingController: pagingController,
                        )
            ],
          );
        },
      ),
    );
  }
}
