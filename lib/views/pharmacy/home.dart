import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/others/no_items.dart';
import 'package:pharmo_app/widgets/product/product_widget.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IconData viewIcon = Icons.grid_view;
  int pageKey = 1;
  bool hasSale = true;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  late PromotionProvider promotionProvider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreProducts();
      }
    });
    fetchProducts(pageKey);
    basketProvider.getBasket();
    if (homeProvider.userRole == 'PA') {
      initPharmo();
    }
  }

  void _fetchMoreProducts() async {
    setState(() {
      pageKey = pageKey + 1;
      fetchProducts(pageKey);
    });
  }

  clearItems() {
    setState(() {
      fetchedItems.clear();
    });
  }

  setPage(int n) {
    setState(() {
      pageKey = n;
    });
  }

  refresh() {
    setPage(1);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  initPharmo() async {
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    // await promotionProvider.getMarkedPromotion();

    // await homeProvider.getBranches();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (promotionProvider.markedPromotions.isNotEmpty) {
    //     homeProvider.showMarkedPromos(context, promotionProvider);
    //   }
    // });
  }

  List<Product> fetchedItems = [];
  setItems(List<Product> items) {
    setState(() {
      fetchedItems.addAll(items);
    });
  }

  // Барааны жагсаалт авах
  Future<void> fetchProducts(int pageKey) async {
    List<Product> items = await homeProvider.getProducts(pageKey);
    if (items.isNotEmpty) {
      setItems(items);
    }
  }

  filterProducts(String query) async {
    List<Product> items = await homeProvider.getProductsByQuery(query);
    if (items.isNotEmpty) {
      setState(() {
        fetchedItems.clear();
      });
      setItems(items);
    }
  }

  List<IconData> icons = [Icons.discount, Icons.star, Icons.new_releases];

  goFilt(String query, String title, bool hasSale) async {
    goto(FilteredProducts(query: query, title: title));
  }

  bool isCategoryView = false;
  setIsCategoryView(bool n) {
    setState(() {
      isCategoryView = n;
    });
  }

  List<String> filters = ['Хямдралтай', 'Эрэлттэй', 'Шинэ'];

  @override
  Widget build(BuildContext context) {
    // final smallFontSize = Sizes.height * .0125;
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        refresh();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          homeProvider.refresh(context, homeProvider, promotionProvider);
        });
      }),
      child: Consumer3<HomeProvider, BasketProvider, PromotionProvider>(
        builder: (_, homeProvider, basketProvider, promotionProvider, child) {
          final search = homeProvider.searchController;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                searchBar(
                  context,
                  homeProvider,
                  basketProvider,
                  Sizes.smallFontSize,
                  search,
                ),
                if (homeProvider.userRole == 'PA')
                  filtering(Sizes.smallFontSize),
                fetchedItems.isNotEmpty
                    ? products(homeProvider)
                    : Column(
                        children: [
                          SizedBox(height: Sizes.height / 5),
                          const NoItems()
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Хайлт
  searchBar(
    BuildContext context,
    HomeProvider homeProvider,
    BasketProvider basketProvider,
    double smallFontSize,
    TextEditingController search,
  ) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: getDecoration(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (homeProvider.userRole == 'PA')
                  IntrinsicWidth(
                    child: InkWell(
                      onTap: () => _onPickSupplier(context),
                      child: Text(
                        '${homeProvider.supName} :',
                        style: TextStyle(
                          fontSize: Sizes.mediumFontSize - 2,
                          color: AppColors.succesColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  cursorHeight: smallFontSize,
                  style: TextStyle(fontSize: Sizes.mediumFontSize),
                  decoration: InputDecoration(
                    hintText: '${homeProvider.searchType} хайх',
                    hintStyle: TextStyle(
                        fontSize: Sizes.mediumFontSize - 2,
                        color: Colors.black),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) => _onfieldChanged(v),
                  onFieldSubmitted: (v) => _onFieldSubmitted(v),
                )),
                InkWell(
                    onTap: () => _changeSearchType(),
                    child: const Icon(Icons.keyboard_arrow_down_rounded)),
                const SizedBox(width: 5),
                InkWell(
                  onTap: () => homeProvider.switchView(),
                  child: Icon(
                    homeProvider.isList ? Icons.grid_view : Icons.list_sharp,
                    color: black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _changeSearchType() {
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(150, 120, 0, 0),
      items: homeProvider.stype
          .map(
            (e) => PopupMenuItem(
              onTap: () {
                homeProvider.setQueryTypeName(e);
                int index = homeProvider.stype.indexOf(e);
                if (index == 0) {
                  homeProvider.setQueryType('name');
                } else if (index == 1) {
                  homeProvider.setQueryType('barcode');
                }
              },
              child: Text(
                e,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: Sizes.smallFontSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Хайлт функц
  _onfieldChanged(String v) {
    if (v.isNotEmpty) {
      filterProducts(v);
    } else {
      fetchProducts(pageKey);
    }
  }

  _onFieldSubmitted(String v) {
    if (v.isEmpty) {
      fetchProducts(pageKey);
    } else {
      filterProducts(v);
    }
  }

  Widget products(HomeProvider homeProvider) {
    if (homeProvider.supID == 0 || homeProvider.supID == null) {
      return errorWidget();
    } else {
      if (homeProvider.isList) {
        return Expanded(
          child: ListView.builder(
            itemCount: fetchedItems.length,
            controller: _scrollController,
            itemBuilder: (context, idx) {
              Product product = fetchedItems[idx];
              return ProductWidgetListView(item: product);
            },
          ),
        );
      } else {
        return Expanded(
          child: GridView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: fetchedItems.length,
            itemBuilder: (context, idx) {
              Product product = fetchedItems[idx];
              return ProductWidget(item: product);
            },
          ),
        );
      }
    }
  }

  // Эрэлттэй, Шинэ, Хямдралтай
  filtering(double smallFontSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(2.5),
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 10,
        children: [
          filt(e: 'Ангилал', icon: Icons.list, ontap: () => onTapCategory()),
          ...filters.map(
            (e) => filt(
              e: e,
              icon: icons[filters.indexOf(e)],
              ontap: () => ontapFilter(e),
            ),
          ),
        ],
      ),
    );
  }

  onTapCategory() {
    goto(const FilterPage());
  }

  ontapFilter(String e) {
    if (filters.indexOf(e) == 0) {
      goFilt('discount__gt=0', 'Хямдралтай', true);
    } else if (filters.indexOf(e) == 1) {
      goFilt('ordering=-created_at', 'Эрэлттэй', false);
    } else {
      goFilt('supplier_indemand_products/', 'Шинэ', false);
    }
  }

  filt({required String e, required IconData icon, required Function() ontap}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: getDecoration(context),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.secondary, size: 20),
              const SizedBox(width: 5),
              Text(e, style: TextStyle(fontSize: Sizes.smallFontSize + 2)),
            ],
          ),
        ),
      ),
    );
  }

  // Нийлүүлэгч сонгох
  _onPickSupplier(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showMenu(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
        size.width * 0.02,
        size.height * 0.15,
        size.width * 0.8,
        0,
      ),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: homeProvider.supList
          .map(
            (e) => PopupMenuItem(
              onTap: () async => await onPickSupp(e),
              child: Text(
                e.name,
                style: TextStyle(
                  color: e.name == homeProvider.supName
                      ? AppColors.succesColor
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  onPickSupp(Supplier e) async {
    await homeProvider.pickSupplier(int.parse(e.id), context);
    await homeProvider.changeSupName(e.name);
    homeProvider.setSupId(int.parse(e.id));
    basketProvider.getBasket();
    clearItems();
    fetchProducts(pageKey);
    // await promotionProvider.getMarkedPromotion();
    homeProvider.refresh(context, homeProvider, promotionProvider);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (promotionProvider.markedPromotions.isNotEmpty) {
    //     homeProvider.showMarkedPromos(context, promotionProvider);
    //   }
    // });
    // Navigator.pop(context);
  }

  Widget errorWidget() {
    return Text(
      'Нийлүүлэгч сонгоно уу!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.red,
        fontSize: Sizes.mediumFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

getDecoration(BuildContext context) {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor,
        blurRadius: 10,
        // offset: const Offset(5, 5),
        blurStyle: BlurStyle.normal,
      )
    ],
    borderRadius: BorderRadius.circular(30),
  );
}

class Products extends StatelessWidget {
  final ScrollController controller;
  final List<Product> products;
  const Products({super.key, required this.controller, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: products.length,
      itemBuilder: (context, idx) {
        Product product = products[idx];
        return ProductWidget(item: product);
      },
    );
  }
}

class FilteredProducts extends StatefulWidget {
  final String query;
  final String title;
  const FilteredProducts({super.key, required this.query, required this.title});

  @override
  State<FilteredProducts> createState() => _FilteredProductsState();
}

class _FilteredProductsState extends State<FilteredProducts> {
  List<Product> items = [];
  late HomeProvider home;
  setItems() async {
    final prods = await home.filterProducts(widget.query);
    setState(() {
      items.addAll(prods);
    });
  }

  @override
  initState() {
    super.initState();
    home = Provider.of<HomeProvider>(context, listen: false);
    setItems();
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: const ChevronBack(),
        title: Text(widget.title, style: Constants.headerTextStyle),
      ),
      body: Products(
        controller: scrollController,
        products: items,
      ),
    );
  }
}
