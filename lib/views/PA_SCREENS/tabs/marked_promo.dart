import 'package:flutter/material.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

// ignore: must_be_immutable
class MarkedPromoWidget extends StatelessWidget {
  MarkedPromo promo;
  MarkedPromoWidget({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        title: Text(promo.name!, style: const TextStyle(fontSize: 14)),
        centerTitle: true,
        leading: const ChevronBack(),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Багцийн үнэ:'),
                const Text('Идэвхтэй эсэх:'),
                const Text('Бэлэгтэй эсэх:'),
                const Text('Бэлэн эсэх:'),
                const Text('Эхлэсэн огноо:'),
                const Text('Дуусах огноо:'),
                const Text('Үүсгэх огноо:'),
                const Text('Шинэчлэгдсэн огноо:'),
                const Text('Процент:'),
                const Text('Код:'),
                const Text('Бэлэгүүд:'),
                Column(
                  children: promo.gift != null
                      ? promo.gift!.map((e) => Text(e['name'])).toList()
                      : [],
                ),
                const Text('Багц:'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: promo.bundles != null
                      ? promo.bundles!.map((e) => Text(e['name'])).toList()
                      : [],
                ),
                const Text('Зорилтот хэрэглэгчид:'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: promo.target != null
                      ? promo.target!
                          .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(e.toString()),
                          ))
                          .toList()
                      : [],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const Text('Тайлбар:'),
                Container(
                  width: MediaQuery.of(context).size.width * 0.57,
                  height: 200,
                  child: Text(
                    promo.desc ?? '-',
                  ),
                )
              ],
            ),
              ],
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(promo.bundlePrice.toString()),
                // Text(promo.desc ?? '-'),
                Text(promo.isActive! ? 'Идэвхтэй' : 'Идэвхгүй'),
                Text(promo.hasGift! ? 'Бэлэгтэй' : 'Бэлэггүй'),
                Text(promo.isCash! ? 'Бэлэн' : 'Бэлэн биш'),
                Text(promo.startDate ?? '-'),
                Text(promo.endDate ?? '-'),
                Text(promo.createdAt ?? '-'),
                Text(promo.updatedAt ?? '-'),
                Text(
                    promo.procent != null ? promo.procent.toString() : '-'),
                Text(promo.code != null ? promo.code.toString() : '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
