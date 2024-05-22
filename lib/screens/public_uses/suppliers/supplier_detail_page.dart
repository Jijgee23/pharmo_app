import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

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
  bool isList = false;
  IconData viewIcon = Icons.grid_view;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, searchQuery);
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
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Нийлүүлэгчийн бараанууд',
        ),
        body: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Expanded(
                  flex: 10,
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
                            position:
                                const RelativeRect.fromLTRB(150, 20, 0, 0),
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
                        icon: const Icon(Icons.swap_vert),
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
          body: !isList
              ? PagedGridView<int, dynamic>(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox(
                                // ignore: prefer_interpolation_to_compose_strings
                                child: (item.images != null &&
                                        item.images.length > 0)
                                    ? Image.network(
                                        'http://192.168.88.39:8000' +
                                            item.images.first['url'])
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
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: OutlinedButton(
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Сагсанд нэмэх',
                                  style: TextStyle(color: Colors.white),
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
                  builderDelegate: PagedChildBuilderDelegate<dynamic>(
                    itemBuilder: (context, item, index) => InkWell(
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
                            horizontal: 15, vertical: 7),
                        width: double.infinity,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                  item.price + ' ₮',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                addBasket(item.id, item.itemname_id);
                              },
                              icon: const Icon(Icons.shopping_cart),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
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
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }
}
