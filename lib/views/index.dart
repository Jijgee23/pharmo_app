import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/login/login.dart';
import 'package:pharmo_app/roles/seller/customer/customers.dart';
import 'package:pharmo_app/views/home/home.dart';
import 'package:pharmo_app/views/order_history/order_history.dart';
import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/views/track_map/track_map.dart';

class IndexPharma extends StatefulWidget {
  const IndexPharma({super.key});
  @override
  State<IndexPharma> createState() => _IndexPharmaState();
}

class _IndexPharmaState extends State<IndexPharma> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await inititliazeBasket(),
    );
  }

  Future inititliazeBasket() async {
    final security = Authenticator.security;
    if (security == null) return;
    final cart = context.read<CartProvider>();
    final home = context.read<HomeProvider>();
    await cart.getBasket();
    await home.getSuppliers();
    if (!mounted) return;
    if (home.supliers.isEmpty) return;
    final sId = security.supplierId ?? security.byId;
    // security.supplierId/stockId can go stale relative to the freshly
    // fetched home.supliers — e.g. switching role (Driver -> Seller) reuses
    // the same Security/stockId while home.getSuppliers() above returns a
    // different list for the new role, so a plain firstWhere() (no match)
    // threw "Bad state: No element" here. Fall back to the supplier's/the
    // list's first entry instead of crashing when nothing matches.
    final findedSup = sId != null
        ? home.supliers.where((sup) => sup.id == sId).firstOrNull ?? home.supliers[0]
        : null;
    if (findedSup != null) {
      home.setSupplier(findedSup);
      if (findedSup.stocks.isNotEmpty) {
        final findedStock =
            findedSup.stocks.where((stock) => stock.id == security.stockId).firstOrNull ??
                findedSup.stocks[0];
        home.setStock(findedStock);
      }
    } else {
      final sup = home.supliers[0];
      print(sup.name);
      home.pickSupplier(sup, sup.stocks[0], context);
      home.setSupplier(sup);
      home.setStock(sup.stocks[0]);
    }
    if (security.role == 'PA') {
      final promotion = context.read<PromotionProvider>();
      await promotion.getMarkedPromotion();
      await home.getBranches();
      if (promotion.markedPromotions.isNotEmpty) {
        home.showMarkedPromos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final security = Authenticator.security;
        if (security == null) {
          return LoginPage();
        }
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              Center(
                child: [
                  if (!security.isPharmacist) const CustomerList(),
                  const Home(),
                  OrderHistory(),
                  const Profile(),
                ][home.currentIndex],
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: 100,
                right: home.hidingOnScroll ? -60 : 10,
                child: SafeArea(
                  child: Column(
                    spacing: 10,
                    children: [
                      if (security.role == 'S' && home.currentIndex == 0)
                        FloatingActionButton(
                          heroTag: 'sellerTRACKING',
                          shape: CircleBorder(),
                          onPressed: () => goto(TrackMap()),
                          backgroundColor: primary,
                          child: Icon(
                            Icons.location_on_rounded,
                            color: white,
                          ),
                        ),
                      CartIcon(),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: home.hidingOnScroll ? -120 : 0,
                left: 0,
                right: 0,
                child: BottomBar(
                  icons: [
                    if (!security.isPharmacist) AssetIcon.users,
                    AssetIcon.category,
                    AssetIcon.orderHistory,
                    AssetIcon.user,
                  ],
                  labels: [
                    if (!security.isPharmacist) 'Харилцагч',
                    'Бараа',
                    'Түүх',
                    'Профайл',
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
