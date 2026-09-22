import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/van_sales/van_sales_index.dart';
import 'package:pharmo_app/views/index.dart';
import 'package:pharmo_app/views/order_history/order_card/order_card_skeleton.dart';

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
    final cart = context.read<CartProvider>();
    cart.setLoading(true);
    try {
      await cart.getBasket();
      final user = Authenticator.security;
      if (user == null) return;
      if (user.isPharmacist) {
        if (!mounted) return;
        await context.read<HomeProvider>().getBranches();
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      cart.setLoading(false);
    }
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
        bool basketIsEmpty = provider.basketIsEmpty;
        final user = Authenticator.security;
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: const SideAppBar(text: 'Миний сагс'),
          body: Stack(
            children: [
              RefreshIndicator.adaptive(
                onRefresh: init,
                child: Builder(
                  builder: (context) {
                    if (provider.loading) {
                      return SkeletonList();
                    }
                    if (basketIsEmpty) {
                      return _buildEmptyState();
                    }
                    return Column(
                      children: [
                        // Сагсны нийт мэдээллийг дээр нь тогтмол байршуулна
                        const Padding(
                          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: CartInfo(),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                            physics: AlwaysScrollableScrollPhysics(),
                            children: _buildCartSections(cartDatas),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (!basketIsEmpty)
                StartOrder(
                  isPharmacist: user!.isPharmacist,
                  emptyBasket: basketIsEmpty,
                  handler: () => placeOrder(context),
                  onClearBasket: () async {
                    final confirmed = await confirmDialog(
                      title: 'Захиалгын сагсыг хоослох уу?',
                    );
                    if (confirmed) {
                      await provider.clearBasket();
                      await provider.getBasket();
                    }
                  },
                  supplierName: home.picked.name,
                )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCartSections(List<dynamic> cartDatas) {
    final items = cartDatas.cast<CartItemModel>();
    final cashOnlyItems = items.where((e) => e.cashOnly).toList();
    final otherItems = items.where((e) => !e.cashOnly).toList();
    final hasBothGroups = cashOnlyItems.isNotEmpty && otherItems.isNotEmpty;
    return [
      if (cashOnlyItems.isNotEmpty) ...[
        _sectionHeader('Зөвхөн бэлнээр төлөгдөх', Colors.redAccent),
        const SizedBox(height: 8),
        ...cashOnlyItems.map((e) => CartItem(item: e)),
      ],
      if (otherItems.isNotEmpty) ...[
        if (hasBothGroups) ...[
          const SizedBox(height: 4),
          _sectionHeader('Бусад бараа', Colors.grey),
          const SizedBox(height: 8),
        ],
        ...otherItems.map((e) => CartItem(item: e)),
      ],
    ];
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // RefreshIndicator ажиллахын тулд ListView ашиглав
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const EmptyBasket(), // Таны өмнөх Empty State widget
        SizedBox(height: 20),
        Row(
          children: [
            Spacer(),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final home = context.read<HomeProvider>();
                  final user = Authenticator.security;
                  home.changeIndex(user!.isPharmacist
                      ? 0
                      : user.isVanSales
                          ? 1
                          : 2);
                  home.setHidingOnScroll(false);
                  gotoRemoveUntil(
                      user.isVanSales ? VanSalesIndex() : IndexPharma());
                },
                style: ElevatedButton.styleFrom(
                  maximumSize: Size(150, 48),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Бараа үзэх', style: TextStyle(fontSize: 14)),
                    Icon(Icons.chevron_right_rounded, color: white),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        )
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

    await Get.bottomSheet(
      const OrderSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class StartOrder extends StatelessWidget {
  final bool isPharmacist, emptyBasket;
  final Function() handler, onClearBasket;
  final String supplierName;
  const StartOrder({
    super.key,
    required this.isPharmacist,
    required this.emptyBasket,
    required this.handler,
    required this.supplierName,
    required this.onClearBasket,
  });

  @override
  Widget build(BuildContext context) {
    if (emptyBasket) return SizedBox.shrink();
    return Positioned(
      bottom: 20,
      width: MediaQuery.of(context).size.width,
      left: 0,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                color: white,
                style: IconButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: onClearBasket,
                icon: Icon(Icons.delete_rounded),
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kToolbarHeight),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: handler,
                child: Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration:
                          BoxDecoration(color: white, shape: BoxShape.circle),
                      child: Icon(
                        Icons.shopping_basket,
                        color: AppColors.cleanBlack,
                      ),
                    ),
                    Text(
                      'Захиалах',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ],
        ).marginSymmetric(horizontal: 20),
      ),
    );
  }
}
