import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/track_map/track_map.dart';
import 'package:pharmo_app/views/DRIVER/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/profile/delivery_profile.dart';
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
          // appBar: appBar(home),
          body: _pages[home.currentIndex],
          bottomNavigationBar: BottomBar(icons: icons, labels: labels),
        );
      },
    );
  }

  final List _pages = [TrackMap(), ReadyOrders(), DeliveryProfile()];

  List<String> icons = [AssetIcon.marker, AssetIcon.boxCheck, AssetIcon.user];
  List<String> labels = ['Map', 'Захиалгууд', 'Профайл'];
}
