// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';
import 'package:pharmo_app/widgets/product/product_widget_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isList = false;
  bool searching = false;
  final TextEditingController _searchController = TextEditingController();
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (searching) {
          _fetchbySearching(pageKey, type, searchQuery!);
        } else {
          _fetchPage(pageKey);
        }
      },
    );
    super.initState();
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
                          onChanged: (v) {
                            setState(() {
                              if (_searchController.text.isEmpty) {
                                searching = false;
                              } else {
                                searching = true;
                                searchQuery = _searchController.text;
                                _pagingController.refresh();
                              }
                            });
                          },
                          onSubmitted: (v) {
                            if (_searchController.text.isEmpty) {
                              setState(() {
                                searching = false;
                              });
                              _pagingController.refresh();
                            }
                          },
                          title: '$searchType хайх',
                          suffix: IconButton(
                            icon: Image.asset(
                              'assets/icons/refresh.png',
                              height: 24,
                              width: 24,
                            ),
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
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
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
                            child: Icon(viewIcon),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                !isList ? _gridview() : _listview()
              ],
            ),
          );
        },
      ),
    );
  }

  _listview() {
    return PagedSliverList<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        animateTransitions: true,
        firstPageProgressIndicatorBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          );
        },
        firstPageErrorIndicatorBuilder: (context) {
          _pagingController.refresh();
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return const NoItems();
        },
        itemBuilder: (context, item, index) => ProductWidgetListView(
          item: item,
          onButtonTab: () => addBasket(item.id),
          onTap: () => goto(
            ProductDetail(prod: item),
            context,
          ),
        ),
      ),
    );
  }

  _gridview() {
    return PagedSliverGrid(
      pagingController: _pagingController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 480 ? 3 : 2,
      ),
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        firstPageProgressIndicatorBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          );
        },
        firstPageErrorIndicatorBuilder: (context) {
          _pagingController.refresh();
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Colors.red),
            ),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return const NoItems();
        },
        animateTransitions: true,
        transitionDuration: const Duration(milliseconds: 700),
        itemBuilder: (_, item, index) => ProductWidget(
          item: item,
          onButtonTab: () => addBasket(item.id),
          onTap: () => goto(
            ProductDetail(prod: item),
            context,
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
          print(response.statusCode);
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
      showFailedMessage(message: 'Алдаа гарлаа!', context: context);
    }
  }
}
