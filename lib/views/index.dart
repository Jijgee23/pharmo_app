import 'package:pharmo_app/views/home/home.dart';
import 'package:pharmo_app/views/order_history/order_history.dart';
import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/views/SELLER/customer/customers.dart';
import 'package:pharmo_app/application/application.dart';
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
    final security = LocalBase.security;
    if (security == null) return;
    final basket = context.read<BasketProvider>();
    final home = context.read<HomeProvider>();
    final promotion = context.read<PromotionProvider>();
    await basket.getBasket();
    if (security.role == 'PA') {
      print(home.selected.name);
      await promotion.getMarkedPromotion();
      await home.getBranches();
      await home.getSuppliers();
      if (security.supplierId != null) {
        final sup =
            home.supliers.firstWhere((e) => e.id == security.supplierId);
        home.setSupplier(sup);
        final findedSup =
            home.supliers.firstWhere((sup) => sup.id == security.supplierId);
        final findedStock = findedSup.stocks
            .firstWhere((stock) => stock.id == security.stockId);
        if (findedSup != null && findedStock != null) {
          home.setSupplier(findedSup);
          home.setStock(findedStock);
        }
      } else {
        final sup = home.supliers[0];
        print(sup.name);
        home.pickSupplier(sup, sup.stocks[0], context);
        home.setSupplier(sup);
        home.setStock(sup.stocks[0]);
      }
      if (promotion.markedPromotions.isNotEmpty) {
        home.showMarkedPromos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final security = LocalBase.security;
        if (security == null) {
          return Scaffold();
        }
        String role = security.role;
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: [
                  if (role != 'PA') const CustomerList(),
                  const Home(),
                  OrderHistory(),
                  const Profile(),
                ][home.currentIndex],
              ),
              Positioned(
                bottom: 10,
                right: 10,
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
              )
            ],
          ),
          bottomNavigationBar: BottomBar(
            icons: [
              if (role != 'PA') 'users',
              'category',
              'order-history',
              'user'
            ],
          ),
        );
      },
    );
  }
}
