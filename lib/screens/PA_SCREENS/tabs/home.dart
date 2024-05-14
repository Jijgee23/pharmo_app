import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _pageSize = 20;
  bool isList = false;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  String email = '';
  String role = '';
  String searchQuery = '';
  bool isem = true;
  bool isvita = true;
  bool isprod = true;
  bool isother = true;
  Color selectedColor = AppColors.failedColor;
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayProducts = <Product>[];
  IconData viewIcon = Icons.grid_view;
  String searchType = 'Нэрээр';
  @override
  void initState() {
    getUserInfo();
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (_searchController.text.isNotEmpty && searchType == 'Нэрээр') {
          _fetchPageByName(pageKey, searchQuery);
        }
        if (_searchController.text.isNotEmpty && searchType == 'Баркодоор') {
          _fetchPageByBarcode(pageKey, searchQuery);
        }
        if (_searchController.text.isNotEmpty &&
            searchType == 'Ерөнхий нэршлээр') {
          _fetchPageByIntName(pageKey, searchQuery);
        }
        if (_searchController.text.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                                      searchType = 'Нэрээр';
                                    });
                                  },
                                  child: const Text('Нэрээр'),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    setState(() {
                                      searchType = 'Баркодоор';
                                    });
                                  },
                                  child: const Text('Баркодоор'),
                                ),
                                PopupMenuItem(
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
            !isList
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
                                    ])
                              ],
                            ),
                          )),
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
                            children: [
                              SizedBox(
                                width: size.width / 6 * 2,
                                child: (item.images != null &&
                                        item.images.length > 0)
                                    ? Image.network(
                                        // ignore: prefer_interpolation_to_compose_strings
                                        'http://192.168.88.39:8000' +
                                            item.images?.first['url'])
                                    : Image.asset('assets/no_image.jpg'),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: size.width / 6 * 3,
                                    child: Text(
                                      item.name,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                  Text(
                                    item.price + ' ₮',
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    item.modified_at,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
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

  Future<void> _fetchPageByIntName(int pageKey, String searchQuery) async {
    try {
      final newItems = await SearchProvider.getProdListByIntName(
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

  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userRole = prefs.getString('userrole');
    setState(() {
      email = useremail.toString();
      role = userRole.toString();
    });
  }
}
