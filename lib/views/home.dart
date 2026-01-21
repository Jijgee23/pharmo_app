import 'package:pharmo_app/views/public/filter/filter.dart';
import 'package:pharmo_app/views/public/product/product_widget.dart';
import 'package:pharmo_app/application/application.dart';

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
  final ScrollController _scrollController = ScrollController();
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await initPublic(),
    );
  }

  Future initPublic() async {
    final home = context.read<HomeProvider>();
    final basket = context.read<BasketProvider>();
    setLoading(true);
    final security = LocalBase.security;
    if (security == null) return;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        home.fetchMoreProducts();
      }
    });
    home.clearItems();
    home.setPageKey(1);
    await home.fetchProducts();
    await basket.getBasket();
    if (mounted) setLoading(false);
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
  void setSelectedFilter(String n) {
    setState(() {
      selectedFilter = n;
    });
  }

  Future<void> refresh() async {
    setLoading(true);
    final homeProvider = context.read<HomeProvider>();
    await homeProvider.clearItems();
    await homeProvider.setPageKey(1);
    await homeProvider.fetchProducts();
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PromotionProvider>(
      builder: (_, home, promotionProvider, child) {
        return Scaffold(
          body: Builder(builder: (context) {
            if (loading) {
              return shimmer();
            }
            return RefreshIndicator.adaptive(
              onRefresh: () async => await refresh(),
              child: Column(
                children: [
                  if (LocalBase.security != null &&
                      LocalBase.security!.role == 'PA')
                    filtering(Sizes.smallFontSize),
                  products(home),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget shimmer() {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, idx) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ShimmerBox(controller: controller, height: 150),
        );
      },
    );
  }

  Widget products(HomeProvider home) {
    if (LocalBase.security!.role == 'PA' && home.picked.id.toString() == '-1' ||
        home.picked == null) {
      return errorWidget();
    } else {
      if (home.isList) {
        return Flexible(
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
  SingleChildScrollView filtering(double smallFontSize) {
    final homeProvider = context.read<HomeProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10,
        children: [
          filt(e: 'Ангилал', ontap: () => goto(const FilterPage())),
          filt(
            e: 'Бүгд',
            ontap: () {
              setSelectedFilter('Бүгд');
              homeProvider.setPageKey(1);
              homeProvider.fetchProducts();
            },
          ),
          ...filterNames.map(
            (e) => filt(
              e: e,
              ontap: () {
                setSelectedFilter(e);
                homeProvider.filterProducts(
                  filterss[filterNames.indexOf(e)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filt({
    required String e,
    required Function() ontap,
  }) {
    bool selected = (e == selectedFilter);
    final side = selected ? BorderSide.none : BorderSide(color: grey400);
    return ElevatedButton(
      onPressed: ontap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primary : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: side,
        ),
      ),
      child: Text(
        e,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? white : black,
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
  const Products({
    super.key,
    required this.controller,
    required this.products,
  });
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: products.length,
      itemBuilder: (context, idx) {
        Product product = products[idx];
        return ProductWidget(item: product);
      },
    );
  }
}
