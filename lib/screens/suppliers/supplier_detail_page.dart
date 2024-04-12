import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/product_controller.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/suppliers/product_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierDetail extends StatefulWidget {
  final Supplier supp;

  const SupplierDetail({super.key, required this.supp});

  @override
  State<SupplierDetail> createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail> {
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String type = 'нэрээр';
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      if (_searchController.text.isEmpty) {
        _fetchPage(pageKey, searchQuery);
      }
      if (_searchController.text.isNotEmpty && type == 'нэрээр') {
        _fetchPageByName(pageKey, searchQuery);
      }
      if (_searchController.text.isNotEmpty && type == 'баркодоор') {
        _fetchPageByBarcode(pageKey, searchQuery);
      }
      if (_searchController.text.isNotEmpty && type == 'ерөнхий нэршлээр') {
        _fetchPageByIntName(pageKey, searchQuery);
      }
      _pagingController.refresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey, String searchQuery) async {
    try {
      final newItems = await RemoteApi.getProdList(pageKey, _pageSize);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(_pagingController.error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: ChangeNotifierProvider(
          create: (context) => ProductController(),
          child: Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _searchController,
                onChanged: (value) async {
                  setState(() {
                    searchQuery = _searchController.text;
                  });
                  _pagingController.refresh();
                },
                decoration: InputDecoration(
                  hintText: 'Барааны $type хайх',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(150, 20, 0, 0),
                        items: <PopupMenuEntry>[
                          PopupMenuItem(
                            value: '1',
                            onTap: () {
                              setState(() {
                                type = 'нэрээр';
                              });
                            },
                            child: const Text('нэрээр'),
                          ),
                          PopupMenuItem(
                            value: '2',
                            onTap: () {
                              setState(() {
                                type = 'баркодоор';
                              });
                            },
                            child: const Text('Баркодоор'),
                          ),
                          PopupMenuItem(
                            value: '3',
                            onTap: () {
                              setState(() {
                                type = 'ерөнхий нэршлээр';
                              });
                            },
                            child: const Text('Ерөнхий нэршлээр'),
                          ),
                        ],
                      ).then((value) {});
                    },
                    icon: const Icon(Icons.change_circle),
                  ),
                ),
              ),
            ),
            body: PagedGridView<int, dynamic>(
              showNewPageProgressIndicatorAsGridChild: false,
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              pagingController: _pagingController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                animateTransitions: true,
                itemBuilder: (_, item, index) => InkWell(
                  onTap: () {
                    print("Container was tapped");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetail(
                                  prod: item,
                                )));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: (item.images != null &&
                                    item.images.length > 0)
                                // ignore: prefer_interpolation_to_compose_strings
                                ? Image.network('http://192.168.88.39:8000' +
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                            ])
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _fetchPageByName(int pageKey, String searchQuery) async {
    try {
      final newItems = await getProdListByName(pageKey, _pageSize, searchQuery);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(_pagingController.error);
      _pagingController.error = error;
    }
  }

  Future<void> _fetchPageByBarcode(int pageKey, String searchQuery) async {
    try {
      final newItems =
          await getProdListByBarcode(pageKey, _pageSize, searchQuery);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(_pagingController.error);
      _pagingController.error = error;
    }
  }

  Future<void> _fetchPageByIntName(int pageKey, String searchQuery) async {
    try {
      final newItems =
          await getProdListByIntName(pageKey, _pageSize, searchQuery);
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(_pagingController.error);
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
              'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'),
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
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListByIntName(
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
              'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'),
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
              .intName
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase())) {
            filteredItems.add(prods[i]);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListByBarcode(
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
              'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        // Map res = jsonDecode(response.body);
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i]
              .barcode
              .toString()
              .toLowerCase()
              .contains(searchQuery.toString().toLowerCase())) {
            print(prods[i].barcode);
            filteredItems.add(prods[i]);
            //  print(filteredItems.length);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }
}

class RemoteApi {
  static Future<List<dynamic>?> getProdList(
    int page,
    int limit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse(
              'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return prods;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }
}
