import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history.dart';
import 'package:pharmo_app/roles/driver/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/profile/delivery_profile.dart';
import 'package:pharmo_app/views/track_map/track_map.dart';

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
        // The map's panel and buttons sit on the bar: it stays put there.
        final onMap = _pages[home.currentIndex] is TrackMap;
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _pages[home.currentIndex],
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: home.hidingOnScroll && !onMap ? -120 : 0,
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
    ReadyOrders(),
    ShipmentHistory(asTab: true),
    DeliveryProfile(),
  ];

  List<String> icons = [
    AssetIcon.marker,
    AssetIcon.boxCheck,
    AssetIcon.orderHistory,
    AssetIcon.user,
  ];
  List<String> labels = ['Map', 'Захиалгууд', 'Түүх', 'Профайл'];
}
