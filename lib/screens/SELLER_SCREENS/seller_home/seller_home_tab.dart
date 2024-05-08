// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
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
  String searchQuery = '';
  bool isem = true;
  bool isvita = true;
  bool isprod = true;
  bool isother = true;
  bool isList = false;
  int viewIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  List<Product> demoList = <Product>[];
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (_searchController.text.isNotEmpty && searchType == 'Нэрээр') {
          _fetchPageByName(pageKey, searchQuery);
        }
        if (_searchController.text.isNotEmpty && searchType == 'Баркодоор') {
          _fetchPageByBarcode(pageKey, searchQuery);
        }
        if (_searchController.text.isEmpty) {
          _fetchPage(pageKey);
        }
        _pagingController.refresh();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<dynamic>?> getProdList(int page, int limit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        demoList.clear();
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        setState(() {
          demoList = prods;
        });
        print(demoList);
        return prods;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
    return null;
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

  Future<void> _fetchPageByName(int pageKey, String searchQuery) async {
    try {
      final newItems = await SearchProvider.getProdListByName(
          pageKey, _pageSize, searchQuery);
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

  static Future<List<dynamic>?> getProdListByName(
    int page,
    int limit,
    String searchQuery,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));

        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i]
              .name
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase())) {
            filteredItems.add(prods[i]);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
    return null;
  }

  Future<void> _fetchPageByBarcode(int pageKey, String searchQuery) async {
    try {
      final newItems = await SearchProvider.getProdListByBarcode(
          pageKey, _pageSize, searchQuery);
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

  void addBasket(int productID, int itemNameId) async {
    try {
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      Map<String, dynamic> res = await basketProvider.addBasket(
          product_id: productID, itemname_id: itemNameId, qty: 1);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  actions: [
                    IconButton(
                      onPressed: () {
                        getProdList(1, 20);
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
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
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              _pagingController.refresh();
                            },
                            onSubmitted: (value) {
                              if (_searchController.text.isEmpty) {
                                _fetchPage(1);
                              }
                            },
                            title: searchType,
                            suffix: IconButton(
                              icon: const Icon(Icons.change_circle_sharp),
                              onPressed: () {
                                showMenu(
                                  context: context,
                                  position: const RelativeRect.fromLTRB(
                                      150, 20, 0, 0),
                                  items: <PopupMenuEntry>[
                                    PopupMenuItem(
                                      value: '1',
                                      onTap: () {
                                        setState(() {
                                          searchType = 'Нэрээр';
                                        });
                                      },
                                      child: const Text('Нэрээр'),
                                    ),
                                    PopupMenuItem(
                                      value: '2',
                                      onTap: () {
                                        setState(() {
                                          searchType = 'Баркодоор';
                                        });
                                      },
                                      child: const Text('Баркодоор'),
                                    ),
                                    PopupMenuItem(
                                      value: '2',
                                      onTap: () {
                                        setState(() {
                                          searchType = 'Ерөнхий нэршлээр';
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
                // SliverAppBar(
                //   title: Expanded(
                //     child: SingleChildScrollView(
                //       controller: ScrollController(initialScrollOffset: 50),
                //       physics: const AlwaysScrollableScrollPhysics(),
                //       scrollDirection: Axis.horizontal,
                //       child: Wrap(
                //         spacing: 5,
                //         children: [
                //           CustomFitler(
                //             selected: !isem,
                //             text: 'Эм',
                //             onSelected: (bool value) {
                //               setState(() {
                //                 isem = !isem;
                //               });
                //             },
                //           ),
                //           CustomFitler(
                //             selected: !isvita,
                //             text: 'Витамин',
                //             onSelected: (bool value) {
                //               setState(() {
                //                 isvita = !isvita;
                //               });
                //             },
                //           ),
                //           CustomFitler(
                //             selected: !isprod,
                //             text: 'Эрүүл мэндийн хэрэгсэл, төхөөрөмж',
                //             onSelected: (bool value) {
                //               setState(() {
                //                 isprod = !isprod;
                //               });
                //             },
                //           ),
                //           CustomFitler(
                //             selected: !isother,
                //             text: 'Бусад',
                //             onSelected: (bool value) {
                //               setState(() {
                //                 isother = !isother;
                //               });
                //             },
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                !isList
                    ? PagedSliverGrid(
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
                                  horizontal: 15, vertical: 5),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: (item.images != null &&
                                              item.images.length > 0)
                                          ? Image.network(
                                              // ignore: prefer_interpolation_to_compose_strings
                                              'http://192.168.88.39:8000' +
                                                  item.images?.first['url'])
                                          : Image.asset('assets/no_image.jpg'),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.price + ' ₮',
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        item.modified_at,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
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
                        builderDelegate: PagedChildBuilderDelegate(
                          itemBuilder: (_, item, index) {
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: SizedBox(
                                                  child: (item.images != null &&
                                                          item.images.length >
                                                              0)
                                                      ? Image.network(
                                                          // ignore: prefer_interpolation_to_compose_strings
                                                          'http://192.168.88.39:8000' +
                                                              item.images
                                                                      ?.first[
                                                                  'url'])
                                                      : Image.asset(
                                                          'assets/no_image.jpg'),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          item.modified_at,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                        Text(
                                                          '${item.price}₮',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.8,
                                                      child: OutlinedButton(
                                                        style:
                                                            const ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStatePropertyAll(
                                                            AppColors.primary,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          addBasket(item.id,
                                                              item.itemname_id);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          'Сагсанд нэмэх',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              item.name,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.price,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Expanded(
                                            child: IconButton(
                                              onPressed: () {
                                                addBasket(
                                                    item.id, item.itemname_id);
                                              },
                                              icon: const Icon(
                                                Icons.add_shopping_cart,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
