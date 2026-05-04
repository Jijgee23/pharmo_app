import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/authentication/auth_error.dart';
import 'package:pharmo_app/views/product/product_widget.dart';
import 'package:pharmo_app/views/public/filter/filter.dart';

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
    final cart = context.read<CartProvider>();
    setLoading(true);
    final security = Authenticator.security;
    if (security == null) return;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          home.hasMore) {
        home.fetchMoreProducts();
      }
    });
    home.clearItems();
    home.setPageKey(1);
    await home.fetchProducts();
    await cart.getBasket();
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
  List<String> filterss = ['discount__gt=0', 'supplier_indemand_products', 'ordering=-created_at'];
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
        final user = Authenticator.security;
        if (user == null) return SizedBox();
        return SafeArea(
          child: Material(
            child: RefreshIndicator.adaptive(
              onRefresh: () async => await refresh(),
              child: Column(
                spacing: 10,
                children: [
                  // if (user.isPharmacist)
                  GestureDetector(
                    onTap: () => handleActionButton(home),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary.shade500, primary.shade700],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(Icons.storefront_outlined, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              home.picked.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.85), size: 20),
                        ],
                      ),
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
                        iconData: home.isList ? Icons.grid_view : Icons.list_sharp,
                        onPressed: () => home.switchView(),
                      ),
                      // CartIcon(),
                    ],
                  ),
                  // if (user.role == 'PA')
                  filtering(smallFontSize),
                  products(home),
                ],
              ),
            ).paddingSymmetric(horizontal: 10),
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
        home.clearItems();
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
      title: ' ${Authenticator.security!.isPharmacist ? "Нийлүүлэгч" : "Агуулах"} сонгох',
      isDismissible: true,
      spacing: 0,
      children: all.map((e) => stockBuilder(e, home, context)).toList(),
    );
  }

  Widget products(HomeProvider home) {
    var del = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.isTablet ? 3 : 2,
      childAspectRatio: 0.75,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      mainAxisExtent: 250,
    );
    final user = Authenticator.security;

    return Expanded(
      child: Builder(
        builder: (context) {
          if (user == null) {
            return AuthError();
          }
          if (user.isPharmacist && (home.picked.id.toString() == '-1' || home.picked == null)) {
            return errorWidget();
          }
          if (loading) {
            return GridView.builder(
              gridDelegate: del,
              itemBuilder: (_, idx) {
                return ShimmerBox(controller: controller, height: 150);
              },
            );
          }
          if (home.fetchedItems.isEmpty) {
            return NoResult();
          }
          if (home.isList) {
            return ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, idx) => SizedBox(height: 10),
              itemCount: home.fetchedItems.length + 1,
              controller: _scrollController,
              itemBuilder: (context, idx) {
                if (idx == home.fetchedItems.length) return _fetchFooter(home);
                Product product = home.fetchedItems[idx];
                return ProductWidgetListView(item: product);
              },
            );
          }
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverGrid(
                gridDelegate: del,
                delegate: SliverChildBuilderDelegate(
                  (context, idx) => ProductWidget(item: home.fetchedItems[idx]),
                  childCount: home.fetchedItems.length,
                ),
              ),
              SliverToBoxAdapter(child: _fetchFooter(home)),
            ],
          );
        },
      ),
    );
  }

  // Эрэлттэй, Шинэ, Хямдралтай
  SingleChildScrollView filtering(double smallFontSize) {
    final homeProvider = context.read<HomeProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10,
        children: [
          PharmoFilterChip(
            caption: 'Ангилал',
            icon: Icons.tune_rounded,
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
    final bool hasImage = supplier.logo != null;
    final bool selected = home.selected.id == e.id;

    return GestureDetector(
      onTap: () => onPickSupp(supplier, e, home, context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary.withOpacity(0.4) : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? primary.withOpacity(0.15) : Colors.grey.shade100,
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage('${dotenv.env['IMAGE_URL']}${supplier.logo!}'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? Center(
                        child: Text(
                          supplier.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: selected ? primary : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selected ? primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? primary.withOpacity(0.8) : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected
                    ? Container(
                        key: const ValueKey('check'),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      )
                    : SizedBox(
                        key: const ValueKey('empty'),
                        width: 24,
                        height: 24,
                      ),
              ),
            ],
          ),
        ),
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

  Widget _fetchFooter(HomeProvider home) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: home.hasMore
            ? const CircularProgressIndicator.adaptive()
            : Text(
                'Нийт ${home.totalCount} бараа харуулж байна',
                style: TextStyle(color: Colors.grey, fontSize: smallFontSize),
              ),
      ),
    );
  }

  Widget errorWidget() {
    return Text(
      'Нийлүүлэгч сонгоно уу!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.red,
        fontSize: mediumFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
