import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/order_card/order_status_chip.dart';
import 'package:pharmo_app/views/order_history/order_card/user_tag.dart';
import 'package:pharmo_app/views/order_history/pharm_order_history/pharm_order_detail.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_detail.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        bool isPharma = Authenticator.security!.isPharmacist;
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: (!isPharma && order.orderProcess == OrderProcess.newOrder)
              ? Slidable(
                  key: ValueKey(order.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      CustomSlidableAction(
                        onPressed: (context) =>
                            _showDeleteDialog(context, provider),
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.red.shade700, size: 24),
                            const Text('Устгах',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: _buildOrderCard(context, provider, isPharma),
                )
              : _buildOrderCard(context, provider, isPharma),
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderProvider provider,
    bool isPharma,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isPharma) {
            goto(PharmOrderDetail(order: order));
            return;
          }
          goto(SellerOrderDetail(oId: order.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isPharma),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              _buildBody(context, provider, isPharma),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPharma) {
    String displayName = !isPharma
        ? (order.customer ?? "Захиалагч")
        : (order.supplier ?? "Нийлүүлэгч");
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          UserTag(name: displayName, isSupplier: isPharma),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                toPrice(order.totalPrice.toString()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
              ),
              Text(
                '#${order.orderNo}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    OrderProvider provider,
    bool isPharma,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderStatusChip(order.orderStatus),
                    const SizedBox(height: 8),
                    IconedText(
                      icon: Icons.sync_outlined,
                      text: order.orderProcess.name,
                      color: order.orderProcess.color,
                    ),
                    const SizedBox(height: 4),
                    if (order.createdOn != null)
                      IconedText(
                        icon: Icons.calendar_today_outlined,
                        text: order.createdOn!.length > 10
                            ? order.createdOn!.substring(0, 10)
                            : order.createdOn!,
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          if (isPharma && (order.isAcceptable)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () async => await provider.confirmOrder(order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: succesColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Хүлээн авах',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OrderProvider provider) async {
    final confirmed = await confirmDialog(
      context: context,
      title: 'Захиалга устгах уу?',
    );
    if (!confirmed) return;
    await provider.deleteSellerOrder(orderId: order.id);
  }
}
