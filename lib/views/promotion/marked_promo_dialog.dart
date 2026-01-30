import 'package:pharmo_app/views/promotion/buying_promo_dialog.dart';
import 'package:pharmo_app/application/application.dart';

class MakredPromoOnDialog extends StatelessWidget {
  final MarkedPromo promo;
  const MakredPromoOnDialog({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    var myColor = Colors.red.shade600;
    bool noGift = (promo.gift != null);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (promo.desc != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(promo.desc!),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              children: [
                text('Захиалгын дүн '),
                text(maybeNull(toPrice(promo.total)), color: myColor, size: 20),
                text('-с дээш бол '),
                text(maybeNull(promo.procent.toString()),
                    color: myColor, size: 20),
                text(' хямдрал '),
                noGift ? text('эдэлж') : text('эдлээрэй!')
              ],
            ),
            if (noGift)
              const Icon(Icons.add, color: AppColors.secondary, size: 30),
            if (noGift)
              Column(
                children: [
                  (noGift)
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return product(
                                promo.gift?[index], noImage, context);
                          },
                          itemCount: promo.gift?.length,
                        )
                      : const SizedBox(),
                  const SizedBox(height: 15),
                  const Text('бэлгэнд аваарай!')
                ],
              ),
            if (promo.endDate != null)
              Column(
                children: [
                  text('Урамшуулал дуусах хугацаа:'),
                  text(maybeNull(promo.endDate), color: myColor, size: 20)
                ],
              )
          ],
        ),
      ),
    );
  }
}

Widget text(String text, {Color? color, double? size, TextAlign? align}) {
  return Text(
    text,
    textAlign: align ?? TextAlign.start,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: color ?? black,
      fontSize: size ?? 14,
    ),
  );
}
