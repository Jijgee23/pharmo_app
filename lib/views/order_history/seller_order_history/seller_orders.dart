import 'package:intl/intl.dart' show NumberFormat;
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card_skeleton.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_filter.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_filter_sheet.dart';
import 'package:pharmo_app/widgets/filter/filter_widgets.dart';

class SellerOrderHistory extends StatefulWidget {
  const SellerOrderHistory({super.key});

  @override
  State<SellerOrderHistory> createState() => _SellerOrderHistoryState();
}

class _SellerOrderHistoryState extends State<SellerOrderHistory> {
  final TextEditingController search = TextEditingController();
  Timer? _debounce;

  // This widget is rebuilt each time the bottom bar switches back to it;
  // the list, its filters and scroll position are kept on OrderProvider.
  late final OrderProvider _orders;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _orders = context.read<OrderProvider>();
    search.text = _orders.sellerFilter.search;
    _scrollController = ScrollController(initialScrollOffset: _orders.sellerScrollOffset)
      ..addListener(() => _orders.sellerScrollOffset = _scrollController.position.pixels);
    // Back on the tab with a list already loaded: show it as it was, then
    // update it in place, since statuses move and new orders come in.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _orders.sellerOrdersLoaded ? _orders.getSellerOrders() : _orders.loadSellerOrders(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Waits for a pause in typing rather than fetching on every keystroke.
  void _onSearchChanged(OrderProvider provider, String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      provider.applySellerFilter(provider.sellerFilter.copyWith(search: text));
    });
  }

  void _selectSearchBy(OrderProvider provider) {
    mySheet(
      isDismissible: true,
      spacing: 10,
      title: 'Хайх төрөл сонгоно уу',
      children: [
        for (final by in SellerOrderSearch.values)
          SelectedFilter(
            selected: by == provider.sellerFilter.searchBy,
            caption: by.label,
            onSelect: () {
              final filter = provider.sellerFilter.copyWith(searchBy: by);
              // Only refetch when the box holds something to match by.
              if (filter.search.trim().isEmpty) {
                provider.setSellerFilter(filter);
              } else {
                provider.applySellerFilter(filter);
              }
            },
          ),
      ],
    );
  }

  Future<void> _openFilters(OrderProvider provider) async {
    FocusScope.of(context).unfocus();
    final filter = await showSellerOrderFilterSheet(provider.sellerFilter);
    if (filter != null) await provider.applySellerFilter(filter);
  }

  void _clearAll(OrderProvider provider) {
    _debounce?.cancel();
    search.clear();
    provider.applySellerFilter(provider.sellerFilter.cleared().copyWith(search: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (_, provider, child) {
        final filter = provider.sellerFilter;
        return SafeArea(
          bottom: false,
          child: Column(
            spacing: 10,
            children: [
              if (context.isLandscape) SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 7.5,
                children: [
                  Text(
                    'Захиалгын түүх',
                    style: context.theme.appBarTheme.titleTextStyle,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: ModernField(
                          hint: '${filter.searchBy.label} хайх',
                          controller: search,
                          keyboardType: filter.searchBy.keyboard,
                          onChanged: (v) => _onSearchChanged(provider, v),
                          suffixIcon: IconButton(
                            onPressed: () => _selectSearchBy(provider),
                            tooltip: 'Хайх төрөл',
                            icon: Icon(
                              filter.searchBy == SellerOrderSearch.customer
                                  ? Icons.person_search_rounded
                                  : Icons.tag_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Badge(
                        isLabelVisible: filter.activeCount > 0,
                        label: Text('${filter.activeCount}'),
                        backgroundColor: context.theme.primaryColor,
                        child: ModernIcon(
                          iconData: Icons.tune_rounded,
                          color: filter.activeCount > 0 ? context.theme.primaryColor : null,
                          onPressed: () => _openFilters(provider),
                        ),
                      ),
                    ],
                  ),
                ],
              ).paddingSymmetric(horizontal: 10),
              _activeFilters(provider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadSellerOrders,
                  child: Builder(
                    builder: (context) {
                      if (provider.loading) {
                        return SkeletonList();
                      }
                      if (provider.sellerOrders.isEmpty) {
                        final filtered = filter.activeCount > 0 || filter.search.trim().isNotEmpty;
                        return EmptyState(
                          icon: filtered ? Icons.filter_alt_off_outlined : Icons.receipt_long_rounded,
                          title: filtered ? 'Тохирох захиалга олдсонгүй' : 'Захиалга олдсонгүй',
                          message: filtered
                              ? 'Хайлт эсвэл шүүлтүүрээ өөрчлөөд дахин оролдоно уу.'
                              : 'Таны авсан захиалга энд харагдана.',
                          actionLabel: filtered ? 'Шүүлтүүр цэвэрлэх' : null,
                          actionIcon: Icons.filter_alt_off_outlined,
                          onAction: filtered ? () => _clearAll(provider) : null,
                          padding: const EdgeInsets.only(bottom: 100),
                        );
                      }
                      return HomeScrollListener(
                        xchild: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 150),
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          shrinkWrap: true,
                          itemCount: provider.sellerOrders.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final order = provider.sellerOrders[index];
                            return OrderCard(order: order);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // One removable chip per filter in use, plus "clear all".
  Widget _activeFilters(OrderProvider provider) {
    final f = provider.sellerFilter;
    final chips = <(String, SellerOrderFilter)>[
      if (f.dates != null) (f.datesLabel!, f.copyWith(dates: null)),
      if (f.status != null) (f.status!.name, f.copyWith(status: null)),
      if (f.process != null) (f.process!.name, f.copyWith(process: null)),
      if (f.payType != null) (f.payType!.name, f.copyWith(payType: null)),
      if (f.qpay != null)
        (f.qpay! ? 'QPay-ээр төлсөн' : 'QPay-ээр төлөөгүй', f.copyWith(qpay: null)),
      if (f.minTotal != null || f.maxTotal != null)
        (_rangeLabel(f.minTotal, f.maxTotal, '₮'), f.copyWith(minTotal: null, maxTotal: null)),
      if (f.minCount != null || f.maxCount != null)
        (_rangeLabel(f.minCount, f.maxCount, 'ш'), f.copyWith(minCount: null, maxCount: null)),
    ];
    return ActiveFiltersRow(
      chips: [for (final (label, without) in chips) (label, () => provider.applySellerFilter(without))],
      onClearAll: () => provider.applySellerFilter(f.cleared()),
    );
  }

  static String _rangeLabel(int? low, int? high, String unit) {
    final n = NumberFormat('#,###');
    if (low != null && high != null) return '${n.format(low)} – ${n.format(high)} $unit';
    if (low != null) return '≥ ${n.format(low)} $unit';
    return '≤ ${n.format(high)} $unit';
  }
}
