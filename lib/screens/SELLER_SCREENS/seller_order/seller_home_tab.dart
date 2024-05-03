// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/filter.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

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
  Color selectedColor = AppColors.failedColor;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (_searchController.text.isNotEmpty && searchType == 'Нэрээр') {
          _fetchPageByName(pageKey, searchQuery);
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
      print(_pagingController.error);
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
      print(_pagingController.error);
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
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: StickyHeaderDelegate(
                      minHeight: MediaQuery.of(context).size.height * 0.145,
                      maxHeight: MediaQuery.of(context).size.height * 0.15,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
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
                                        icon: const Icon(
                                            Icons.change_circle_sharp),
                                        onPressed: () {
                                          showMenu(
                                            context: context,
                                            position:
                                                const RelativeRect.fromLTRB(
                                                    150, 20, 0, 0),
                                            items: <PopupMenuEntry>[
                                              PopupMenuItem(
                                                value: 'item1',
                                                onTap: () {
                                                  setState(() {
                                                    searchType = 'нэрээр';
                                                  });
                                                },
                                                child: const Text('нэрээр'),
                                              ),
                                              PopupMenuItem(
                                                value: 'item2',
                                                onTap: () {
                                                  setState(() {
                                                    searchType = 'баркодоор';
                                                  });
                                                },
                                                child: const Text('Баркодоор'),
                                              ),
                                              PopupMenuItem(
                                                value: 'item3',
                                                onTap: () {
                                                  setState(() {
                                                    searchType =
                                                        'ерөнхий нэршлээр';
                                                  });
                                                },
                                                child: const Text(
                                                    'Ерөнхий нэршлээр'),
                                              ),
                                            ],
                                          ).then((value) {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        if (isList) {
                                          isList = false;
                                          viewIcon = Icons.grid_view;
                                        } else {
                                          isList = true;
                                          viewIcon = Icons.list;
                                        }
                                      },
                                    );
                                  },
                                  icon: Icon(viewIcon),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 10,
                                children: [
                                  CustomFitler(
                                    selected: !isem,
                                    text: 'Эм',
                                    onSelected: (bool value) {
                                      setState(() {
                                        isem = !isem;
                                      });
                                    },
                                  ),
                                  CustomFitler(
                                    selected: !isvita,
                                    text: 'Витамин',
                                    onSelected: (bool value) {
                                      setState(() {
                                        isvita = !isvita;
                                      });
                                    },
                                  ),
                                  CustomFitler(
                                    selected: !isprod,
                                    text: 'Эрүүл мэндийн хэрэгсэл, төхөөрөмж',
                                    onSelected: (bool value) {
                                      setState(() {
                                        isprod = !isprod;
                                      });
                                    },
                                  ),
                                  CustomFitler(
                                    selected: !isother,
                                    text: 'Бусад',
                                    onSelected: (bool value) {
                                      setState(() {
                                        isother = !isother;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: !isList
                  ? PagedGridView<int, dynamic>(
                      showNewPageProgressIndicatorAsGridChild: false,
                      showNewPageErrorIndicatorAsGridChild: false,
                      showNoMoreItemsIndicatorAsGridChild: false,
                      pagingController: _pagingController,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
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
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: OutlinedButton(
                                    child: Text(
                                      'Сагсанд нэмэх',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : PagedListView<int, dynamic>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (_, item, index) {
                          return Card(
                              child: InkWell(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                          ));
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
