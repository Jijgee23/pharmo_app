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
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/PA_SCREENS/tabs/marked_promo.dart';
import 'package:pharmo_app/views/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';
import 'package:pharmo_app/widgets/product/product_widget_list.dart';
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
    _pagingController.addPageRequestListener(_handlePageRequest);
    basketProvider.getBasket();
    promotionProvider.getMarkedPromotion();
  }

  void _handlePageRequest(int pageKey) {
    if (!searching) {
      _fetchPage(pageKey);
    } else {
      _fetchbySearching(pageKey, type, searchQuery!);
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void refresh() async {
    basketProvider.getBasket();
    await homeProvider.getFilters();
    await promotionProvider.getMarkedPromotion();
    _pagingController.refresh();
  }

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
                          const Icon(Icons.keyboard_double_arrow_down_sharp)
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
                        suffix: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            showMenu(
                              context: context,
                              position:
                                  const RelativeRect.fromLTRB(150, 20, 0, 0),
                              items: <PopupMenuEntry>[
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      searchBarText = 'Нэрээр';
                                      type = 'name';
                                    });
                                  },
                                  child: const Text('Нэрээр'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      searchBarText = 'Баркодоор';
                                      type = 'barcode';
                                    });
                                  },
                                  child: const Text('Баркодоор'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      searchBarText = 'Ерөнхий нэршлээр';
                                      type = 'intName';
                                    });
                                  },
                                  child: const Text('Ерөнхий нэршлээр'),
                                ),
                              ],
                            ).then((value) {});
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              if (isList) {
                                isList = false;
                                viewIcon = Icons.list;
                              } else {
                                isList = true;
                                viewIcon = Icons.grid_view_sharp;
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
              promotionProvider.markedPromotions.isNotEmpty == true
                  ? SliverAppBar(
                      toolbarHeight: 70,
                      automaticallyImplyLeading: false,
                      title: Column(
                        children: [
                          const Text(
                            'Онцлох урамшууллууд',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          SingleChildScrollView(
                            child: Row(
                                children: promotionProvider.markedPromotions
                                    .map(
                                      (promo) => GestureDetector(
                                          onTap: () => goto(
                                              MarkedPromoWidget(promo: promo),
                                              context),
                                          child: Stack(
                                              fit: StackFit.loose,
                                              children: [
                                                Positioned(
                                                  right: 3,
                                                  top: -4,
                                                  child: InkWell(
                                                    onTap: () => promotionProvider
                                                        .hidePromo(
                                                            promo.id!, context)
                                                        .then((e) =>
                                                            promotionProvider
                                                                .getMarkedPromotion()),
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color:
                                                          Colors.red.shade600,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 2),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                AppColors.main),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Text(promo.name!,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .secondary)))
                                              ])),
                                    )
                                    .toList()),
                          ),
                        ],
                      ),
                    )
                  : const SliverAppBar(toolbarHeight: 0),
              searching
                  ? !isList
                      ? _griview()
                      : _griview()
                  : !isList
                      ? _griview()
                      : _listview()
            ],
          );
        },
      ),
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: homeProvider.supList
                        .map((e) => InkWell(
                              onTap: () {
                                homeProvider.pickSupplier(int.parse(e.id));
                                basketProvider.getBasket();
                                homeProvider.changeSupName(e.name);
                                homeProvider.getFilters();
                                promotionProvider.getMarkedPromotion();
                                refresh();
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade300),
                                  )),
                                  child: Text(e.name)),
                            ))
                        .toList(),
                  ),
                )),
          );
        });
  }

  _listview() {
    return PagedSliverList<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
          firstPageErrorIndicatorBuilder: (context) {
            _pagingController.refresh();
            return indicator();
          },
          firstPageProgressIndicatorBuilder: (context) {
            _pagingController.refresh();
            return indicator();
          },
          noItemsFoundIndicatorBuilder: (context) {
            return const NoItems();
          },
          itemBuilder: (context, item, index) => ProductWidgetListView(
                item: item,
                onButtonTab: () => addBasket(item.id, item.itemname_id),
              ),
          newPageProgressIndicatorBuilder: (context) => indicator(),
          newPageErrorIndicatorBuilder: (context) => indicator()),
    );
  }

  _griview() {
    return PagedSliverGrid<int, dynamic>(
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
      pagingController: _pagingController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 480 ? 3 : 2,
      ),
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        noItemsFoundIndicatorBuilder: (context) {
          return const NoItems();
        },
        firstPageErrorIndicatorBuilder: (context) {
          _pagingController.refresh();
          return indicator();
        },
        firstPageProgressIndicatorBuilder: (context) {
          _pagingController.refresh();
          return indicator();
        },
        animateTransitions: true,
        itemBuilder: (_, item, index) => ProductWidget(
          item: item,
          onTap: () => goto(ProductDetail(prod: item), context),
          onButtonTab: () => addBasket(item.id, item.itemname_id),
        ),
      ),
    );
  }

  indicator() {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
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
      showFailedMessage(message: 'Алдаа гарлаа', context: context);
    }
  }

  Future<void> _fetchbySearching(int pageKey, String type, String key) async {
    print([pageKey, type, key]);
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
      print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        final newItems = (res).map((data) => Product.fromJson(data)).toList();
        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          // _pagingController.appendLastPage(newItems);
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
