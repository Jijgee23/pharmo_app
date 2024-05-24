// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
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
  String? searchQuery = '';
  String type = 'name';
  int filterKey = 1;
  bool isList = false;
  bool searching = false;
  bool filtering = false;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  List<Product> demoList = <Product>[];
  IconData viewIcon = Icons.grid_view;
  List<Filter> filters = [
    Filter(name: 'Эм', selected: false),
    Filter(name: 'Витамин', selected: false),
    Filter(name: 'Эрүүл мэндийн хэрэгсэл, төхөөрөмж', selected: false),
    Filter(name: 'Бусад', selected: false),
  ];
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (!searching && !filtering) {
          _fetchPage(pageKey);
        }
        if (filtering) {
          _fetchPageFilter(filterKey, pageKey);
        }
        if (searching) {
          _fetchbySearching(pageKey, type, searchQuery!);
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
      child: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: Scaffold(
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
                SliverAppBar(
                  title: Expanded(
                    child: NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {}
                        return true;
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: filters.map(
                          (e) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: FilterChip(
                                label: Text(e.name),
                                selected: e.selected,
                                onSelected: (value) {
                                  setState(() {
                                    e.selected = value;
                                    filterKey = filters.indexOf(e) + 1;
                                    if (e.selected) {
                                      filtering = true;
                                    } else {
                                      filtering = false;
                                    }
                                    for (int i = 0; i < filters.length; i++) {
                                      if (i != filters.indexOf(e)) {
                                        filters[i].selected = false;
                                      }
                                    }
                                  });
                                  _pagingController.refresh();
                                },
                              ),
                            );
                          },
                        ).toList()),
                      ),
                    ),
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
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            addBasket(
                                                item.id, item.itemname_id);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(AppColors.primary),
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  '${dotenv.env['SERVER_URL']}' +
                                                      item.images?.first['url'])
                                              : Image.asset(
                                                  'assets/no_image.jpg'),
                                        ),
                                      ),
                                      Text(
                                        item.name,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            addBasket(
                                                item.id, item.itemname_id);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(AppColors.primary),
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                      child: (item.images !=
                                                                  null &&
                                                              item.images
                                                                      .length >
                                                                  0)
                                                          ? Image.network(
                                                              // ignore: prefer_interpolation_to_compose_strings
                                                              '${dotenv.env['SERVER_URL']}' +
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
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ),
                                                            Text(
                                                              '${item.price}₮',
                                                              style: const TextStyle(
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
                                                          width:
                                                              size.width * 0.8,
                                                          child: OutlinedButton(
                                                            style:
                                                                const ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStatePropertyAll(
                                                                AppColors
                                                                    .primary,
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
                                                                  color: Colors
                                                                      .white),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  item.price,
                                                  style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              Expanded(
                                                child: IconButton(
                                                  onPressed: () {
                                                    addBasket(item.id,
                                                        item.itemname_id);
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

  Widget filterWidget(String label, bool selected, int fKey) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setState(() {
          selected = !value;
        });
      },
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

  Future<void> _fetchPageFilter(int filters, int pageKey) async {
    try {
      final newItems = await filter(filters, pageKey, _pageSize);
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

  filter(int filters, int page, int pageSize) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              '${dotenv.env['SERVER_URL']}product/?category=$filters&page=$page&page_size=$pageSize'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        print(res);
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
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
}

class Filter {
  String name;
  bool selected;
  Filter({
    required this.name,
    required this.selected,
  });
}
