import 'package:pharmo_app/application/application.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, BasketProvider>(
      builder: (context, home, basket, child) {
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                home.changeIndex(
                  LocalBase.security!.role == 'PA' ? 1 : 2,
                );
              },
              icon: Icon(Icons.shopping_cart, size: 24),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(15)),
                child: Text(
                  basket.basket != null
                      ? (basket.basket!.totalCount > 99)
                          ? '+99'
                          : basket.basket!.totalCount.toString()
                      : '0',
                  style: const TextStyle(
                    color: white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
