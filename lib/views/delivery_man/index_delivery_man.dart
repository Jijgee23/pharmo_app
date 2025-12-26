import 'package:pharmo_app/views/delivery_man/home/deliveries.dart';
import 'package:pharmo_app/views/delivery_man/home/map_view.dart';
import 'package:pharmo_app/views/delivery_man/orders/delivery_orders.dart';
import 'package:pharmo_app/views/delivery_man/profile/delivery_profile.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';

class IndexDeliveryMan extends StatefulWidget {
  const IndexDeliveryMan({super.key});

  @override
  State<IndexDeliveryMan> createState() => _IndexDeliveryManState();
}

class _IndexDeliveryManState extends State<IndexDeliveryMan> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        return Scaffold(
          appBar: home.currentIndex == 0
              ? null
              : DMAppBar(title: getTitle(home.currentIndex)),
          body: _pages[home.currentIndex],
          bottomNavigationBar: BottomBar(icons: icons),
        );
      },
    );
  }

  String getTitle(int n) {
    switch (n) {
      case 1:
        return 'Өнөөдрийн түгээлтүүд';
      case 2:
        return 'Бэлэн захиалгууд';
      case 3:
        return 'Миний профайл';
      default:
        return '';
    }
  }

  final List _pages = [
    const MapView(),
    const Deliveries(),
    const DeliveryOrders(),
    const DeliveryProfile()
  ];

  List<String> icons = ['marker', 'truck-check', 'box-check', 'user'];
}
