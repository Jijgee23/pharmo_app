// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/filtered_product.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/product_widget.dart';
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
  final List<Supplier> _supList = <Supplier>[];
  final int _pageSize = 20;
  bool isList = false;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  String? searchQuery = '';
  bool searching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  IconData viewIcon = Icons.grid_view;
  String searchBarText = 'Нэрээр';
  String type = 'name';
  Supplier? selectedSupplier;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  Color selectedFilterColor = Colors.black;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    getSuppliers();
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (!searching) {
          _pagingController.refresh();
          _fetchPage(pageKey);
        } else {
          _pagingController.refresh();
          _fetchbySearching(pageKey, type, searchQuery!);
        }
      },
    );
    super.initState();
    basketProvider.getBasket();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        _pagingController.refresh();
        basketProvider.getBasket();
      }),
      child: Consumer2<HomeProvider, BasketProvider>(
        builder: (_, homeProvider, basketProvider, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: ChangeNotifierProvider(
                  create: (context) => BasketProvider(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    height: 50,
                    child: DropdownButtonFormField<Supplier>(
                      style: const TextStyle(),
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'Нийлүүлэгч сонгох'),
                      icon: const Icon(Icons.arrow_drop_down),
                      value: selectedSupplier,
                      onSaved: (newValue) {
                        print('saved');
                        _pagingController.refresh();
                      },
                      onChanged: (Supplier? newValue) {
                        pickSupplier(int.parse(newValue!.id));
                        setLastSupplier(int.parse(newValue.id));
                        homeProvider.getFilters();
                        basketProvider.getBasket();
                        _pagingController.refresh();
                      },
                      items: _supList
                          .map<DropdownMenuItem<Supplier>>((Supplier supplier) {
                        return DropdownMenuItem<Supplier>(
                          value: supplier,
                          child: Text(
                            supplier.name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        );
                      }).toList(),
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
                    addBasket(item.id, item.itemname_id);
                  },
                  icon: const Icon(Icons.add_shopping_cart,size: 18,color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _griview() {
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

  pickSupplier(int supId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    final response =
        await http.post(Uri.parse('${dotenv.env['SERVER_URL']}pick/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
            body: jsonEncode({'supplierId': supId}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> res = jsonDecode(response.body);
      print(res);
      await prefs.setString('access_token', res['access_token']);
      await prefs.setString('refresh_token', res['refresh_token']);
    } else if (response.statusCode == 403) {
      showFailedMessage(
          message: 'Энэ үйлдлийг хийхэд таны эрх хүрэхгүй байна.',
          context: context);
    } else {
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }

  setLastSupplier(int lastSupId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastSupId', lastSupId);
  }

  getSuppliers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}suppliers'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          res.forEach((key, value) {
            var model = Supplier(key, value);
            _supList.add(model);
          });
        });
      } else {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
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
