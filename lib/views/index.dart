import 'package:pharmo_app/services/local_base.dart';
import 'package:pharmo_app/views/cart/cart.dart';
import 'package:pharmo_app/views/home.dart';
import 'package:pharmo_app/views/seller/seller_tracking.dart';
import 'package:pharmo_app/views/product/product_searcher.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/views/seller/add_customer.dart';
import 'package:pharmo_app/views/seller/customer_searcher.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/utilities/a_utils.dart';

class IndexPharma extends StatefulWidget {
  const IndexPharma({super.key});

  @override
  State<IndexPharma> createState() => _IndexPharmaState();
}

class _IndexPharmaState extends State<IndexPharma> {
  @override
  void initState() {
    super.initState();
    inititliazeBasket();
  }

  inititliazeBasket() async {
    final basket = context.read<BasketProvider>();
    await basket.getBasket();
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
          extendBody: true,
          appBar: CustomAppBar(title: getAppbar(role, homeProvider)),
          body: getPages(role)[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(icons: getIcons(role)),
          floatingActionButton: security.role == 'S'
              ? FloatingActionButton(
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
            children: [
              Expanded(flex: 8, child: CustomerSearcher()),
              SizedBox(width: 10),
              Expanded(child: AddCustomer()),
            ],
          );
        case 1:
          return const ProductSearcher();
        case 3:
          return appBarSingleText('Миний профайл');

        default:
          return selectedCustomer(homeProvider);
      }
    }
  }

  appBarSingleText(String v) {
    return Text(
      v,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  List<String> getIcons(String role) {
    if (role == 'PA') {
      return ['category', 'cart', 'user'];
    } else {
      return ['users', 'category', 'cart', 'user'];
    }
  }

  List<Widget> getPages(String role) {
    if (role == 'PA') {
      return [
        const Home(),
        const Cart(),
        const Profile(),
      ];
    }
    return [
      const CustomerList(),
      const Home(),
      const Cart(),
      const Profile(),
    ];
  }
}
