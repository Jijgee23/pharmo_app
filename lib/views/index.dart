import 'package:pharmo_app/views/home/home.dart';
import 'package:pharmo_app/views/order_history/order_history.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/views/SELLER/customer/customers.dart';
import 'package:pharmo_app/views/SELLER/customer/add_customer.dart';
import 'package:pharmo_app/views/SELLER/customer/customer_searcher.dart';
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
        home.setSupplier(findedSup);
        home.setStock(findedStock);
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
          appBar: ((home.currentIndex == 0) ||
                  (role != 'PA' && home.currentIndex == 1))
              ? null
              : CustomAppBar(
                  title: getAppbar(role, home),
                  actions: [
                    if ((role == 'S' && home.currentIndex != 3) ||
                        (role == 'PA' && home.currentIndex != 2))
                      CartIcon(),
                    if ((role == 'S' && home.currentIndex == 3) ||
                        (role == 'PA' && home.currentIndex == 2))
                      IconButton(
                        onPressed: () => logout(context),
                        icon: Icon(Icons.logout_rounded),
                      ),
                  ],
                ),
          body: getPages(role)[home.currentIndex],
          bottomNavigationBar: BottomBar(icons: getIcons(role)),
          floatingActionButton: (security.role == 'S' && home.currentIndex == 0)
              ? FloatingActionButton(
                  heroTag: 'sellerTRACKING',
                  shape: CircleBorder(),
                  onPressed: () => goto(TrackMap()),
                  backgroundColor: primary,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: white,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget getAppbar(String role, HomeProvider homeProvider) {
    if (role == 'PA') {
      switch (homeProvider.currentIndex) {
        case 2:
          return appBarSingleText('Миний профайл');
        default:
          return appBarSingleText('Сагс');
      }
    } else {
      switch (homeProvider.currentIndex) {
        case 0:
          return const Row(
            spacing: 10,
            children: [
              Expanded(flex: 6, child: CustomerSearcher()),
              Expanded(child: AddCustomer()),
            ],
          );
        case 2:
          return appBarSingleText('Сагс');
        case 3:
          return appBarSingleText('Миний профайл');

        default:
          return appBarSingleText('');
      }
    }
  }

  appBarSingleText(String v) {
    return Text(
      v,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  List<String> getIcons(String role) {
    return [if (role != 'PA') 'users', 'category', 'order-history', 'user'];
  }

  List<Widget> getPages(String role) {
    return [
      if (role != 'PA') const CustomerList(),
      const Home(),
      // const Cart(),
      OrderHistory(),
      const Profile(),
    ];
  }
}
