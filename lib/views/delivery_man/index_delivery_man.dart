import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/views/delivery_man/map/map_view.dart';
import 'package:pharmo_app/views/delivery_man/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/delivery_man/profile/delivery_profile.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

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
          appBar: appBar(home),
          body: _pages[home.currentIndex],
          bottomNavigationBar: BottomBar(icons: icons),
        );
      },
    );
  }

  AppBar? appBar(HomeProvider home) {
    if (home.currentIndex == 0) return null;
    return AppBar(
      leading: null,
      centerTitle: false,
      title: Text(
        getTitle(home.currentIndex),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: black,
        ),
      ),
      actions: [
        if (home.currentIndex == 2)
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
          )
      ],
    );
  }

  String getTitle(int n) {
    switch (n) {
      case 1:
        return 'Өнөөдрийн түгээлтүүд';
      case 2:
        return 'Миний профайл';
      default:
        return '';
    }
  }

  final List _pages = [MapView(), ReadyOrders(), DeliveryProfile()];

  List<String> icons = ['marker', 'box-check', 'user'];
}
