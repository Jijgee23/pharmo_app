import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/promotion/buying_promo.dart';
import 'package:pharmo_app/views/promotion/marked_promo.dart';
import 'package:pharmo_app/views/promotion/promo_card.dart';

class PromotionWidget extends StatefulWidget {
  const PromotionWidget({super.key});

  @override
  State<PromotionWidget> createState() => _PromotionWidgetState();
}

class _PromotionWidgetState extends State<PromotionWidget> {
  late PromotionProvider promotionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
      await promotionProvider.getPromotion();
    });
  }

  List<String> promoTypes = [
    'Багцын урамшуулал',
    'Худалдан авалтын урамшуулал',
    'Барааны урашмуулал'
  ];
  String selectedPromoType = 'Багцын урамшуулал';
  bool hasGift = false;
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionProvider>(
      builder: (_, provider, child) {
        final promos = provider.promotions;
        return Scaffold(
          appBar: const SideAppBar(text: 'Урамшуулал'),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _filterRow(provider),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (provider.loading) {
                        return const Center(child: PharmoIndicator());
                      }
                      if (promos.isEmpty) {
                        return EmptyState(
                          icon: Icons.local_offer_outlined,
                          title: 'Урамшуулал алга',
                          message: 'Одоогоор идэвхтэй урамшуулал байхгүй байна.',
                          actionLabel: 'Дахин ачаалах',
                          onAction: () => promotionProvider.getPromotion(),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(15),
                        itemCount: promos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) => PromoCard(
                          promo: promos[idx],
                          onTap: () => _openPromo(promos[idx]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPromo(Promotion promo) {
    promotionProvider.getDetail(promo.id!).then((e) {
      if (promo.promoType == '2') {
        goto(BuyinPromo(promo: promotionProvider.promoDetail));
      } else {
        goto(MarkedPromoWidget(promo: promotionProvider.promoDetail));
      }
    });
  }

  bool _promoTypeOpen = false;
  final MenuController _promoMenuController = MenuController();

  Widget _filterRow(PromotionProvider provider) {
    final dateActive =
        start != DateTime(start.year, start.month, start.day) || end.difference(start).inDays > 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          // 1. Promo type dropdown — MenuAnchor, styled like PharmoFilterChip
          // (same pill/border/shadow language, primary fill while open).
          MenuAnchor(
            controller: _promoMenuController,
            onOpen: () => setState(() => _promoTypeOpen = true),
            onClose: () => setState(() => _promoTypeOpen = false),
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              elevation: WidgetStatePropertyAll(8),
              shadowColor: WidgetStatePropertyAll(Colors.black12),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
            ),
            menuChildren: promoTypes.map((type) {
              final selected = selectedPromoType == type;
              return MenuItemButton(
                onPressed: () {
                  setState(() => selectedPromoType = type);
                  provider.filterPromotion('promo_type', (promoTypes.indexOf(type) + 1).toString());
                  _promoMenuController.close();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    selected ? primary.withOpacity(0.07) : Colors.transparent,
                  ),
                  padding: WidgetStatePropertyAll(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: 16,
                      child: selected ? Icon(Icons.check_rounded, size: 15, color: primary) : null,
                    ),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? primary : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            child: GestureDetector(
              onTap: () =>
                  _promoTypeOpen ? _promoMenuController.close() : _promoMenuController.open(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _promoTypeOpen ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _promoTypeOpen ? primary : Colors.grey.shade300,
                    width: 1.2,
                  ),
                  boxShadow: _promoTypeOpen
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Text(
                      selectedPromoType,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _promoTypeOpen ? FontWeight.w600 : FontWeight.w400,
                        color: _promoTypeOpen ? Colors.white : Colors.grey.shade700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _promoTypeOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: _promoTypeOpen ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Gift toggle
          PharmoFilterChip(
            caption: 'Бэлэгтэй',
            icon: hasGift ? Icons.card_giftcard_rounded : Icons.card_giftcard_outlined,
            selected: hasGift,
            onPressed: () {
              setState(() => hasGift = !hasGift);
              provider.filterPromotion('has_gift', hasGift.toString());
            },
          ),

          // 3. Date range picker — same pill styling as PharmoFilterChip
          GestureDetector(
            onTap: () => _datePicker(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: dateActive ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: dateActive ? primary : Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: dateActive
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                    color: dateActive ? Colors.white : Colors.grey.shade600,
                  ),
                  Text(
                    '${start.toString().substring(0, 10)}  ~  ${end.toString().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: dateActive ? FontWeight.w600 : FontWeight.w400,
                      color: dateActive ? Colors.white : Colors.grey.shade700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Reload
          ModernIcon(
            iconData: Icons.refresh_rounded,
            onPressed: provider.getPromotion,
          ),
        ],
      ),
    );
  }

  _datePicker(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
        initialEntryMode: DatePickerEntryMode.input,
        helpText: 'Огноо сонгох',
        cancelText: 'Буцах',
        confirmText: "Сонгох",
        saveText: 'Хадгалах',
        errorFormatText: 'Огноо буруу байна',
        fieldEndHintText: 'Дуусах огноо',
        fieldEndLabelText: 'Дуусах огноо',
        fieldStartLabelText: 'Эхлэх огноо',
        fieldStartHintText: 'Эхлэх огноо',
        locale: null,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.main),
            ),
            child: child!,
          );
        },
        initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()));
    if (result != null && result.start != start) {
      setState(() {
        start = result.start;
        end = result.end;
      });
    }
  }
}
