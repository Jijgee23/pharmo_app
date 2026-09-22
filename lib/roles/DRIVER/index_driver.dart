import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/DRIVER/ready_orders/ready_orders.dart';
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
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _pages[home.currentIndex],
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: home.hidingOnScroll ? -120 : 0,
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

  final List _pages = [TrackMap(), ReadyOrders(), DeliveryProfile()];

  List<String> icons = [AssetIcon.marker, AssetIcon.boxCheck, AssetIcon.user];
  List<String> labels = ['Map', 'Захиалгууд', 'Профайл'];
}
