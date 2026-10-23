import 'package:pharmo_app/views/public/filter/filtered_products.dart';
import 'package:pharmo_app/application/application.dart';

/// The supplier's categories, manufacturers and vendors (product/filters/),
/// each leading to the products filed under it. A list the supplier turned
/// off (show_cat, show_mnfr, show_vndr) comes back empty and gets no tab.
class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await context.read<HomeProvider>().getFilters();
    if (mounted) setState(() => _loading = false);
  }

  String get _query => _search.text.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        final tabs = <_Tab>[
          if (home.categories.isNotEmpty) _Tab('Ангилал', _CategoriesView(home.categories, _query)),
          if (home.mnfrs.isNotEmpty) _Tab('Үйлдвэрлэгч', _BrandsView(home.mnfrs, 'mnfr', _query)),
          if (home.vndrs.isNotEmpty) _Tab('Нийлүүлэгч', _BrandsView(home.vndrs, 'vndr', _query)),
        ];
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F9F9),
            appBar: const ModernAppBar(title: 'Ангилал'),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: ModernField(
                    controller: _search,
                    hint: 'Ангилал, үйлдвэрлэгч хайх',
                    onChanged: (_) => setState(() {}),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => setState(_search.clear),
                            icon: Icon(Icons.close_rounded, size: 18, color: grey500),
                          ),
                  ),
                ),
                if (tabs.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _Segments(tabs),
                  ),
                Expanded(child: _body(tabs)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(List<_Tab> tabs) {
    if (_loading && tabs.isEmpty) return const _Skeleton();
    if (tabs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: const EmptyState(
          icon: Icons.category_outlined,
          title: 'Ангилал алга',
          message: 'Энэ нийлүүлэгч барааны ангилал харуулдаггүй байна.',
        ),
      );
    }
    return TabBarView(
      children: [
        for (final tab in tabs) RefreshIndicator(onRefresh: _load, child: tab.view),
      ],
    );
  }
}

class _Tab {
  final String label;
  final Widget view;
  const _Tab(this.label, this.view);
}

/// Pill-style switch between the tabs.
class _Segments extends StatelessWidget {
  final List<_Tab> tabs;
  const _Segments(this.tabs);

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    final label = context.theme.textTheme.labelLarge;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: grey100, borderRadius: BorderRadius.circular(14)),
      child: TabBar(
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: primaryColor,
        unselectedLabelColor: grey600,
        labelStyle: label?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: label?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        splashBorderRadius: BorderRadius.circular(10),
        // Three labels only just fit a phone's width, so no counts here:
        // the cards and rows carry their own.
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [
          for (final tab in tabs)
            Tab(height: 36, child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------

/// This category and every one under it.
List<int> _subtreeIds(Category cat) =>
    [cat.id, for (final child in cat.children ?? <Category>[]) ..._subtreeIds(child)];

bool _hasChildren(Category cat) => cat.children?.isNotEmpty ?? false;

/// The products of [cat] alone, or with everything under it as one
/// `category=[…]` list.
void _openCategory(Category cat, {bool withSubtree = false}) {
  final ids = withSubtree ? _subtreeIds(cat) : [cat.id];
  goto(FilteredProducts(title: cat.name, query: {'category': '[${ids.join(',')}]'}));
}

/// Soft colours the category tiles cycle through, so the list scans easily.
const _palette = <MaterialColor>[
  Colors.teal,
  Colors.blue,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.green,
  Colors.indigo,
  Colors.brown,
];

class _CategoriesView extends StatelessWidget {
  final List<Category> categories;
  final String query;
  const _CategoriesView(this.categories, this.query);

  @override
  Widget build(BuildContext context) {
    if (query.isNotEmpty) return _CategorySearch(categories, query);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CategoryCard(categories[i]),
    );
  }
}

/// A top-level category: a card that opens its products, or unfolds its
/// subcategories when it has any.
class _CategoryCard extends StatefulWidget {
  final Category cat;
  const _CategoryCard(this.cat);

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final tint = _palette[cat.id % _palette.length];
    final children = cat.children ?? <Category>[];
    final hasChildren = children.isNotEmpty;
    return _Card(
      child: Column(
        children: [
          InkWell(
            onTap: hasChildren
                ? () => setState(() => _expanded = !_expanded)
                : () => _openCategory(cat),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _LetterTile(cat.name, tint),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasChildren ? '${children.length} дэд ангилал' : 'Бараа харах',
                          style: TextStyle(fontSize: 12, color: grey500),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right_rounded, color: _expanded ? tint : grey400),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      Divider(height: 1, color: grey100),
                      _AllRow(cat, depth: 0),
                      for (final child in children) _CategoryNode(child, depth: 0),
                      const SizedBox(height: 6),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A subcategory row inside a card, indented by [depth] with a guide line;
/// unfolds in place when it has subcategories of its own.
class _CategoryNode extends StatefulWidget {
  final Category cat;
  final int depth;
  const _CategoryNode(this.cat, {required this.depth});

  @override
  State<_CategoryNode> createState() => _CategoryNodeState();
}

class _CategoryNodeState extends State<_CategoryNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final hasChildren = _hasChildren(cat);
    final primaryColor = context.theme.primaryColor;
    return Column(
      children: [
        _IndentedRow(
          depth: widget.depth,
          onTap:
              hasChildren ? () => setState(() => _expanded = !_expanded) : () => _openCategory(cat),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _expanded ? FontWeight.w700 : FontWeight.w500,
                    color: _expanded ? primaryColor : Colors.grey.shade800,
                  ),
                ),
              ),
              if (hasChildren) ...[
                _CountPill('${cat.children!.length}'),
                const SizedBox(width: 4),
              ],
              AnimatedRotation(
                turns: hasChildren && _expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.chevron_right_rounded, size: 20, color: grey400),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          _AllRow(cat, depth: widget.depth + 1),
          for (final child in cat.children!) _CategoryNode(child, depth: widget.depth + 1),
        ],
      ],
    );
  }
}

/// «Бүгдийг харах»: everything in [cat] and its subcategories.
class _AllRow extends StatelessWidget {
  final Category cat;
  final int depth;
  const _AllRow(this.cat, {required this.depth});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return _IndentedRow(
      depth: depth,
      onTap: () => _openCategory(cat, withSubtree: true),
      child: Row(
        children: [
          Icon(Icons.grid_view_rounded, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Бүгдийг харах',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryColor),
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 18, color: primaryColor),
        ],
      ),
    );
  }
}

class _IndentedRow extends StatelessWidget {
  final int depth;
  final VoidCallback onTap;
  final Widget child;
  const _IndentedRow({required this.depth, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 30.0 + depth * 16, right: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: grey200, width: 2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Categories at any depth whose name matches, each with its path.
class _CategorySearch extends StatelessWidget {
  final List<Category> categories;
  final String query;
  const _CategorySearch(this.categories, this.query);

  @override
  Widget build(BuildContext context) {
    final matches = <(Category, List<String>)>[];
    void walk(List<Category> cats, List<String> path) {
      for (final cat in cats) {
        if (cat.name.toLowerCase().contains(query)) matches.add((cat, path));
        walk(cat.children ?? <Category>[], [...path, cat.name]);
      }
    }

    walk(categories, []);
    if (matches.isEmpty) {
      return const EmptyState(icon: Icons.search_off_rounded, title: 'Ангилал олдсонгүй');
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _Card(
          child: Column(
            children: [
              for (final (i, (cat, path)) in matches.indexed) ...[
                if (i > 0) Divider(height: 1, indent: 16, color: grey100),
                InkWell(
                  onTap: () => _openCategory(cat, withSubtree: _hasChildren(cat)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              if (path.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  path.join(' › '),
                                  style: TextStyle(fontSize: 12, color: grey500),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_hasChildren(cat)) _CountPill('${cat.children!.length}'),
                        Icon(Icons.chevron_right_rounded, color: grey400),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Manufacturers and vendors
// ---------------------------------------------------------------------------

/// Manufacturers or vendors ([param] `mnfr` / `vndr`), A–Я by first letter.
class _BrandsView extends StatelessWidget {
  final List<Manufacturer> items;
  final String param;
  final String query;
  const _BrandsView(this.items, this.param, this.query);

  @override
  Widget build(BuildContext context) {
    final shown = items.where((m) => m.name.toLowerCase().contains(query)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (shown.isEmpty) {
      return const EmptyState(icon: Icons.search_off_rounded, title: 'Илэрц олдсонгүй');
    }
    final groups = <String, List<Manufacturer>>{};
    for (final m in shown) {
      final name = m.name.trim();
      final letter = name.isEmpty ? '#' : name[0].toUpperCase();
      groups.putIfAbsent(letter, () => []).add(m);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        for (final MapEntry(key: letter, value: group) in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 0, 8),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.theme.primaryColor,
              ),
            ),
          ),
          _Card(
            child: Column(
              children: [
                for (final (i, m) in group.indexed) ...[
                  if (i > 0) Divider(height: 1, indent: 66, color: grey100),
                  _BrandRow(m, param),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  final Manufacturer item;
  final String param;
  const _BrandRow(this.item, this.param);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // `mnfr=[3]` / `vndr=[2]`: the API takes a list of ids.
      onTap: () => goto(FilteredProducts(title: item.name, query: {param: '[${item.id}]'})),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _LetterTile(item.name, Colors.blueGrey, size: 38, circle: true),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            if (item.cnt != null) ...[
              _CountPill('${item.cnt} бараа'),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, size: 20, color: grey400),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      elevation: 2,
      child: child,
    );
  }
}

/// The name's first letter on a tinted tile.
class _LetterTile extends StatelessWidget {
  final String name;
  final MaterialColor tint;
  final double size;
  final bool circle;
  const _LetterTile(this.name, this.tint, {this.size = 44, this.circle = false});

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: tint.shade700,
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String text;
  const _CountPill(this.text);

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryColor),
      ),
    );
  }
}

/// Placeholder cards while the lists load.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: grey100, borderRadius: BorderRadius.circular(6)),
        );
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => _Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: grey100, borderRadius: BorderRadius.circular(13)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [bar(140, 12), const SizedBox(height: 8), bar(80, 10)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
