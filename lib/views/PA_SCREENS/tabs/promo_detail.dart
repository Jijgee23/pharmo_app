
import 'package:flutter/material.dart';
import 'package:pharmo_app/models/promotion.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

class PromoDetail extends StatelessWidget {
  final Promotion promotion;
  const PromoDetail({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(promotion.name!, style: const TextStyle(fontSize: 14)),
        leading: const ChevronBack(),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children: [
                  const Text(
                    'Дэлгэрэнгүй:',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Тайлбар:',
                      ),
                      Text(
                        promotion.description ?? '-',
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Wrap(
                        spacing: 20,
                        direction: Axis.vertical,
                        children: [
                          Text('Эхлэсэн огноо:'),
                          Text('Дуусах огноо:'),
                          Text('Бэлэгтэй эсэх:'),
                          Text('Идэвхтэй эсэх:'),
                        ],
                      ),
                      Wrap(
                        spacing: 20,
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(promotion.startDate ?? 'Хоосон'),
                          Text(promotion.endDate ?? 'Хоосон'),
                          Text(promotion.hasGift! ? 'Тийм' : 'Үгүй'),
                          Text(promotion.isActive! ? 'Тийм' : 'Үгүй'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
