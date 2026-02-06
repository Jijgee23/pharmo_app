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
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    LoadingService.run(() async {
      await context.read<CartProvider>().getBasket();
      final user = Authenticator.security;
      if (user == null) return;
      if (user.isPharmacist) {
        await context.read<HomeProvider>().getBranches();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, HomeProvider>(
      builder: (context, provider, home, _) {
        final cartDatas = provider.shoppingCarts;
        final basket = provider.basket;
        final bool basketIsEmpty = (basket == null ||
            basket.totalCount == 0 ||
            (basket.items?.isEmpty ?? true));
        final user = Authenticator.security;
        return Scaffold(
          backgroundColor: Colors.grey.shade50, // Зөөлөн дэвсгэр
          appBar: const SideAppBar(text: 'Миний сагс'),
          bottomNavigationBar: !basketIsEmpty
              ? IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: SafeArea(
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user!.isPharmacist)
                            BottomSheetLabelBuilder(
                                'Сонгосон нийлүүлэгч: ${home.picked.name}'),
                          Expanded(
                            child: CustomButton(
                              text: "Захиалга үүсгэх",
                              ontap: () => placeOrder(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator.adaptive(
            onRefresh: init,
            child: basketIsEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Сагсны нийт мэдээллийг дээр нь тогтмол байршуулна
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: CartInfo(),
                      ),

                      // Сагсан дахь бүтээгдэхүүнүүд
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Refresh хийхэд заавал хэрэгтэй
                          itemCount: cartDatas.length,
                          itemBuilder: (context, index) {
                            return CartItem(detail: cartDatas[index]);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // RefreshIndicator ажиллахын тулд ListView ашиглав
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const EmptyBasket(), // Таны өмнөх Empty State widget
      ],
    );
  }

  Future<void> placeOrder(BuildContext context) async {
    final Security? security = Authenticator.security;
    if (security == null) return;

    final provider = context.read<CartProvider>();
    await provider.getBasket();

    // Үнийн дүнгийн шалгалт
    double totalPrice =
        double.tryParse(provider.basket?.totalPrice.toString() ?? '0') ?? 0;

    if (totalPrice < 10) {
      messageWarning('Захиалгын доод дүн 10₮ байна!');
      return;
    }

    // Role-оос хамаарч Order Sheet харуулах
    Get.bottomSheet(
      security.role == 'PA'
          ? const PharmOrderSheet()
          : const SellerOrderSheet(),
      isScrollControlled: true, // Sheet бүтэн харагдахад тусална
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
