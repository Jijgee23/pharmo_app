import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/buying_promo_dialog.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/marked_promo_dialog.dart';
import 'package:provider/provider.dart';

class PromotionDialog extends StatelessWidget {
  const PromotionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return Dialog(
      backgroundColor: white,
      child: Consumer<PromotionProvider>(
        builder: (context, promo, child) => Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      button2(Icons.chevron_left,
                          handler: () => preivous(pageController)),
                      button2(Icons.chevron_right,
                          handler: () => next(pageController, promo, context)),
                    ],
                  ),
                  button2(Icons.highlight_remove,
                      handler: () => Navigator.pop(context))
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: PageView(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  children: promo.markedPromotions
                      .map(
                        (p) => (p.promoType == 2)
                            ? MakredPromoOnDialog(promo: p)
                            : BuyingPromoOnDialog(promo: p),
                      )
                      .toList()),
            ),
          ],
        ),
      ),
    );
  }

  button2(IconData icon, {Function()? handler}) {
    return InkWell(
      onTap: handler,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [Icon(icon, color: theme.primaryColor)],
        ),
      ),
    );
  }

  void next(PageController pageController, PromotionProvider promo,
      BuildContext context) {
    if (pageController.page == promo.markedPromotions.length - 1) {
      Navigator.pop(context);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  void preivous(PageController pageController) {
    pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }
}
