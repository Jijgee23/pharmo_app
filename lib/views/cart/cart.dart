import 'package:pharmo_app/application/application.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((cb) async {
      init();
    });
  }

  Future<void> init() async {
    LoadingService.run(() async {
      final basket = context.read<BasketProvider>();
      await basket.getBasket();
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
        return Scaffold(
          appBar: AppBar(
            title: Text('Миний сагс'),
          ),
          body: RefreshIndicator(
            onRefresh: () => init(),
            child: Container(
              padding: EdgeInsets.all(5),
              height: double.maxFinite,
              child: Builder(
                builder: (context) {
                  if (basketIsEmpty) {
                    return Center(child: EmptyBasket());
                  }
                  return SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            CartInfo(),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  final e = cartDatas[index];
                                  return CartItem(detail: e);
                                },
                                itemCount: cartDatas.length,
                                shrinkWrap: true,
                              ),
                            ),
                          ],
                        ),
                        if (!basketIsEmpty)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            width: 250,
                            height: 50,
                            child: SafeArea(
                              child: CustomButton(
                                text: 'Захиалга үүсгэх',
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Захиалга үүсгэх',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.shop),
                                  ],
                                ),
                                ontap: () async => await placeOrder(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  placeOrder(BuildContext c) async {
    final Security? security = LocalBase.security;
    if (security == null) {
      return;
    }
    final basket = context.read<BasketProvider>();
    await basket.getBasket();
    if (double.parse(basket.basket!.totalPrice.toString()) < 10) {
      messageWarning('Үнийн дүн 10₮-с бага байж болохгүй!');
      return;
    }
    Get.bottomSheet(
      security.role == 'PA' ? PharmOrderSheet() : SellerOrderSheet(),
    );
  }
}
