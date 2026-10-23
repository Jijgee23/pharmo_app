import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history.dart';
import 'package:pharmo_app/views/home/home.dart';
import 'package:pharmo_app/views/order_history/order_history.dart';
import 'package:pharmo_app/views/profile/delivery_profile.dart';
import 'package:pharmo_app/views/track_map/track_map.dart';

class VanSalesIndex extends StatefulWidget {
  const VanSalesIndex({super.key});

  @override
  State<VanSalesIndex> createState() => _VanSalesIndexState();
}

class _VanSalesIndexState extends State<VanSalesIndex> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await context.read<CartProvider>().getBasket(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final showCart = home.currentIndex != 0 && _pages[home.currentIndex] is! ShipmentHistory;
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _pages[home.currentIndex],
              // The map has the basket (and the ready orders) in its own top
              // bar, and it has no business over the delivery history.
              if (showCart)
                Positioned(
                  bottom: 100,
                  right: 10,
                  child: SafeArea(child: CartIcon()),
                ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomBar(icons: icons, labels: labels),
              ),
            ],
          ),
        );
      },
    );
  }

  final List _pages = [
    TrackMap(),
    Home(),
    OrderHistory(),
    ShipmentHistory(asTab: true),
    DeliveryProfile(),
  ];

  List<String> icons = [
    AssetIcon.marker,
    AssetIcon.category,
    AssetIcon.orderHistory,
    AssetIcon.boxCheck,
    AssetIcon.user,
  ];

  // "Түүх" would read as the order history next to Захиалгууд.
  List<String> labels = ['Map', 'Бараа', 'Захиалгууд', 'Түгээлт', 'Профайл'];
}
