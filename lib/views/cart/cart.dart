import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/views/cart/cart_info.dart';
import 'package:pharmo_app/views/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/cart/seller_order_sheet.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/shimmer_box.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    init();
  }

  Future<void> init() async {
    final basket = context.read<BasketProvider>();
    WidgetsBinding.instance.addPostFrameCallback((cb) async {
      setLoading(true);
      await basket.getBasket();
      setLoading(false);
    });
  }

  shimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ShimmerBox(
          height: 100,
          controller: controller,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BasketProvider>(
      builder: (context, provider, _) {
        final cartDatas = provider.shoppingCarts;
        final basket = provider.basket;
        final basketIsEmpty = (basket == null
            ? true
            : basket.totalCount == 0 || basket.items!.isEmpty);
        return DataScreen(
          loading: loading,
          empty: false,
          customLoading: shimmer(),
          onRefresh: () => init(),
          child: Builder(builder: (context) {
            if (basketIsEmpty) {
              return Center(child: EmptyBasket());
            }
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const CartInfo(),
                  ...cartDatas.map((e) => CartItem(detail: e)),
                  CustomButton(
                    text: 'Захиалга үүсгэх',
                    ontap: () async => await placeOrder(context),
                  ),
                  SizedBox(height: kToolbarHeight + 50),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  placeOrder(BuildContext c) async {
    final Security? security = LocalBase.security;
    final basket = context.read<BasketProvider>();
    if (security == null) {
      return;
    }
    await basket.getBasket();
    if (double.parse(basket.basket!.totalPrice.toString()) < 10) {
      message('Үнийн дүн 10₮-с бага байж болохгүй!');
      return;
    }
    if (basket.qtys.isNotEmpty) {
      message('Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!');
      return;
    }
    Get.bottomSheet(
        security.role == 'PA' ? PharmOrderSheet() : SellerOrderSheet());
  }
}
