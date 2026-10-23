import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/product/product_widget.dart';

/// The products matching [query] on GET products/, page by page.
class FilteredProducts extends StatefulWidget {
  final String title;

  /// products/ filters, e.g. `{'category': '[12,15]'}` or `{'mnfr': '[3]'}`.
  final Map<String, String> query;

  const FilteredProducts({super.key, required this.title, required this.query});

  @override
  State<FilteredProducts> createState() => _FilteredProductsState();
}

class _FilteredProductsState extends State<FilteredProducts> {
  static const _pageSize = 20;
  final _scrollController = ScrollController();
  final List<Product> products = [];

  /// The last page loaded, 0 before the first.
  int _page = 0;
  int _total = 0;
  bool _loading = false;

  bool get _hasMore => products.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) _loadMore();
  }

  // The next page, unless one is on its way or there are no more.
  Future<void> _loadMore() async {
    if (_loading || (_page > 0 && !_hasMore)) return;
    setState(() => _loading = true);
    final (items, total) = await context
        .read<HomeProvider>()
        .productsPage('products/', widget.query, _page + 1, size: _pageSize);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _page++;
      _total = total;
      products.addAll(items);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      products.clear();
      _page = 0;
      _total = 0;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: widget.title,
        subtitle: _page > 0 ? '$_total бараа' : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            if (products.isEmpty && _loading) {
              return const Center(child: PharmoIndicator());
            }
            if (products.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Бараа олдсонгүй',
                message: 'Энэ ангилалд тохирох бараа байхгүй байна.',
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Products(controller: _scrollController, products: products),
            );
          },
        ),
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
      // Scrollable even when the first page fits, so pull-to-refresh works.
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 3 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, idx) {
        Product product = products[idx];
        return ProductWidget(item: product);
      },
    );
  }
}
