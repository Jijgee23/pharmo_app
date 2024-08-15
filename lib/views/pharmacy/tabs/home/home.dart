// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/marked_promo.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _pageSize = 20;
  bool isList = false;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  String? searchQuery = '';
  bool searching = false;
  final TextEditingController _searchController = TextEditingController();
  late PageController _pageController = PageController();
  IconData viewIcon = Icons.grid_view;
  String searchBarText = 'Нэрээр';
  String type = 'name';
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  late PromotionProvider promotionProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    _pageController = PageController(initialPage: 0);
    _pagingController.addPageRequestListener(_handlePageRequest);
    basketProvider.getBasket();
    promotionProvider.getMarkedPromotion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (promotionProvider.markedPromotions.isNotEmpty) {
        _pagingController.refresh();
        _showMarkedPromos();
      }
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List stype = ['Нэрээр', 'Баркодоор', 'Ерөнхий нэршлээр'];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        refresh();
      }),
      child: Consumer3<HomeProvider, BasketProvider, PromotionProvider>(
        builder: (_, homeProvider, basketProvider, promotionProvider, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: ChangeNotifierProvider(
                  create: (context) => BasketProvider(),
                  child: InkWell(
                    onTap: () {
                      _picksupp(context, homeProvider, basketProvider);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            homeProvider.supName,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: CustomSearchBar(
                        searchController: _searchController,
                        onChanged: (value) {
                          if (_searchController.text.isNotEmpty) {
                            setState(() {
                              searching = true;
                              searchQuery =
                                  value.isEmpty ? null : _searchController.text;
                            });
                            _pagingController.refresh();
                          } else {
                            setState(() {
                              searching = false;
                              _pagingController
                                  .removePageRequestListener((pageKey) {});
                            });
                            _pagingController.refresh();
                          }
                        },
                        onSubmitted: (p0) {
                          if (p0.isEmpty) {
                            setState(() {
                              searching = false;
                              _pagingController.refresh();
                            });
                          }
                        },
                        title: '$searchBarText хайх',
                        suffix: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Icon(Icons.keyboard_arrow_down_rounded)),
                        onTapSuffux: () {
                          showMenu(
                                  surfaceTintColor: Colors.white,
                                  context: context,
                                  position: const RelativeRect.fromLTRB(
                                      150, 140, 0, 0),
                                  items: stype
                                      .map((e) => PopupMenuItem(
                                          onTap: () {
                                            setState(() {
                                              searchBarText = e;
                                              if (stype.indexOf(e) == 0) {
                                                type = 'name';
                                              } else if (stype.indexOf(e) ==
                                                  1) {
                                                type = 'barcode';
                                              } else {
                                                type = 'intName';
                                              }
                                            });
                                          },
                                          child: Text(e)))
                                      .toList())
                              .then((value) {});
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              isList = !isList;
                              if (isList) {
                                viewIcon = Icons.grid_view;
                              } else {
                                viewIcon = Icons.list_alt_outlined;
                              }
                            },
                          );
                        },
                        icon: Icon(viewIcon),
                      ),
                    ),
                  ],
                ),
              ),
              searching
                  ? !isList
                      ? CustomGridView(pagingController: _pagingController)
                      : CustomListView(pagingController: _pagingController)
                  : !isList
                      ? CustomGridView(pagingController: _pagingController)
                      : CustomListView(
                          pagingController: _pagingController,
                        )
            ],
          );
        },
      ),
    );
  }

  void refresh() async {
    basketProvider.getBasket();
    await homeProvider.getFilters();
    await promotionProvider.getMarkedPromotion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (promotionProvider.markedPromotions.isNotEmpty) {
        _pagingController.refresh();
        _showMarkedPromos();
      }
    });
    _pagingController.refresh();
  }

  void _handlePageRequest(int pageKey) {
    if (!searching) {
      _fetchPage(pageKey);
    } else {
      _fetchbySearching(pageKey, type, searchQuery!);
    }
  }

  void _showMarkedPromos() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                height: double.infinity,
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        pageSnapping: true,
                        children: promotionProvider.markedPromotions
                            .map((e) => MarkedPromoWidget(promo: e))
                            .toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear),
                          child: const Text('Өмнөх'),
                        ),
                        InkWell(
                            onTap: () {
                              if (_pageController.page ==
                                  promotionProvider.markedPromotions.length -
                                      1) {
                                Navigator.pop(context);
                              } else {
                                _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.linear);
                              }
                            },
                            child: const Text('Дараах')),
                      ],
                    )
                  ],
                )),
          );
        });
  }

  Future<dynamic> _picksupp(BuildContext context, HomeProvider homeProvider,
      BasketProvider basketProvider) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: AppColors.cleanBlack)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: homeProvider.supList
                        .map((e) => InkWell(
                              onTap: () async {
                                await homeProvider
                                    .pickSupplier(int.parse(e.id));
                                homeProvider.changeSupName(e.name);
                                refresh();
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade700),
                                  )),
                                  child: Text(e.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary))),
                            ))
                        .toList(),
                  ),
                )),
          );
        });
  }

  Future<void> _fetchbySearching(int pageKey, String type, String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}product/search/?k=$type&v=$searchQuery'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        final newItems = (res).map((data) => Product.fromJson(data)).toList();
        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await SearchProvider.getProdList(pageKey, _pageSize);
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
}
