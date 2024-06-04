import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/public_uses/filtered_products.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/product_widget.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> filterList = ['Англилал', 'Үйлдвэрлэгчид', 'Нийлүүлэгчид'];
  int selectedFilter = 0;
  String selectedFilterName = 'Англилал';
  late HomeProvider homeProvider;
  bool searching = false;
  final int _pageSize = 20;
  String searchBarText = 'Нэрээр';
  String type = 'name';
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getFilters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: CustomSearchBar(
                  searchController: _searchController,
                  title: 'Хайх',
                  onChanged: (p0) {
                    if (p0.isNotEmpty && p0.length > 2) {
                      setState(() {
                        searching = true;
                        _pagingController.addPageRequestListener((pageKey) {
                          _fetchbySearching(
                              pageKey, type, _searchController.text);
                        });
                        _pagingController.refresh();
                      });
                    } else {
                      setState(() {
                        searching = false;
                        _pagingController
                            .removePageRequestListener((pageKey) {});
                      });
                    }
                    _pagingController.refresh();
                  },
                ),
              ),
              searching
                  ? _search()
                  : SliverAppBar(
                      toolbarHeight: 14,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: filterList.map((e) {
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = filterList.indexOf(e);
                              });
                            },
                            child: Text(
                              e,
                              style: TextStyle(
                                  color: filterList.indexOf(e) == selectedFilter
                                      ? AppColors.succesColor
                                      : AppColors.primary),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
              searching
                  ? const SliverAppBar(
                      toolbarHeight: 0,
                    )
                  : selectedFilter == 0
                      ? _categories()
                      : selectedFilter == 1
                          ? _mnfrs()
                          : _vndrs(),
            ],
          ),
        );
      },
    );
  }

  _search() {
    return PagedSliverGrid<int, dynamic>(
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
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
      ),
    );
  }

  _categories() {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return Padding(
            padding: const EdgeInsets.only(left: 30, top: 5),
            child: GestureDetector(
              child: Text(
                homeProvider.categories[index].name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                goto(
                    FilteredProducts(
                        title: homeProvider.categories[index].name,
                        filterKey: homeProvider.categories[index].id),
                    context);
              },
            ));
      },
      itemCount: homeProvider.categories.length,
    );
  }

  _mnfrs() {
    return SliverList.builder(
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 5,
          ),
          child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                child: Text(
                  homeProvider.mnfrs[idx].name,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  goto(
                      FilteredProducts(
                          title: homeProvider.mnfrs[idx].name,
                          filterKey: homeProvider.mnfrs[idx].id),
                      context);
                },
              )),
        );
      },
      itemCount: homeProvider.mnfrs.length,
    );
  }

  _vndrs() {
    return SliverList.builder(
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 5,
          ),
          child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                child: Text(
                  homeProvider.vndrs[idx].name,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  goto(
                      FilteredProducts(
                          title: homeProvider.vndrs[idx].name,
                          filterKey: homeProvider.vndrs[idx].id),
                      context);
                },
              )),
        );
      },
      itemCount: homeProvider.vndrs.length,
    );
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

  search(String filter, String searchWord) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}product/search/?k=$filter&v=$searchWord'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods =
            (res).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      debugPrint(e.toString());
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
      showFailedMessage(message: 'Алдаа гарлаа', context: context);
    }
  }
}
