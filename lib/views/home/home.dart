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
  bool hasSale = true;
  late AnimationController controller;

  // This widget is rebuilt each time the bottom bar switches back to it;
  // its search text, listing and scroll position are kept on HomeProvider.
  late final HomeProvider _home;
  late final ScrollController _scrollController;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _home = context.read<HomeProvider>();
    _scrollController = ScrollController(initialScrollOffset: _home.productScrollOffset)
      ..addListener(_onScroll);
    _search = TextEditingController(text: _home.query);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await initPublic(),
    );
  }

  Future initPublic() async {
    final cart = context.read<CartProvider>();
    final security = Authenticator.security;
    if (security == null) return;
    // Back on the tab with a listing already loaded: show it as it was.
    if (!_home.productsLoaded) {
      setLoading(true);
      await _home.showAllProducts();
      if (mounted) setLoading(false);
    }
    await cart.getBasket();
  }

  void _onScroll() {
    final position = _scrollController.position;
    _home.productScrollOffset = position.pixels;
    if (position.pixels == position.maxScrollExtent && _home.hasMore) {
      _home.fetchMoreProducts();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  List<IconData> icons = [Icons.discount, Icons.star, Icons.new_releases];

  Future<void> refresh() async {
    setLoading(true);
    await _home.reloadProducts();
    if (mounted) setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, PromotionProvider>(
      builder: (_, home, promotionProvider, child) {
        final user = Authenticator.security;
        if (user == null) return SizedBox();
        return Material(
          child: RefreshIndicator.adaptive(
            onRefresh: () async => await refresh(),
            child: SafeArea(
              bottom: false,
              child: Column(
                spacing: 10,
                children: [
                  if (context.isLandscape) SizedBox(height: 14),
                  if (user.isPharmacist)
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
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.85),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: ModernField(
                          controller: _search,
                          onChanged: (v) => onfieldChanged(v, home),
                          onSubmited: (v) => onFieldSubmitted(v, home),
                          hint: '${home.searchType} хайх',
                          suffixIcon: IconButton(
                            onPressed: () => setFilter(home),
                            icon: Icon(Icons.settings),
                          ),
                        ),
                      ),
                      ModernIcon(
                        iconData: home.isList ? Icons.grid_view : Icons.list_sharp,
                        onPressed: () => home.switchView(),
                      ),
                      // CartIcon(),
                    ],
                  ),
                  if (!home.hidingOnScroll) filtering(smallFontSize),
                  products(home),
                ],
              ),
            ),
          ).paddingSymmetric(horizontal: 10),
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
      if (v.isEmpty) {
        home.showAllProducts();
      } else {
        home.filterProduct(v);
      }
    });
  }

  onFieldSubmitted(String v, HomeProvider home) => onfieldChanged(v, home);

  final actoinKey = GlobalKey();

  void handleActionButton(HomeProvider home) async {
    List<Stock> all = [];
    for (Supplier sup in home.supliers) {
      all.addAll(sup.stocks);
    }
    Get.bottomSheet(
      _SupplierPickerSheet(stocks: all, home: home),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  Widget products(HomeProvider home) {
    var del = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: parseInt(context.width / 250),
      childAspectRatio: 0.75,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    );
    final user = Authenticator.security;

    return Expanded(
      child: HomeScrollListener(
        xchild: Builder(
          builder: (context) {
            if (user == null) {
              return AuthError();
            }
            if (user.isPharmacist && (home.picked.id.toString() == '-1' || home.picked == null)) {
              return errorWidget();
            }
            if (loading) {
              return GridView.builder(
                controller: _scrollController,
                gridDelegate: del,
                itemBuilder: (_, idx) {
                  return ShimmerBox(controller: controller, height: 150);
                },
              );
            }
            if (home.fetchedItems.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Бараа олдсонгүй',
                message: 'Хайлт эсвэл шүүлтүүрээ өөрчлөөд дахин оролдоно уу.',
                padding: EdgeInsets.only(bottom: 100),
              );
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
                SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(bottom: 150)))
              ],
            );
          },
        ),
      ),
    );
  }

  // Эрэлттэй, Шинэ, Хямдралтай
  Widget filtering(double smallFontSize) {
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
            caption: HomeProvider.allProducts,
            selected: homeProvider.productFilter == HomeProvider.allProducts,
            onPressed: () {
              // A chip replaces the search, so the box empties with it.
              _search.clear();
              homeProvider.showAllProducts();
            },
          ),
          for (final name in HomeProvider.quickFilters.keys)
            PharmoFilterChip(
              caption: name,
              selected: homeProvider.productFilter == name,
              onPressed: () {
                _search.clear();
                homeProvider.applyQuickFilter(name);
              },
            ),
        ],
      ),
    );
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

/// Supplier/warehouse picker bottom sheet, opened from [Home.handleActionButton].
/// Filters the already-fetched `stocks` list locally by supplier or
/// stock/warehouse name as the user types — no request round-trip, since
/// the full list is already in memory via `home.supliers`.
class _SupplierPickerSheet extends StatefulWidget {
  final List<Stock> stocks;
  final HomeProvider home;
  const _SupplierPickerSheet({required this.stocks, required this.home});

  @override
  State<_SupplierPickerSheet> createState() => _SupplierPickerSheetState();
}

class _SupplierPickerSheetState extends State<_SupplierPickerSheet> {
  final TextEditingController _query = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Stock> get _filtered {
    if (_search.trim().isEmpty) return widget.stocks;
    final q = _search.trim().toLowerCase();
    return widget.stocks.where((e) {
      final supplier = widget.home.supliers.firstWhere((sup) => sup.stocks.contains(e));
      return supplier.name.toLowerCase().contains(q) || e.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = ' ${Authenticator.security!.isPharmacist ? "Нийлүүлэгч" : "Агуулах"} сонгох';
    final filtered = _filtered;
    return Container(
      constraints: BoxConstraints(maxHeight: context.height * .8),
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ModernField(
                  controller: _query,
                  hint: 'Хайх',
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: filtered.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Илэрц олдсонгүй',
                          compact: true,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (context, idx) => _stockTile(filtered[idx], context),
                        ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stockTile(Stock e, BuildContext context) {
    final home = widget.home;
    final supplier = home.supliers.firstWhere((sup) => sup.stocks.contains(e));
    final bool hasImage = supplier.logo != null;
    final bool selected = home.selected.id == e.id;

    return GestureDetector(
      onTap: () => _pickSupplier(supplier, e, context),
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

  void _pickSupplier(Supplier e, Stock stock, BuildContext context) async {
    Navigator.pop(context);
    await widget.home.pickSupplier(e, stock, context);
    // Same search or quick filter, now against the new supplier's catalogue.
    widget.home.reloadProducts();
  }
}
