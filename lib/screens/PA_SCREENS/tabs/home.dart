import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/screens/suppliers/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/filter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1);
  String type = 'нэрээр';
  String searchQuery = '';
  bool isem = true;
  bool isvita = true;
  bool isprod = true;
  bool isother = true;
  Color selectedColor = AppColors.failedColor;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (_searchController.text.isNotEmpty && type == 'нэрээр') {
          _fetchPageByName(pageKey, searchQuery);
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: TextField(
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
          ),
          resizeToAvoidBottomInset: false,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverPersistentHeader(
                  pinned: false,
                  delegate: StickyHeaderDelegate(
                    minHeight: MediaQuery.of(context).size.height * 0.071,
                    maxHeight: MediaQuery.of(context).size.height * 0.071,
                    child: Column(
                      children: [
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
            body: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: PagedGridView<int, dynamic>(
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
                          print("Container was tapped");
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
                                      // ignore: prefer_interpolation_to_compose_strings
                                      ? Image.network(
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
                                  ])
                            ],
                          ),
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
