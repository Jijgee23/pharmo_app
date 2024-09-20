import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/buying_promo.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/marked_promo.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/icon/custom_icon.dart';
import 'package:provider/provider.dart';

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
    return Consumer<PromotionProvider>(builder: (_, provider, child) {
      return Scaffold(
        appBar: 
        const SideMenuAppbar(title: 'Урамшуулалууд'),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: SingleChildScrollView(
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButton(
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
              ),
            ),
            SliverList.builder(
              itemCount: promotionProvider.promotions.length,
              itemBuilder: (context, index) {
                final promo = promotionProvider.promotions[index];
                return InkWell(
                  onTap: () => promotionProvider.getDetail(promo.id!).then((e) {
                    if (promo.promoType == '2') {
                      goto(BuyinPromo(promo: promotionProvider.promoDetail),
                          context);
                    } else {
                      goto(
                          MarkedPromoWidget(
                              promo: promotionProvider.promoDetail),
                          context);
                    }
                  }),
                  splashColor: Colors.transparent,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.name!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          promo.description ?? 'Тайлбар хоосон',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }

  _selectDate(BuildContext context, PromotionProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Огноо сонгох',
      cancelText: 'Буцах',
      confirmText: "Сонгох",
      initialDate: start,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.main),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != start) {
      setState(() {
        start = picked;
      });
      provider.filterPromotion('end_date', start.toString().substring(0, 10));
    }
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
