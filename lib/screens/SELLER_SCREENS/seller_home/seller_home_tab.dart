// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/filtered_product.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/product_widget.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SellerHomeTab extends StatefulWidget {
  const SellerHomeTab({
    super.key,
  });

  @override
  State<SellerHomeTab> createState() => _SellerHomeTabState();
}

class _SellerHomeTabState extends State<SellerHomeTab> {
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  String email = '';
  String role = '';
  String searchType = 'Нэрээр';
  String? searchQuery = '';
  String type = 'name';
  int filterKey = 0;
  bool isList = false;
  bool searching = false;
  final TextEditingController _searchController = TextEditingController();
  IconData viewIcon = Icons.grid_view;
  late HomeProvider homeProvider;
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (!searching) {
          _fetchPage(pageKey);
        }
        if (searching) {
          _fetchbySearching(pageKey, type, searchQuery!);
        }
      },
    );
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getFilters();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Consumer<HomeProvider>(
        builder: (_, homeProvider, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 10,
                        child: CustomSearchBar(
                          searchController: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searching = true;
                              searchQuery =
                                  value.isEmpty ? null : _searchController.text;
                            });
                            _pagingController.refresh();
                          },
                          onSubmitted: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                searching = false;
                              } else {
                                searching = true;
                                searchQuery = value;
                              }
                            });
                            _pagingController.refresh();
                          },
                          title: '$searchType хайх',
                          suffix: IconButton(
                            icon: const Icon(Icons.swap_vert),
                            onPressed: () {
                              showMenu(
                                surfaceTintColor: Colors.white,
                                context: context,
                                position:
                                    const RelativeRect.fromLTRB(150, 20, 0, 0),
                                items: <PopupMenuEntry>[
                                  PopupMenuItem(
                                    onTap: () {
                                      setState(() {
                                        searchType = 'Нэрээр';
                                        type = 'name';
                                      });
                                    },
                                    child: const Text('Нэрээр'),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      setState(() {
                                        searchType = 'Баркодоор';
                                        type = 'barcode';
                                      });
                                    },
                                    child: const Text('Баркодоор'),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      setState(() {
                                        searchType = 'Ерөнхий нэршлээр';
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
                searching
                    ? !isList
                        ? PagedSliverGrid<int, dynamic>(
                            showNewPageProgressIndicatorAsGridChild: false,
                            showNewPageErrorIndicatorAsGridChild: false,
                            showNoMoreItemsIndicatorAsGridChild: false,
                            pagingController: _pagingController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            builderDelegate: PagedChildBuilderDelegate<dynamic>(
                              animateTransitions: true,
                              itemBuilder: (_, item, index) => ProductWidget(
                                item: item,
                                onButtonTab: () => addBasket(item.id),
                                onTap: () => goto(
                                  ProductDetail(prod: item),
                                  context,
                                ),
                              ),
                            ),
                          )
                        : _listview()
                    : !isList
                        ? PagedSliverGrid(
                            pagingController: _pagingController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            builderDelegate: PagedChildBuilderDelegate<dynamic>(
                              animateTransitions: true,
                              itemBuilder: (_, item, index) => ProductWidget(
                                item: item,
                                onButtonTab: () => addBasket(item.id),
                                onTap: () => goto(
                                  ProductDetail(prod: item),
                                  context,
                                ),
                              ),
                            ),
                          )
                        : _listview()
              ],
            ),
          );
        },
      ),
    );
  }
  _listview() {
    Size size = MediaQuery.of(context).size;
    return PagedSliverList<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        itemBuilder: (context, item, index) => InkWell(
          onTap: () {
            goto(ProductDetail(prod: item), context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width / 6 * 3,
                      child: Text(
                        item.name,
                        style: const TextStyle(color: Colors.black),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Text(
                      '${item.price} ₮',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    addBasket(item.id);
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  search(String filter, String searchWord) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}products/search/?k=$filter&v=$searchWord'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        List<FilteredProduct> prods =
            (res).map((data) => FilteredProduct.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _fetchbySearching(int pageKey, String type, String key) async {
    try {
      final newItems = await search(type, key);
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

  void addBasket(int productID) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res =
          await basketProvider.addBasket(product_id: productID, qty: 1);
      if (res['errorType'] == 1) {
        basketProvider.getBasket();
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа.!', context: context);
    }
  }
}
