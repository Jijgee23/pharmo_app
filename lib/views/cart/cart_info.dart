import 'package:pharmo_app/application/application.dart';

class CartInfo extends StatefulWidget {
  const CartInfo({super.key});

  @override
  State<CartInfo> createState() => _CartInfoState();
}

class _CartInfoState extends State<CartInfo> {
  @override
  Widget build(BuildContext context) {
    // Дата өөрчлөгдөх бүрт UI шинэчлэгдэхийн тулд listen: true (Default) ашиглана
    final cartProvider = Provider.of<CartProvider>(context);
    final basket = cartProvider.basket;

    void clearBasket() async {
      final confirmed = await confirmDialog(
        title: 'Захиалгын сагсыг хоослох уу?',
        context: context,
      );
      if (confirmed) {
        await cartProvider.clearBasket();
        await cartProvider.getBasket();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(
                0, -4), // Дээшээ сүүдэр өгөх (Bottom bar шиг харагдана)
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // 1. Нийт дүн
            _buildInfoItem(
              title: 'Нийт дүн',
              text: toPrice(basket?.totalPrice ?? 0),
              isHighlight: true,
            ),

            // Зааглагч зураас
            Container(
              height: 30,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.grey.shade200,
            ),

            // 2. Нийт тоо
            _buildInfoItem(
              title: 'Тоо ширхэг',
              text: '${basket?.totalCount ?? 0} ш',
              isHighlight: false,
            ),

            const Spacer(),

            // 3. Устгах товч (Бүдэг улаан дэвсгэртэй)
            Material(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: clearBasket,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String text,
    required bool isHighlight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: isHighlight ? primary : Colors.black87,
            fontSize: isHighlight ? 17 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
