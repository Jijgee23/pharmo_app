import 'package:pharmo_app/views/public/filter/filtered_products.dart';
import 'package:pharmo_app/application/application.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().getFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        final tabs = <_TabInfo>[
          if (home.categories.isNotEmpty)
            _TabInfo('Ангилал', Icons.category_rounded),
          if (home.mnfrs.isNotEmpty)
            _TabInfo('Нийлүүлэгч', Icons.local_shipping_rounded),
          if (home.vndrs.isNotEmpty)
            _TabInfo('Үйлдвэрлэгч', Icons.factory_rounded),
        ];
        final views = <Widget>[
          if (home.categories.isNotEmpty) _CategoriesTab(home: home),
          if (home.mnfrs.isNotEmpty)
            _ManufacturerTab(items: home.mnfrs, type: 'mnfr'),
          if (home.vndrs.isNotEmpty)
            _ManufacturerTab(items: home.vndrs, type: 'vndr'),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Ангилал',
                style: context.theme.appBarTheme.titleTextStyle,
              ),
              actions: [CartIcon.forAppBar(), const SizedBox(width: 5)],
              bottom: TabBar(
                indicatorColor: primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: primary,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: tabs
                    .map(
                      (tab) => Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(tab.icon, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              tab.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: views.map((v) {
                return RefreshIndicator(
                  onRefresh: () async => home.refresh(context),
                  child: v,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  const _TabInfo(this.label, this.icon);
}

class _CategoriesTab extends StatelessWidget {
  final HomeProvider home;
  const _CategoriesTab({required this.home});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: home.categories.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: grey50),
      itemBuilder: (context, index) {
        return CategoryItem(cat: home.categories[index]);
      },
    );
  }
}

class _ManufacturerTab extends StatelessWidget {
  final List<Manufacturer> items;
  final String type;
  const _ManufacturerTab({required this.items, required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: grey50),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ManufacturerItem(item: item, type: type);
      },
    );
  }
}

class _ManufacturerItem extends StatelessWidget {
  final Manufacturer item;
  final String type;
  const _ManufacturerItem({required this.item, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => goto(FilteredProducts(
        type: type,
        title: item.name,
        filterKey: item.id,
      )),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: mediumFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.cnt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.cnt}',
                  style: TextStyle(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatefulWidget {
  final Category cat;
  final int depth;

  const CategoryItem({super.key, required this.cat, this.depth = 0});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasChildren =>
      widget.cat.children != null && widget.cat.children!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.depth * 16.0,
              top: 12,
              bottom: 12,
              right: 4,
            ),
            child: Row(
              children: [
                if (widget.depth > 0)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isExpanded ? primary : Colors.grey[400],
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.cat.name,
                    style: TextStyle(
                      fontSize: mediumFontSize,
                      fontWeight:
                          widget.depth == 0 ? FontWeight.w600 : FontWeight.w500,
                      color: isExpanded ? primary : null,
                    ),
                  ),
                ),
                if (_hasChildren)
                  RotationTransition(
                    turns: _iconTurn,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: isExpanded ? primary : Colors.grey[400],
                      size: 20,
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _hasChildren
                  ? widget.cat.children!
                      .map((e) => CategoryItem(
                            cat: e,
                            depth: widget.depth + 1,
                          ))
                      .toList()
                  : [],
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  void _onTap() {
    if (_hasChildren) {
      setState(() => isExpanded = !isExpanded);
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      goto(FilteredProducts(
        type: 'cat',
        title: widget.cat.name,
        filterKey: widget.cat.id,
      ));
    }
  }
}
