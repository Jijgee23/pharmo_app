import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/views/cart/cart.dart';
import 'package:pharmo_app/views/cart/cart_icon.dart';
import 'package:pharmo_app/views/home.dart';
import 'package:pharmo_app/views/seller/track/seller_tracking.dart';
import 'package:pharmo_app/views/public/product/product_searcher.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/views/seller/customer/customers.dart';
import 'package:pharmo_app/views/seller/customer/add_customer.dart';
import 'package:pharmo_app/views/seller/customer/customer_searcher.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

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
      builder: (context, homeProvider, _) {
        final security = LocalBase.security;
        if (security == null) {
          return Scaffold();
        }
        String role = security.role;
        return Scaffold(
          appBar: CustomAppBar(
            title: getAppbar(role, homeProvider),
            actions: [CartIcon()],
          ),
          body: getPages(role)[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(icons: getIcons(role)),
          floatingActionButton:
              (security.role == 'S' && homeProvider.currentIndex == 0)
                  ? FloatingActionButton(
                      heroTag: 'sellerTRACKING',
                      shape: CircleBorder(),
                      onPressed: () => goto(SellerTracking()),
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
        case 0:
          return const ProductSearcher();
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
        case 1:
          return const ProductSearcher();
        case 3:
          return appBarSingleText('Миний профайл');

        default:
          return appBarSingleText('Сагс');
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
    return [if (role != 'PA') 'users', 'category', 'cart', 'user'];
  }

  List<Widget> getPages(String role) {
    return [
      if (role != 'PA') const CustomerList(),
      const Home(),
      const Cart(),
      const Profile(),
    ];
  }
}
