import 'package:pharmo_app/views/ORDERER/promotion/buying_promo.dart';
import 'package:pharmo_app/views/ORDERER/promotion/marked_promo.dart';
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
    // final size = MediaQuery.of(context).size;
    return Consumer<PromotionProvider>(
      builder: (_, provider, child) {
        final promos = provider.promotions;
        return DefaultBox(
          title: 'Урамшуулалууд',
          child: Column(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(15),
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 25,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton(
                          dropdownColor: Colors.white,
                          isExpanded: false,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          underline: const SizedBox(),
                          value: selectedPromoType,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: promoTypes.map((e) {
                            return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPromoType = value!;
                            });
                            provider.filterPromotion('promo_type',
                                (promoTypes.indexOf(value!) + 1).toString());
                          }),
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            hasGift = !hasGift;
                            provider.filterPromotion(
                                'has_gift', hasGift.toString());
                          });
                        },
                        child: CustomIcon(
                            name: hasGift
                                ? 'gitf_filled.png'
                                : 'gift_empty.png')),
                    GestureDetector(
                      onTap: () {
                        //  _selectDate(context, provider);
                        _datePicker(context);
                        debugPrint(start.toString().substring(0, 10));
                      },
                      child: Column(
                        children: [
                          Text(
                            start.toString().substring(0, 10),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            end.toString().substring(0, 10),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Colors.blue.shade100,
                        onTap: provider.getPromotion,
                        child: const CustomIcon(name: 'list.png')),
                  ],
                ),
              ),
              (promos.isNotEmpty)
                  ? Expanded(
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
                    )
                  : NoResult(),
            ],
          ),
        );
      },
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
