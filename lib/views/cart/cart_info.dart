import 'package:pharmo_app/application/application.dart';

class CartInfo extends StatefulWidget {
  const CartInfo({super.key});

  @override
  State<CartInfo> createState() => _CartInfoState();
}

class _CartInfoState extends State<CartInfo> {
  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // theme
    void clearBasket() async {
      await basketProvider.clearBasket();
      await basketProvider.getBasket();
    }

    return Card(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade500, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                info(
                  title: 'Нийт дүн',
                  text: toPrice(
                    basketProvider.basket != null
                        ? basketProvider.basket!.totalPrice
                        : 0,
                  ),
                )
              ],
            ),
            info(
                title: 'Нийт тоо ширхэг',
                text:
                    '${basketProvider.basket != null ? basketProvider.basket!.totalCount : 0}'),
            InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () => clearBasket(),
              child: const Icon(Icons.delete, color: Colors.red, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget info({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: black.withAlpha(25 * 7),
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
