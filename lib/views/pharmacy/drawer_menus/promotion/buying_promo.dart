import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/defaultBox.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class BuyinPromo extends StatelessWidget {
  final MarkedPromo promo;
  const BuyinPromo({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    return Consumer<PromotionProvider>(
      builder: (_, promotion, child) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   title: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       const ChevronBack(),
          //       Text(promo.name!,
          //           style: const TextStyle(fontSize: 16, color: AppColors.main)),
          //       (promo.isMarked == true)
          //           ? InkWell(
          //               onTap: () => promotion
          //                   .hidePromo(promo.id!, context)
          //                   .then((e) => Navigator.pop(context)),
          //               child: const Text('Дахиж харахгүй',
          //                   style: TextStyle(fontSize: 14)),
          //             )
          //           : const SizedBox(),
          //     ],
          //   ),
          // ),
          body: DefaultBox(
            title: promo.name!,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (promo.desc != null)
                      ? Box(
                          child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(promo.desc!),
                        ))
                      : const SizedBox(),
                  Box(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        const Text('Захиалгын дүн '),
                        Text(
                          '${promo.total}₮ ',
                          style: TextStyle(
                              fontSize: 20, color: Colors.red.shade600),
                        ),
                        const Text('-с дээш бол '),
                        Text(
                          '${promo.procent}% ',
                          style: TextStyle(
                              fontSize: 20, color: Colors.red.shade600),
                        ),
                        const Text('хямдрал '),
                        promo.gift != null
                            ? const Text('эдэлж')
                            : const Text('эдлээрэй!')
                      ],
                    ),
                  ),
                  (promo.gift != null)
                      ? const Icon(Icons.add,
                          color: AppColors.secondary, size: 30)
                      : const SizedBox(),
                  (promo.gift != null)
                      ? Box(
                          child: Column(
                            children: [
                              (promo.gift != null)
                                  ? GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                      ),
                                      shrinkWrap: true,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return product(
                                            promo.gift?[index], noImage);
                                      },
                                      itemCount: promo.gift?.length,
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 15),
                              const Text('бэлгэнд аваарай!')
                            ],
                          ),
                        )
                      : const SizedBox(),
                  promo.endDate != null
                      ? Box(
                          child: Column(
                            children: [
                              const Text('Урамшуулал дуусах хугацаа:'),
                              Text(
                                promo.endDate != null
                                    ? promo.endDate!.substring(0, 10)
                                    : '-',
                                style: textStyle,
                              )
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  product(e, String noImage) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [Constants.defaultShadow]),
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      scale: 1,
                      image: NetworkImage(noImage),
                    ),
                  ),
                ),
              ),
              Text(
                e['name'] != null ? e['name'].toString() : '-',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '${e['price'] != null ? e['price'].toString() : '-'} ₮',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 3,
          top: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'x ${e['qty']}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
