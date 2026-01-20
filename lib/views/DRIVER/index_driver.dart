import 'package:pharmo_app/application/color/colors.dart';
import 'package:pharmo_app/views/DRIVER/map/map_view.dart';
import 'package:pharmo_app/views/DRIVER/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/DRIVER/profile/delivery_profile.dart';
import 'package:pharmo_app/views/profile.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

class IndexDriver extends StatefulWidget {
  const IndexDriver({super.key});

  @override
  State<IndexDriver> createState() => _IndexDriverState();
}

class _IndexDriverState extends State<IndexDriver> {
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
