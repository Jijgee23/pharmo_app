// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.paging();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => homeProvider.refreshCntrl());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => homeProvider.pagingController.refresh(),
      ),
      child: Consumer<HomeProvider>(
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
                            Future.delayed(const Duration(milliseconds: 1500),
                                () {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                if (search.text.isNotEmpty) {
                                  homeProvider.changeSearching(true);
                                  homeProvider.changeQueryValue(v);
                                  homeProvider.pagingController.refresh();
                                } else {
                                  homeProvider.changeSearching(false);
                                  homeProvider.pagingController
                                      .removePageRequestListener((pageKey) {});
                                  homeProvider.pagingController.refresh();
                                }
                              });
                            });
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
                                                homeProvider
                                                    .setQueryType('name');
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
                    ? CustomGridView(
                        pagingController: homeProvider.pagingController)
                    : CustomListView(
                        pagingController: homeProvider.pagingController)
              ],
            ),
          );
        },
      ),
    );
  }
}
