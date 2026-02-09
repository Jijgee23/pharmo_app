import 'package:pharmo_app/application/application.dart';

enum CartIconType { floating, appBar }

class CartIcon extends StatelessWidget {
  final CartIconType type;

  const CartIcon({super.key}) : type = CartIconType.floating;

  const CartIcon.forAppBar({super.key}) : type = CartIconType.appBar;

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, CartProvider>(
      builder: (context, home, cart, child) {
        Widget iconWidget = type == CartIconType.floating
            ? FloatingActionButton(
                heroTag: 'MYCART',
                shape: const CircleBorder(),
                onPressed: () => goto(const Cart()),
                backgroundColor: primary,
                child: const Icon(Icons.shopping_cart),
              )
            : IconButton(
                onPressed: () => goto(Cart()),
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
              );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            if (cart.basket?.totalCount != 0)
              Positioned(
                right: type == CartIconType.appBar ? 0 : 2,
                top: type == CartIconType.appBar ? 0 : 2,
                child: _buildBadge(cart.basket?.totalCount.toInt() ?? 0),
              ),
          ],
        );
      },
    );
  }

  // Badge-ийг тусад нь функц болгох нь кодыг цэгцтэй болгоно
  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        count > 99 ? '+99' : count.toString(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
