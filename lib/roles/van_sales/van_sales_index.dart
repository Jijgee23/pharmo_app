import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/home/home.dart';
import 'package:pharmo_app/views/profile/delivery_profile.dart';
import 'package:pharmo_app/views/track_map/track_map.dart';

class VanSalesIndex extends StatefulWidget {
  const VanSalesIndex({super.key});

  @override
  State<VanSalesIndex> createState() => _VanSalesIndexState();
}

class _VanSalesIndexState extends State<VanSalesIndex> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final onMapTab = home.currentIndex == 0;
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _pages[home.currentIndex],
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: 100,
                right: 10,
                child: SafeArea(
                  child: Column(
                    spacing: 10,
                    children: [
                      if (onMapTab) _ReadyOrdersJumpButton(),
                      CartIcon(),
                    ],
                  ),
                ),
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

  final List _pages = [TrackMap(), Home(), DeliveryProfile()];

  List<String> icons = [AssetIcon.marker, AssetIcon.category, AssetIcon.user];

  List<String> labels = ['Map', 'Бараа', 'Профайл'];
}

class _ReadyOrdersJumpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'VS_READY_ORDERS',
      shape: const CircleBorder(),
      backgroundColor: Colors.white,
      onPressed: () => goto(const ReadyOrdersPage()),
      child: const Icon(Icons.checklist_rounded, color: primary),
    );
  }
}

class ReadyOrdersPage extends StatelessWidget {
  const ReadyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SideAppBar(text: 'Бэлэн захиалгууд'),
      body: const ReadyOrders(showHeader: false),
    );
  }
}
