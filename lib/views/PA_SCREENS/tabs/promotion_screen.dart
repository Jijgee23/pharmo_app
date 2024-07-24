import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/models/promotion.dart';
import 'package:pharmo_app/utilities/utils.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionProvider>(builder: (_, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Урамшуулалууд'),
          centerTitle: true,
        ),
        body: Center(
          child: ListView.builder(
            itemCount: promotionProvider.promotions.length,
            itemBuilder: (context, index) {
              final promo = promotionProvider.promotions[index];
              return ListTile(
                title: Text(promo.name),
                subtitle: Text(promo.description ?? 'Тайлбар хоосон'),
                trailing: IconButton(
                    onPressed: () {
                      goto(PromoDetail(promotion: promo), context);
                    },
                    icon: const Icon(Icons.chevron_right)),
              );
            },
          ),
        ),
      );
    });
  }
}

class PromoDetail extends StatelessWidget {
  final Promotion promotion;
  const PromoDetail({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(promotion.name),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Тайлбар:'),
                Text('Эхлэсэн огноо:'),
                Text('Дуусах огноо:'),
                Text('Бэлэгтэй эсэх:'),
                Text('Идэвхтэй эсэх:'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(promotion.description ?? 'Тайлбар хоосон'),
                Text(promotion.startDate ?? 'Хоосон'),
                Text(promotion.endDate ?? 'Хоосон'),
                Text(promotion.hasGift! ? 'Тийм' : 'Үгүй'),
                Text(promotion.isActive! ? 'Тийм' : 'Үгүй'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
