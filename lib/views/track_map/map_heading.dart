import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/ready_orders/ready_orders.dart';
import 'package:pharmo_app/views/track_map/tracking_status_card.dart';

/// The strip along the top of the map: back on a seller's pushed map, the
/// tracking pill while location is being sent, and for VS the ready orders
/// and the basket.
class MapHeading extends StatelessWidget {
  final bool isSeller;
  const MapHeading({super.key, required this.isSeller});

  @override
  Widget build(BuildContext context) {
    final vanSales = Authenticator.security?.isVanSales ?? false;
    return Consumer<JaggerProvider>(
      builder: (context, jagger, _) => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              if (isSeller)
                AppBarButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Буцах',
                  onTap: () => Navigator.maybePop(context),
                ),
              Expanded(
                child: Align(
                  alignment: vanSales ? Alignment.topLeft : Alignment.topCenter,
                  child: jagger.isTracking ? const TrackingPill() : const SizedBox.shrink(),
                ),
              ),
              if (vanSales) ...[
                AppBarButton(
                  icon: Icons.checklist_rounded,
                  tooltip: 'Бэлэн захиалгууд',
                  onTap: () => goto(const ReadyOrdersPage()),
                ),
                const AppBarCartButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
