import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class BuyinPromo extends StatelessWidget {
  final MarkedPromo promo;
  const BuyinPromo({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade600);
    return Consumer<PromotionProvider>(builder: (_, promotion, child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ChevronBack(),
              Text(promo.name!,
                  style: const TextStyle(fontSize: 16, color: AppColors.main)),
              (promo.isMarked == true)
                  ? InkWell(
                      onTap: () => promotion
                          .hidePromo(promo.id!, context)
                          .then((e) => Navigator.pop(context)),
                      child: const Text('Дахиж харахгүй',
                          style: TextStyle(fontSize: 14)),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  promo.desc != null
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(promo.desc!),
                        )
                      : const SizedBox(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        const Text('Захиалгын дүн '),
                        Text(
                          '${promo.total}₮ ',
                          style:
                              TextStyle(fontSize: 20, color: Colors.red.shade600),
                        ),
                        const Text('-с дээш бол '),
                        Text(
                          '${promo.procent}% ',
                          style:
                              TextStyle(fontSize: 20, color: Colors.red.shade600),
                        ),
                        const Text('хямдрал '),
                        promo.gift != null
                            ? const Text('эдэлж')
                            : const Text('эдлээрэй!')
                      ],
                    ),
                  ),
                  promo.gift != null
                      ? Icon(Icons.add, color: Colors.grey.shade900, size: 30)
                      : const SizedBox(),
                  promo.gift != null
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              promo.gift != null
                                  ? GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
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
                          ))
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  promo.endDate != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
        ),
      );
    });
  }

  product(e, String noImage) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondary),
          ),
          padding: const EdgeInsets.only(bottom: 5),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        scale: 1,
                        image: NetworkImage(noImage),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  e['name'] != null ? e['name'].toString() : '-',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
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
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('x ${e['qty']}'),
          ),
        )
      ],
    );
  }
}
