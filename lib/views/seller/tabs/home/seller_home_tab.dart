// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_grid.dart';
import 'package:pharmo_app/widgets/products_views/paged_sliver_list.dart';
import 'package:provider/provider.dart';

class SellerHomeTab extends StatefulWidget {
  const SellerHomeTab({
    super.key,
  });

  @override
  State<SellerHomeTab> createState() => _SellerHomeTabState();
}

class _SellerHomeTabState extends State<SellerHomeTab> {
  late HomeProvider homeProvider;
  bool isList = false;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final items = await homeProvider.getProducts(pageKey);
      final isLastPage = items!.length < homeProvider.pageSize;
      final nextPageKey = pageKey + 1;
      if (isLastPage) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, child) {
        final search = homeProvider.searchController;
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
                        searchController: search,
                        onChanged: (v) {
                          try {
                            Future.delayed(
                              const Duration(milliseconds: 1500),
                              () {
                                if (v.isNotEmpty) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((t) {
                                    homeProvider.changeSearching(true);
                                    homeProvider.changeQueryValue(v);
                                    _pagingController.refresh();
                                  });
                                } else {
                                  print('v: $v');
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((t) {
                                    homeProvider.changeSearching(false);
                                    _pagingController.refresh();
                                  });
                                }
                                print(search.text);
                              },
                            );
                          } catch (e) {
                            print('=============> $e');
                          }
                        },
                        onSubmitted: (v) {
                          if (v.isEmpty) {
                            homeProvider.changeSearching(false);
                            _pagingController.refresh();
                          }
                        },
                        title: '${homeProvider.searchType} хайх',
                        suffix: const Icon(Icons.keyboard_arrow_down_rounded),
                        onTapSuffux: () {
                          showMenu(
                                  surfaceTintColor: Colors.white,
                                  context: context,
                                  position: const RelativeRect.fromLTRB(
                                      150, 140, 0, 0),
                                  items: homeProvider.stype
                                      .map((e) => PopupMenuItem(
                                          onTap: () {
                                            homeProvider.setQueryTypeName(e);
                                            int index =
                                                homeProvider.stype.indexOf(e);
                                            if (index == 0) {
                                              homeProvider.setQueryType('name');
                                            } else if (index == 1) {
                                              homeProvider
                                                  .setQueryType('barcode');
                                            } else {
                                              homeProvider
                                                  .setQueryType('intName');
                                            }
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
                          onTap: () => homeProvider.switchView(),
                          child: Icon(homeProvider.isList
                              ? Icons.grid_view
                              : Icons.list),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              !homeProvider.isList
                  ? CustomGridView(pagingController: _pagingController)
                  : CustomListView(pagingController: _pagingController)
            ],
          ),
        );
      },
    );
  }
}
