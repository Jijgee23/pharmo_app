// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/product_scrolls/paged_sliver_grid.dart';
import 'package:pharmo_app/widgets/product_scrolls/paged_sliver_list.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IconData viewIcon = Icons.grid_view;
  int pageKey = 1;
  bool hasSale = true;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  late PromotionProvider promotionProvider;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, dynamic> _filtering =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    homeProvider.getUserInfo();
    if (homeProvider.userRole == 'PA') {
      initPharmo();
    }
    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  refresh() {
    homeProvider.refresh(context, homeProvider, promotionProvider);
    _pagingController.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    //_pagingController.dispose();
  }

  initPharmo() async {
    await promotionProvider.getMarkedPromotion();
    await homeProvider.getFilters();
    await basketProvider.getBasket();
    await homeProvider.getBranches(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (promotionProvider.markedPromotions.isNotEmpty) {
        // homeProvider.showMarkedPromos(context, promotionProvider);
      }
    });
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final items = await homeProvider.getProducts(pageKey);
      final isLastPage = items!.length < homeProvider.pageSize;
      final nextPageKey = pageKey + 1;
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  List<IconData> icons = [Icons.discount, Icons.star, Icons.new_releases];

  goFilt(String query, String title, int pageKey, bool hasSale) async {
    final items = await homeProvider.filterProducts(query);
    final isLastPage = items!.length < homeProvider.pageSize;
    final nextPageKey = pageKey + 1;
    if (isLastPage) {
      _filtering.appendLastPage(items);
    } else {
      _filtering.appendPage(items, nextPageKey);
    }
    goto(
      Scaffold(
        appBar: CustomAppBar(
          leading: const ChevronBack(),
          title: Text(title, style: Constants.headerTextStyle),
        ),
        body: CustomScrollView(
          slivers: [
            CustomGridView(pagingController: _filtering, hasSale: hasSale)
          ],
        ),
      ),
    );
  }

  List<String> filters = ['Хямдралтай', 'Эрэлттэй', 'Шинэ'];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final smallFontSize = height * .0125;
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        refresh();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          homeProvider.refresh(context, homeProvider, promotionProvider);
          _pagingController.refresh();
        });
      }),
      child: Consumer3<HomeProvider, BasketProvider, PromotionProvider>(
        builder: (_, homeProvider, basketProvider, promotionProvider, child) {
          final search = homeProvider.searchController;
          return Scaffold(
            extendBody: true,
            body: Column(
              children: [
                searchBar(
                  context,
                  homeProvider,
                  basketProvider,
                  smallFontSize,
                  search,
                ),
                if (homeProvider.userRole == 'PA') filtering(smallFontSize),
                products(homeProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Container searchBar(
      BuildContext context,
      HomeProvider homeProvider,
      BasketProvider basketProvider,
      double smallFontSize,
      TextEditingController search) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [Constants.defaultShadow],
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (homeProvider.userRole == 'PA')
                    IntrinsicWidth(
                      child: InkWell(
                        onTap: () =>
                            _picksupp(context, homeProvider, basketProvider),
                        child: Text(
                          '${homeProvider.supName} :',
                          style: TextStyle(
                              fontSize: smallFontSize,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(width: 15),
                  Expanded(
                      child: TextFormField(
                    cursorHeight: smallFontSize,
                    style: TextStyle(fontSize: smallFontSize),
                    decoration: InputDecoration(
                      hintText: '${homeProvider.searchType} хайх',
                      hintStyle: TextStyle(fontSize: smallFontSize),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) {
                      try {
                        Future.delayed(
                          const Duration(milliseconds: 1500),
                          () {
                            if (v.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((t) {
                                homeProvider.changeSearching(true);
                                homeProvider.changeQueryValue(v);
                                _pagingController.refresh();
                              });
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((t) {
                                homeProvider.changeSearching(false);
                                _pagingController.refresh();
                              });
                            }
                            print(search.text);
                          },
                        );
                      } catch (e) {
                        print('=============> $e');
                      }
                    },
                    onFieldSubmitted: (v) {
                      if (v.isEmpty) {
                        homeProvider.changeSearching(false);
                        _pagingController.refresh();
                      }
                    },
                  )),
                  InkWell(
                      onTap: () {
                        showMenu(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                context: context,
                                position:
                                    const RelativeRect.fromLTRB(150, 120, 0, 0),
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
                      child: const Icon(Icons.keyboard_arrow_down_rounded)),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => homeProvider.switchView(),
              child: Icon(
                homeProvider.isList ? Icons.grid_view : Icons.list,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded products(HomeProvider homeProvider) {
    return Expanded(
      child: homeProvider.searching
          ? !homeProvider.isList
              ? CustomGrid(pagingController: _pagingController)
              : CustomList(pagingController: _pagingController)
          : !homeProvider.isList
              ? CustomGrid(pagingController: _pagingController)
              : CustomList(pagingController: _pagingController),
    );
  }

  filtering(double smallFontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: filters
              .map(
                (e) => InkWell(
                  borderRadius: BorderRadius.circular(5),
                  splashColor: AppColors.secondary.withOpacity(0.5),
                  onTap: () {
                    _filtering.itemList?.clear();
                    if (filters.indexOf(e) == 0) {
                      goFilt('discount__gt=0', 'Хямдралтай', pageKey, true);
                    } else if (filters.indexOf(e) == 1) {
                      goFilt(
                          'ordering=-created_at', 'Эрэлттэй', pageKey, false);
                    } else {
                      goFilt('supplier_indemand_products/', 'Шинэ', pageKey,
                          false);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary, width: 2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icons[filters.indexOf(e)],
                              color: AppColors.secondary),
                          const SizedBox(width: 5),
                          Text(
                            e,
                            style: TextStyle(fontSize: smallFontSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList()),
    );
  }

  Future<dynamic> _picksupp(BuildContext context, HomeProvider homeProvider,
      BasketProvider basketProvider) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Scrollbar(
              thickness: 2,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Center(
                        child: Text(
                          'Нийлүүлэгч сонгох',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          ...homeProvider.supList.map(
                            (e) => InkWell(
                              onTap: () async => await onPickSupp(e),
                              child: supplier(
                                  e: e,
                                  isLast: (homeProvider.supList.indexOf(e) ==
                                          homeProvider.supList.length)
                                      ? null
                                      : true),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  onPickSupp(Supplier e) async {
    await homeProvider.pickSupplier(int.parse(e.id), context);
    await homeProvider.changeSupName(e.name);
    basketProvider.getBasket();
    await promotionProvider.getMarkedPromotion();
    homeProvider.refresh(context, homeProvider, promotionProvider);
    _pagingController.refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (promotionProvider.markedPromotions.isNotEmpty) {
        homeProvider.showMarkedPromos(context, promotionProvider);
      }
    });
    Navigator.pop(context);
  }

  supplier({required Supplier e, bool? isLast}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade700, width: 2)),
      ),
      child: Text(
        e.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
