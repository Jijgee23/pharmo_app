import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/promotion/buying_promo.dart';
import 'package:pharmo_app/views/promotion/marked_promo.dart';

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
  String iconurl = 'gitf_filled.png';

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionProvider>(
      builder: (_, provider, child) {
        final promos = provider.promotions;
        return Material(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Олон өнгийн зогсолт ашиглан илүү smooth болгоно
                colors: [
                  primary.withOpacity(0.6), // Маш бүдэг үндсэн өнгө
                  primary.withOpacity(0.3), // Бараг харагдахгүй туяа
                  primary.withOpacity(0.1), // Цэвэр цагаан руу уусна
                ],
                stops: [0, 0.5, 1], // Өнгө хаанаас хаашаа уусахыг заана
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(title: Text('Урамшуулал'), backgroundColor: transperant),
                  _filterRow(provider),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (provider.loading) {
                          return CircularProgressIndicator.adaptive();
                        }
                        if (promos.isEmpty) {
                          return NoResult(
                            onRefresh: () async => await promotionProvider.getPromotion(),
                          );
                        }
                        return SectionCard(
                          title: 'Урамшуулал',
                          child: SingleChildScrollView(
                            child: Column(
                              children: promos
                                  .map(
                                    (p) => promo(
                                      promo: promos[promos.indexOf(p)],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _promoTypeOpen = false;
  final MenuController _promoMenuController = MenuController();

  Widget _filterRow(PromotionProvider provider) {
    final color = primary;
    final dateActive =
        start != DateTime(start.year, start.month, start.day) || end.difference(start).inDays > 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          // 1. Promo type dropdown — MenuAnchor
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
                    selected ? color.withOpacity(0.07) : Colors.transparent,
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
                      child: selected ? Icon(Icons.check_rounded, size: 15, color: color) : null,
                    ),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? color : Colors.black87,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _promoTypeOpen ? Colors.grey.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(
                      selectedPromoType,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _promoTypeOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Gift toggle
          GestureDetector(
            onTap: () {
              setState(() => hasGift = !hasGift);
              provider.filterPromotion('has_gift', hasGift.toString());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasGift ? color.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: hasGift ? color.withOpacity(0.5) : Colors.grey.shade300,
                  width: hasGift ? 1.4 : 1.2,
                ),
                boxShadow: hasGift
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  CustomIcon(name: hasGift ? 'gitf_filled.png' : 'gift_empty.png'),
                  Text(
                    'Бэлэгтэй',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasGift ? FontWeight.w600 : FontWeight.w400,
                      color: hasGift ? color : Colors.grey.shade700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Date range picker
          GestureDetector(
            onTap: () => _datePicker(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: dateActive ? color.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: dateActive ? color.withOpacity(0.5) : Colors.grey.shade300,
                  width: dateActive ? 1.4 : 1.2,
                ),
                boxShadow: dateActive
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                    color: dateActive ? color : Colors.grey.shade500,
                  ),
                  Text(
                    '${start.toString().substring(0, 10)}  ~  ${end.toString().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: dateActive ? FontWeight.w600 : FontWeight.w400,
                      color: dateActive ? color : Colors.grey.shade700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Reload
          GestureDetector(
            onTap: provider.getPromotion,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade200, width: 1.2),
              ),
              child: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget promo({required Promotion promo}) {
    return InkWell(
      onTap: () => promotionProvider.getDetail(promo.id!).then((e) {
        if (promo.promoType == '2') {
          goto(BuyinPromo(promo: promotionProvider.promoDetail));
        } else {
          goto(MarkedPromoWidget(promo: promotionProvider.promoDetail));
        }
      }),
      splashColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 3,
              )
            ],
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promo.name!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            (promo.description != null)
                ? Text(
                    promo.description!,
                    style: const TextStyle(fontSize: 12),
                  )
                : Container()
          ],
        ),
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
