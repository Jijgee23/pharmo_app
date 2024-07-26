import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/PA_SCREENS/tabs/promo_detail.dart';
import 'package:pharmo_app/widgets/icon/custom_icon.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
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
  DateTime date = DateTime.now();
  String iconurl = 'gitf_filled.png';

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionProvider>(builder: (_, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Урамшуулалууд', style: TextStyle(fontSize: 14)),
          centerTitle: true,
          leading: const ChevronBack(),
          toolbarHeight: 40,
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        _selectDate(context, provider);
                        debugPrint(date.toString().substring(0, 10));
                      },
                      child: Text(
                        date.toString().substring(0, 10),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    GestureDetector(
                        onTap: provider.getPromotion,
                        child: const CustomIcon(name: 'list.png')),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: promotionProvider.promotions.length,
              itemBuilder: (context, index) {
                final promo = promotionProvider.promotions[index];
                return InkWell(
                  onTap: () => goto(PromoDetail(promotion: promo), context),
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
      initialDate: date,
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
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
      provider.filterPromotion('end_date', date.toString().substring(0, 10));
    }
  }
}
