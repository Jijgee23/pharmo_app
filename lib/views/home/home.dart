import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/views/home/widgets/filter_chip.dart';
import 'package:pharmo_app/views/home/widgets/modern_field.dart';
import 'package:pharmo_app/views/home/widgets/modern_icon.dart';
import 'package:pharmo_app/views/home/widgets/selected_filter.dart';
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
        final user = LocalBase.security;
        if (user == null) return SizedBox();
        return SafeArea(
          child: RefreshIndicator.adaptive(
            onRefresh: () async => await refresh(),
            child: Column(
              spacing: 5,
              children: [
                if (user.role == 'PA')
                  Padding(
                    key: actoinKey,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => handleActionButton(home),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary.shade600,
                              elevation: 0,
                              minimumSize: Size(double.maxFinite, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  10,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  home.picked.name,
                                  style: TextStyle(
                                    color: white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  color: white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  spacing: 10,
                  children: [
                    ModernField(
                      onChanged: (v) => onfieldChanged(v, home),
                      onSubmited: (v) => onFieldSubmitted(v, home),
                      hint: '${home.searchType} хайх',
                      suffixIcon: IconButton(
                        onPressed: () => setFilter(home),
                        icon: Icon(Icons.settings),
                      ),
                    ),
                    ModernIcon(
                      iconData:
                          home.isList ? Icons.grid_view : Icons.list_sharp,
                      onPressed: () => home.switchView(),
                    ),
                    // CartIcon(),
                  ],
                ).paddingSymmetric(horizontal: 10),
                if (user.role == 'PA') filtering(Sizes.smallFontSize),
                products(home),
              ],
            ),
          ),
        );
      },
    );
  }

  setFilter(HomeProvider home) {
    mySheet(
      isDismissible: true,
      title: 'Хайлтын төрөл сонгоно уу?',
      children: [
        ...home.stype.map(
          (e) {
            bool selected = e == home.searchType;
            return SelectedFilter(
              selected: selected,
              caption: e,
              onSelect: () {
                home.setQueryTypeName(e);
                int index = home.stype.indexOf(e);
                if (index == 0) {
                  home.setQueryType('name');
                } else if (index == 1) {
                  home.setQueryType('barcode');
                }
              },
            );
          },
        )
      ],
    );
  }

  onfieldChanged(String v, HomeProvider home) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        home.setPageKey(1);
        home.fetchProducts();
      } else {
        home.filterProduct(v);
      }
    });
  }

  onFieldSubmitted(String v, HomeProvider home) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (v.isEmpty || v == '') {
        home.setPageKey(1);
        home.fetchProducts();
      } else {
        home.filterProduct(v);
      }
    });
  }

  final actoinKey = GlobalKey();

  void handleActionButton(HomeProvider home) async {
    List<Stock> all = [];
    for (Supplier sup in home.supliers) {
      all.addAll(sup.stocks);
    }
    mySheet(
      title: 'Нийлүүлэгч сонгох',
      isDismissible: true,
      spacing: 0,
      children: all.map((e) => stockBuilder(e, home, context)).toList(),
    );
  }

  Widget products(HomeProvider home) {
    return Expanded(
      child: Builder(
        builder: (context) {
          if (LocalBase.security!.role == 'PA' &&
                  home.picked.id.toString() == '-1' ||
              home.picked == null) {
            return errorWidget();
          }
          if (loading) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (_, idx) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ShimmerBox(controller: controller, height: 150),
                );
              },
            );
          }
          if (home.isList) {
            return ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, idx) => SizedBox(height: 10),
              padding: EdgeInsets.all(10),
              itemCount: home.fetchedItems.length,
              controller: _scrollController,
              itemBuilder: (context, idx) {
                Product product = home.fetchedItems[idx];
                return ProductWidgetListView(item: product);
              },
            );
          }
          return GridView.builder(
            padding: EdgeInsets.all(10),
            controller: _scrollController,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Sizes.isTablet() ? 3 : 2,
              childAspectRatio: .9,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: home.fetchedItems.length,
            itemBuilder: (context, idx) {
              Product product = home.fetchedItems[idx];
              return ProductWidget(item: product);
            },
          );
        },
      ),
    );
  }

  // Эрэлттэй, Шинэ, Хямдралтай
  SingleChildScrollView filtering(double smallFontSize) {
    final homeProvider = context.read<HomeProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10,
        children: [
          PharmoFilterChip(
            caption: 'Ангилал',
            onPressed: () => goto(const FilterPage()),
          ),
          PharmoFilterChip(
            caption: 'Бүгд',
            selected: 'Бүгд' == selectedFilter,
            onPressed: () {
              setSelectedFilter('Бүгд');
              homeProvider.setPageKey(1);
              homeProvider.fetchProducts();
            },
          ),
          ...filterNames.map(
            (e) => PharmoFilterChip(
              caption: e,
              selected: e == selectedFilter,
              onPressed: () {
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

  Widget stockBuilder(Stock e, HomeProvider home, BuildContext context) {
    final supplier = home.supliers.firstWhere((sup) => sup.stocks.contains(e));
    bool hasImage = supplier.logo != null;
    bool selected = home.selected.id == e.id;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: ListTile(
        onTap: () => onPickSupp(supplier, e, home, context),
        dense: true,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueGrey.shade200,
          backgroundImage: hasImage
              ? NetworkImage('${dotenv.env['IMAGE_URL']}${supplier.logo!}')
              : null,
          child: (!hasImage)
              ? Text(
                  supplier.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * 0.9,
                  ),
                )
              : null,
        ),
        title: Text(
          supplier.name,
          style: TextStyle(
            color: selected ? primary : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '(${e.name})',
          style: TextStyle(
            color: selected ? primary : black,
          ),
        ),
        trailing: selected
            ? Icon(
                Icons.check,
                color: primary,
              )
            : null,
      ),
    );
  }

  onPickSupp(
    Supplier e,
    Stock stock,
    HomeProvider home,
    BuildContext context,
  ) async {
    Navigator.pop(context);
    await home.pickSupplier(e, stock, context);
    home.clearItems();
    home.setPageKey(1);
    home.fetchProducts();
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
