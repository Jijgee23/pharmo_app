import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history_detail.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history_filter.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_summary_card.dart';
import 'package:pharmo_app/widgets/filter/filter_widgets.dart';

/// Finished deliveries (GET delivery/history/): searchable by delivery or
/// order number, filtered by date, zone and progress, newest first.
class ShipmentHistory extends StatefulWidget {
  /// Shown as a bottom bar tab: room for the bar under the list, which is
  /// kept (loaded and scrolled) from one visit to the next.
  final bool asTab;
  const ShipmentHistory({super.key, this.asTab = false});

  @override
  State<ShipmentHistory> createState() => _ShipmentHistoryState();
}

class _ShipmentHistoryState extends State<ShipmentHistory> {
  late final DriverProvider _driver;
  final _search = TextEditingController();
  late final ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _driver = context.read<DriverProvider>();
    // Filters live on the provider, so they are still set on coming back.
    _search.text = _driver.historyFilter.search;
    _scrollController = ScrollController(
      initialScrollOffset: widget.asTab ? _driver.historyScrollOffset : 0,
    );
    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (widget.asTab) _driver.historyScrollOffset = position.pixels;
      if (position.pixels >= position.maxScrollExtent - 300) _driver.loadMoreHistory();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A tab picks up where it was left; a pushed page starts afresh.
      if (!widget.asTab || !_driver.historyLoaded) _driver.loadHistory();
      if (_driver.zones.isEmpty) _driver.getDeliveryZones();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Waits for a pause in typing rather than fetching on every keystroke.
  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _driver.applyHistoryFilter(_driver.historyFilter.copyWith(search: text));
    });
  }

  void _selectSearchBy() {
    mySheet(
      isDismissible: true,
      spacing: 10,
      title: 'Хайх төрөл сонгоно уу',
      children: [
        for (final by in DeliverySearch.values)
          SelectedFilter(
            selected: by == _driver.historyFilter.searchBy,
            caption: by.label,
            onSelect: () {
              final filter = _driver.historyFilter.copyWith(searchBy: by);
              if (filter.search.trim().isEmpty) {
                // Nothing to search by yet: only the box's hint changes.
                _driver.setHistoryFilter(filter);
              } else {
                _driver.applyHistoryFilter(filter);
              }
            },
          ),
      ],
    );
  }

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final filter = await Get.bottomSheet<DeliveryHistoryFilter>(
      _DeliveryHistoryFilterSheet(initial: _driver.historyFilter, zones: _driver.zones),
      isScrollControlled: true,
    );
    if (filter != null) await _driver.applyHistoryFilter(filter);
  }

  void _clearAll() {
    _debounce?.cancel();
    _search.clear();
    _driver.applyHistoryFilter(_driver.historyFilter.cleared().copyWith(search: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (_, driver, child) {
        final filter = driver.historyFilter;
        final primaryColor = context.theme.primaryColor;
        return Scaffold(
          appBar: ModernAppBar(
            title: 'Түгээлтийн түүх',
            subtitle: driver.historyLoading ? null : '${driver.historyTotal} түгээлт',
            showCart: false,
          ),
          body: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ModernField(
                      controller: _search,
                      hint: filter.searchBy.hint,
                      keyboardType: TextInputType.number,
                      onChanged: _onSearchChanged,
                      suffixIcon: IconButton(
                        onPressed: _selectSearchBy,
                        tooltip: 'Хайх төрөл',
                        icon: Icon(
                          filter.searchBy == DeliverySearch.deliveryNo
                              ? Icons.local_shipping_outlined
                              : Icons.receipt_long_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Badge(
                    isLabelVisible: filter.activeCount > 0,
                    label: Text('${filter.activeCount}'),
                    backgroundColor: primaryColor,
                    child: ModernIcon(
                      iconData: Icons.tune_rounded,
                      color: filter.activeCount > 0 ? primaryColor : null,
                      onPressed: _openFilters,
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
              ActiveFiltersRow(
                chips: [
                  if (filter.dates != null)
                    (dateRangeLabel(filter.dates!), () => _apply(filter.copyWith(dates: null))),
                  if (filter.zoneId != null)
                    (
                      filter.zoneName ?? 'Бүс',
                      () => _apply(filter.copyWith(zoneId: null, zoneName: null)),
                    ),
                  if (filter.progress != null)
                    (filter.progress!.label, () => _apply(filter.copyWith(progress: null))),
                  if (filter.oldestFirst)
                    ('Хуучин эхэндээ', () => _apply(filter.copyWith(oldestFirst: false))),
                ],
                onClearAll: () => _apply(filter.cleared()),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: driver.loadHistory,
                  child: _list(driver),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _apply(DeliveryHistoryFilter filter) => _driver.applyHistoryFilter(filter);

  Widget _list(DriverProvider driver) {
    if (driver.historyLoading && driver.history.isEmpty) {
      return const Center(child: PharmoIndicator());
    }
    if (driver.history.isEmpty) {
      final filter = driver.historyFilter;
      final filtered = filter.activeCount > 0 || filter.search.trim().isNotEmpty;
      return EmptyState(
        icon: filtered ? Icons.filter_alt_off_outlined : Icons.local_shipping_outlined,
        title: filtered ? 'Тохирох түгээлт олдсонгүй' : 'Түгээлтийн түүх алга',
        message: filtered
            ? 'Хайлт эсвэл шүүлтүүрээ өөрчлөөд дахин оролдоно уу.'
            : 'Дууссан түгээлтүүд энд харагдана.',
        actionLabel: filtered ? 'Шүүлтүүр цэвэрлэх' : null,
        actionIcon: Icons.filter_alt_off_outlined,
        onAction: filtered ? _clearAll : null,
        padding: widget.asTab ? const EdgeInsets.only(bottom: 100) : EdgeInsets.zero,
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 0, 16, widget.asTab ? 110 : 24),
      itemCount: driver.history.length + 1,
      itemBuilder: (context, index) {
        if (index == driver.history.length) {
          return driver.historyFetchingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : const SizedBox(height: 8);
        }
        return ShipmentBuilder(delivery: driver.history[index], idx: index);
      },
    );
  }
}

class _DeliveryHistoryFilterSheet extends StatefulWidget {
  final DeliveryHistoryFilter initial;
  final List<Zone> zones;

  const _DeliveryHistoryFilterSheet({required this.initial, required this.zones});

  @override
  State<_DeliveryHistoryFilterSheet> createState() => _DeliveryHistoryFilterSheetState();
}

class _DeliveryHistoryFilterSheetState extends State<_DeliveryHistoryFilterSheet> {
  late DeliveryHistoryFilter draft = widget.initial;

  void _set(DeliveryHistoryFilter next) => setState(() => draft = next);

  @override
  Widget build(BuildContext context) {
    return FilterSheet(
      onReset: () => _set(draft.cleared()),
      onApply: () => Navigator.pop(context, draft),
      children: [
        FilterSection(
          title: 'Эхэлсэн огноо',
          icon: Icons.calendar_month_rounded,
          children: [
            DateRangeChoices(
              value: draft.dates,
              onChanged: (range) => _set(draft.copyWith(dates: range)),
            ),
          ],
        ),
        if (widget.zones.isNotEmpty)
          FilterSection(title: 'Бүс', icon: Icons.map_outlined, children: [
            FilterChoice(
              'Бүгд',
              draft.zoneId == null,
              () => _set(draft.copyWith(zoneId: null, zoneName: null)),
            ),
            for (final zone in widget.zones)
              FilterChoice(
                zone.name,
                draft.zoneId == zone.id,
                () => _set(draft.copyWith(zoneId: zone.id, zoneName: zone.name)),
              ),
          ]),
        FilterSection(title: 'Гүйцэтгэл', icon: Icons.donut_large_rounded, children: [
          FilterChoice('Бүгд', draft.progress == null, () => _set(draft.copyWith(progress: null))),
          FilterChoice(
            DeliveryProgress.complete.label,
            draft.progress == DeliveryProgress.complete,
            () => _set(draft.copyWith(progress: DeliveryProgress.complete)),
            color: Colors.green,
          ),
          FilterChoice(
            DeliveryProgress.partial.label,
            draft.progress == DeliveryProgress.partial,
            () => _set(draft.copyWith(progress: DeliveryProgress.partial)),
            color: Colors.orange,
          ),
        ]),
        FilterSection(title: 'Эрэмбэ', icon: Icons.sort_rounded, children: [
          FilterChoice(
              'Шинэ эхэндээ', !draft.oldestFirst, () => _set(draft.copyWith(oldestFirst: false))),
          FilterChoice(
              'Хуучин эхэндээ', draft.oldestFirst, () => _set(draft.copyWith(oldestFirst: true))),
        ]),
      ],
    );
  }
}

class ShipmentBuilder extends StatelessWidget {
  final Delivery delivery;
  final int idx;
  const ShipmentBuilder({super.key, required this.delivery, required this.idx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (delivery.orders.isNotEmpty) {
            goto(ShipmentHistoryDetail(delivery: delivery));
          } else {
            message('Захиалга олдсонгүй!');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: DeliverySummaryCard(
          delivery: delivery,
          thirdInfoLabel: 'Захиалга',
          thirdInfoValue: delivery.orders.length.toString(),
        ),
      ),
    );
  }
}
