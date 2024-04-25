import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/product_controller.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/suppliers/product_detail_page.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SupplierDetail extends StatefulWidget {
  final Supplier supp;

  const SupplierDetail({super.key, required this.supp});

  @override
  State<SupplierDetail> createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail> {
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController = PagingController(firstPageKey: 1);
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
      final newItems = await SearchProvider.getProdList(pageKey, _pageSize);
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
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Scaffold(
        // appBar: AppBar(
        //   iconTheme: const IconThemeData(color: AppColors.primary),
        //   centerTitle: true,
        //   title: const Text(
        //     'Миний сагс',
        //     style: TextStyle(fontSize: 16),
        //   ),
        //   actions: [
        //     Container(
        //       margin: const EdgeInsets.only(right: 15),
        //       child: InkWell(
        //         onTap: () {
        //           Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
        //         },
        //         child: badges.Badge(
        //           badgeContent: Text(
        //             "${basketProvider.count}",
        //             style: const TextStyle(color: Colors.white, fontSize: 11),
        //           ),
        //           badgeStyle: const badges.BadgeStyle(
        //             badgeColor: Colors.blue,
        //           ),
        //           child: const Icon(
        //             Icons.shopping_basket,
        //             color: Colors.red,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        appBar: const CustomAppBar(
          title: 'Нийлүүлэгчийн бараанууд',
        ),
        body: ChangeNotifierProvider(
          create: (context) => ProductController(),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          prod: item,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            // ignore: prefer_interpolation_to_compose_strings
                            child: (item.images != null && item.images.length > 0) ? Image.network('http://192.168.88.39:8000' + item.images.first['url']) : Image.asset('assets/no_image.jpg'),
                          ),
                        ),
                        Text(
                          item.name,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                        Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Text(
                            item.price + ' ₮',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            item.modified_at,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
      ),
    );
  }

  Future<void> _fetchPageByName(int pageKey, String searchQuery) async {
    try {
      final newItems = await SearchProvider.getProdListByName(pageKey, _pageSize, searchQuery);
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
      final newItems = await SearchProvider.getProdListByBarcode(pageKey, _pageSize, searchQuery);
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
      final newItems = await SearchProvider.getProdListByIntName(pageKey, _pageSize, searchQuery);
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
}
