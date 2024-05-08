import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:provider/provider.dart';

class ShoppinCartIcon extends StatelessWidget {
  final bool showIcon;
  const ShoppinCartIcon({super.key, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final shoppingCart = context.watch<BasketProvider>().count;
    final shoppingCartProvider = Provider.of<BasketProvider>(context, listen: false);

    void showModal(BuildContext context) {
      // shoppingCartProvider.fetchCartData();
      // SchedulerBinding.instance.addPostFrameCallback((_) {
      //   // add your code here.
      //   // Navigator.push(
      //   //   context,
      //   //   SlidePageRoute(page: const ShoppingCart()),
      //   // );

      //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingCart()));
      // });
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => showModal(context),
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.amberAccent,
            size: 28,
          ),
        ),
        Positioned(
            top: 0, // Adjust this value to position the text vertically
            right: 0, // Adjust this value to position the text horizontally
            child: Text(
              shoppingCart.toString() + ' ' + shoppingCartProvider.count.toString(),
          ),
        ),
      ],
    );
  }
}
