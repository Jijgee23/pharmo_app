// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  Color selectedColor = AppColors.failedColor;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  IconData viewIcon = Icons.grid_view;
  String searchBarText = 'Нэрээр';
  String type = 'name';
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        // _fetchPage(pageKey);
        if (!searching) {
          _fetchPage(pageKey);
        } else {
          _fetchbyFiltered(pageKey, type, searchQuery!);
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
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: CustomSearchBar(
                      searchController: _searchController,
                      onSubmitted: (p0) {
                        setState(() {
                          if (p0.isEmpty) {
                            searching = false;
                          } else {
                            searching = true;
                            searchQuery = p0;
                          }
                        });
                        _pagingController.refresh();
                      },
                      onChanged: (value) {
                        setState(() {
                          searching = true;
                          searchQuery =
                              value.isEmpty ? null : _searchController.text;
                        });
                        _pagingController.refresh();
                      },
                      title: '$searchBarText хайх',
                      suffix: IconButton(
                        icon: const Icon(Icons.swap_vert),
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
                        itemBuilder: (_, item, index) => InkWell(
                          onTap: () {
                            goto(ProductDetail(prod: item), context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            width: double.infinity,
                            child: Column(
                              children: [
                                Expanded(
                                  child: item.image != null
                                      ? Image.network(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          'https://test.pharma.mn/api/v1${item.image}')
                                      : Image.asset(
                                          'assets/no_image.jpg',
                                        ),
                                ),
                                Text(
                                  item.name,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item.price.toString()} ₮',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      addBasket(item.id, item.itemname_id);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.primary),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Сагсанд нэмэх',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : PagedSliverList<int, dynamic>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<dynamic>(
                        itemBuilder: (context, item, index) => InkWell(
                          onTap: () {
                            goto(ProductDetail(prod: item), context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
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
                                        style: const TextStyle(
                                            color: Colors.black),
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
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    addBasket(item.id, item.itemname_id);
                                  },
                                  icon: const Icon(Icons.shopping_cart),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
              : !isList
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
                        itemBuilder: (_, item, index) => InkWell(
                          onTap: () {
                            goto(ProductDetail(prod: item), context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            width: double.infinity,
                            child: Column(
                              children: [
                                Expanded(
                                  child: (item.images != null &&
                                          item.images.length > 0)
                                      ? Image.network(
                                          // ignore: prefer_interpolation_to_compose_strings
                                          '${dotenv.env['SERVER_URL']}${item.images?.first['url']}')
                                      : Image.asset('assets/no_image.jpg'),
                                ),
                                Text(
                                  item.name,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item.price.toString()} ₮',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      addBasket(item.id, item.itemname_id);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.primary),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Сагсанд нэмэх',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : PagedSliverList<int, dynamic>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<dynamic>(
                        itemBuilder: (context, item, index) => InkWell(
                          onTap: () {
                            goto(ProductDetail(prod: item), context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
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
                                        style: const TextStyle(
                                            color: Colors.black),
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
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    addBasket(item.id, item.itemname_id);
                                  },
                                  icon: const Icon(Icons.shopping_cart),
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
        List<FilteredProduct> prods =
            (res).map((data) => FilteredProduct.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
  }

  Future<void> _fetchbyFiltered(int pageKey, String type, String key) async {
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

class FilteredProduct {
  int id;
  int itemname_id;
  String name;
  double price;
  String? barcode;
  String? intName;
  String? image;

  FilteredProduct({
    required this.id,
    required this.itemname_id,
    required this.name,
    required this.price,
    this.barcode,
    this.intName,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemname_id': itemname_id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'intName': intName,
      'image': image,
    };
  }

  factory FilteredProduct.fromJson(Map<String, dynamic> json) {
    return FilteredProduct(
      id: json['id'],
      itemname_id: json['itemname_id'],
      name: json['name'],
      price: json['price'],
      barcode: json['barcode'],
      intName: json['intName'],
      image: json['image'],
    );
  }
}
