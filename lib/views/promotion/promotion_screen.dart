import 'package:pharmo_app/views/promotion/buying_promo.dart';
import 'package:pharmo_app/views/promotion/marked_promo.dart';
import 'package:pharmo_app/application/application.dart';

class PromotionWidget extends StatefulWidget {
  const PromotionWidget({super.key});

  @override
  State<PromotionWidget> createState() => _PromotionWidgetState();
}

class _PromotionWidgetState extends State<PromotionWidget> {
  late PromotionProvider promotionProvider;

  @override
  void initState() {
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    promotionProvider.getPromotion();
    super.initState();
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
        return Scaffold(
          appBar: AppBar(title: Text('Урамшуулал')),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 60, // Тогтмол өндөр нь цэсийг цэгцтэй харагдуулна
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      // 1. Төрөл сонгох Dropdown
                      _buildFilterWrapper(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: selectedPromoType,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          items: promoTypes
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedPromoType = value!);
                            provider.filterPromotion('promo_type',
                                (promoTypes.indexOf(value!) + 1).toString());
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 2. Бэлэгтэй эсэх (Toggle Button загвараар)
                      _buildFilterWrapper(
                        onTap: () {
                          setState(() {
                            hasGift = !hasGift;
                            provider.filterPromotion(
                                'has_gift', hasGift.toString());
                          });
                        },
                        color: hasGift
                            ? primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderColor: hasGift ? primary : Colors.grey.shade300,
                        child: Row(
                          children: [
                            CustomIcon(
                              name: hasGift
                                  ? 'gitf_filled.png'
                                  : 'gift_empty.png',
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Бэлэгтэй',
                              style: TextStyle(
                                fontSize: 12,
                                color: hasGift ? primary : Colors.black87,
                                fontWeight: hasGift
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 3. Огноо сонгох
                      _buildFilterWrapper(
                        onTap: () => _datePicker(context),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  start.toString().substring(0, 10),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  end.toString().substring(0, 10),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 4. Дахин ачаалах/Жагсаалт
                      IconButton(
                        onPressed: provider.getPromotion,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const CustomIcon(name: 'list.png'),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (promos.isEmpty) {
                      return NoResult();
                    }
                    return Expanded(
                      child: XBox(
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
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterWrapper(
      {required Widget child,
      VoidCallback? onTap,
      Color? color,
      Color? borderColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? Colors.grey.shade300),
        ),
        child: Center(child: child),
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
            boxShadow: [Constants.defaultShadow],
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
        initialDateRange:
            DateTimeRange(start: DateTime.now(), end: DateTime.now()));
    if (result != null && result.start != start) {
      setState(() {
        start = result.start;
        end = result.end;
      });
    }
  }
}
