// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/search_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/public_uses/product/product_detail_page.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 10,
                    child: CustomSearchBar(
                      searchController: _searchController,
                      onChanged: (value) {},
                      onSubmitted: (value) {
                        setState(() {});
                        _pagingController.refresh();
                      },
                      title: ' хайх',
                      suffix: IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: () {
                          showMenu(
                            surfaceTintColor: Colors.white,
                            context: context,
                            position:
                                const RelativeRect.fromLTRB(150, 20, 0, 0),
                            items: <PopupMenuEntry>[
                              PopupMenuItem(
                                onTap: () {},
                                child: const Text('Нэрээр'),
                              ),
                              PopupMenuItem(
                                onTap: () {},
                                child: const Text('Баркодоор'),
                              ),
                              PopupMenuItem(
                                onTap: () {},
                                child: const Text('Ерөнхий нэршлээр'),
                              ),
                            ],
                          ).then((value) {});
                        },
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
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
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
                : PagedSliverList<int, dynamic>(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
          ],
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

