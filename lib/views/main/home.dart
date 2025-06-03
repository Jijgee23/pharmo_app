import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/products.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
import 'package:pharmo_app/views/product/product_widget.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/shimmer_box.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  IconData viewIcon = Icons.grid_view;
  int pageKey = 1;
  bool hasSale = true;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  late PromotionProvider promotionProvider;
  final ScrollController _scrollController = ScrollController();
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    initPublic();
  }

  initPublic() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setLoading(true);
        promotionProvider =
            Provider.of<PromotionProvider>(context, listen: false);
        await promotionProvider.getMarkedPromotion();
        await homeProvider.getBranches();
        _scrollController.addListener(() {
          if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
            homeProvider.fetchMoreProducts();
          }
        });
        homeProvider.clearItems();
        homeProvider.setPageKey(1);
        homeProvider.fetchProducts();
        basketProvider.getBasket();
        if (homeProvider.userRole == 'PA' &&
            promotionProvider.markedPromotions.isNotEmpty) {
          homeProvider.showMarkedPromos();
        }
        if (mounted) setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<IconData> icons = [Icons.discount, Icons.star, Icons.new_releases];

  List<String> filterNames = ['Хямдралтай', 'Эрэлттэй', 'Шинэ'];
  List<String> filterss = [
    'discount__gt=0',
    'supplier_indemand_products',
    'ordering=-created_at'
  ];
  String selectedFilter = 'Бүгд';
  setSelectedFilter(String n) {
    setState(() {
      selectedFilter = n;
    });
  }

  refresh() async {
    setLoading(true);
    await homeProvider.clearItems();
    await homeProvider.setPageKey(1);
    await homeProvider.fetchProducts();
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PromotionProvider>(
      builder: (_, home, promotionProvider, child) {
        return DataScreen(
          onRefresh: () => refresh(),
          loading: loading,
          empty: home.fetchedItems.isEmpty,
          customLoading: shimmer(),
          pad: EdgeInsets.all(5.0),
          child: Column(
            children: [
              if (home.userRole == 'PA') filtering(Sizes.smallFontSize),
              products(home),
            ],
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return Center(
      child: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (_, idx) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ShimmerBox(controller: controller, height: 150),
          );
        },
      ),
    );
  }

  Widget products(HomeProvider home) {
    if (home.userRole == 'PA' && home.picked.id == '-1' ||
        home.picked == null) {
      return errorWidget();
    } else {
      if (home.isList) {
        return Expanded(
          child: ListView.builder(
            itemCount: home.fetchedItems.length,
            controller: _scrollController,
            itemBuilder: (context, idx) {
              Product product = home.fetchedItems[idx];
              return ProductWidgetListView(item: product);
            },
          ),
        );
      } else {
        return Expanded(
          child: GridView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Sizes.isTablet() ? 3 : 2,
              childAspectRatio: .9,
            ),
            itemCount: home.fetchedItems.length,
            itemBuilder: (context, idx) {
              Product product = home.fetchedItems[idx];
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
          filt(
              e: 'Ангилал',
              icon: Icons.list,
              ontap: () => goto(const FilterPage())),
          filt(
              e: 'Бүгд',
              icon: Icons.list,
              ontap: () {
                setSelectedFilter('Бүгд');
                homeProvider.setPageKey(1);
                homeProvider.fetchProducts();
              }),
          ...filterNames.map(
            (e) => filt(
                e: e,
                icon: icons[filterNames.indexOf(e)],
                ontap: () {
                  setSelectedFilter(e);
                  homeProvider.filterProducts(filterss[filterNames.indexOf(e)]);
                }),
          ),
        ],
      ),
    );
  }

  filt({required String e, required IconData icon, required Function() ontap}) {
    bool selected = (e == selectedFilter);
    return InkWell(
      splashColor: transperant,
      highlightColor: transperant,
      onTap: ontap,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor.withOpacity(.5) : Colors.white,
          borderRadius: BorderRadius.circular(Sizes.smallFontSize),
        ),
        padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: selected ? Sizes.bigFontSize : Sizes.smallFontSize),
        child: Center(
          child: Text(
            e,
            style: const TextStyle(
              fontSize: Sizes.smallFontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget errorWidget() {
    return const Text(
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
