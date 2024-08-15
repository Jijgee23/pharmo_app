// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_list.dart';
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

  List stype = ['Нэрээр', 'Баркодоор', 'Ерөнхий нэршлээр'];
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
                              setState(() => searching = false);
                              _pagingController.refresh();
                            }
                          },
                          title: '$searchType хайх',
                          suffix: const Icon(Icons.keyboard_arrow_down_rounded),
                          onTapSuffux: () {
                            showMenu(
                                    surfaceTintColor: Colors.white,
                                    context: context,
                                    position: const RelativeRect.fromLTRB(
                                        150, 140, 0, 0),
                                    items: stype
                                        .map((e) => PopupMenuItem(
                                            onTap: () {
                                              setState(() {
                                                searchType = e;
                                                if (stype.indexOf(e) == 0) {
                                                  type = 'name';
                                                } else if (stype.indexOf(e) ==
                                                    1) {
                                                  type = 'barcode';
                                                } else {
                                                  type = 'intName';
                                                }
                                              });
                                            },
                                            child: Text(e)))
                                        .toList())
                                .then((value) {});
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() => isList = !isList);
                            },
                            child: Icon(isList ? Icons.grid_view : Icons.list),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                !isList
                    ? CustomGridView(pagingController: _pagingController)
                    : CustomListView(pagingController: _pagingController)
              ],
            ),
          );
        },
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
}
