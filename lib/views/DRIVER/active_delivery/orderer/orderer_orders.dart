import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_order_card.dart';

class OrdererOrders extends StatelessWidget {
  final User orderer;

  const OrdererOrders({super.key, required this.orderer});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final allOrders = jagger.delivery!.orders;
        final orders = allOrders
            .where((e) =>
                (e.customer != null && e.customer!.id == orderer.id) ||
                (e.user != null && e.user!.id == orderer.id) ||
                (e.orderer != null && e.orderer!.id == orderer.id))
            .toList();
        final deliveredCount = orders.where((o) => o.process == 'D').length;
        final totalCount = orders.length;
        final progress = totalCount > 0 ? deliveredCount / totalCount : 0.0;
        return Scaffold(
          backgroundColor: grey100,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withOpacity(0.8)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Text(
                              orderer.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                            Row(
                              children: [
                                _buildProgressBadge(progress),
                                const SizedBox(width: 12),
                                Text(
                                  '$deliveredCount / $totalCount хүргэсэн',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // title: Text(
                  //   ordererName,
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // centerTitle: false,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeliveryOrderCard(orderId: order.id),
                      );
                    },
                    childCount: orders.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBadge(double progress) {
    final percentage = (progress * 100).toInt();
    Color bgColor;
    String text;

    if (progress == 1.0) {
      bgColor = Colors.greenAccent;
      text = 'Бүгд хүргэсэн';
    } else if (progress > 0) {
      bgColor = Colors.orangeAccent;
      text = '$percentage% хүргэсэн';
    } else {
      bgColor = Colors.white.withOpacity(0.3);
      text = 'Эхлээгүй';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
