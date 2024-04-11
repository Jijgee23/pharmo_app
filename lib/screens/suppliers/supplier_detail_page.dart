import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierDetail extends StatefulWidget {
  final Supplier supp;

  const SupplierDetail({Key? key, required this.supp}) : super(key: key);

  @override
  State<SupplierDetail> createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail> {
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    // TODO: implement initState
    getDataById();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
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

  getDataById() async {
    try {
      // token = prefs.getString("access_token");
      // bearerToken = "Bearer $token";
      // final resProd = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/product/?page=1&page_size=20'), headers: <String, String>{
      //   'Content-Type': 'application/json; charset=UTF-8',
      //   'Authorization': bearerToken,
      // });
      // Map res111 = jsonDecode(resProd.body);
      // List<Product> employees = (res111['results'] as List).map((data) => Product.fromJson(data)).toList();
      // print(employees);
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Бараа',
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                  ),
                  onPressed: () {}),
              IconButton(
                  icon: const Icon(
                    Icons.shopping_basket,
                    color: Colors.red,
                  ),
                  onPressed: () {}),
            ],
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
                  print(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: (item.images != null && item.images.length > 0)
                              ? Image.network('http://192.168.88.39:8000' + item.images?.first['url'])
                              : Image.asset('assets/no_image.jpg'),
                        ),
                      ),
                      Text(
                        item.name,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                      Container(
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Text(
                            item.price + ' ₮',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            item.modified_at,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
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
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(response.body);
        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        print(prods[0].images?.first['url']);
        return prods;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }
}
