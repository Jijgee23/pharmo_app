import 'package:pharmo_app/views/delivery_man/map/map_view.dart';
import 'package:pharmo_app/views/delivery_man/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/delivery_man/profile/delivery_profile.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controller/providers/a_controlller.dart';

class IndexDeliveryMan extends StatefulWidget {
  const IndexDeliveryMan({super.key});

  @override
  State<IndexDeliveryMan> createState() => _IndexDeliveryManState();
}

class _IndexDeliveryManState extends State<IndexDeliveryMan> {
  @override
  void initState() {
    super.initState();
  }

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
      default:
        return '';
    }
  }

  final List _pages = [MapView(), ReadyOrders(), DeliveryProfile()];

  List<String> icons = ['marker', 'box-check', 'user'];
}
