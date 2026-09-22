import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/application/application.dart';
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
                        onPressed: (context) => _showDeleteDialog(context, provider),
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red.shade700, size: 24),
                            const Text('Устгах', style: TextStyle(fontSize: 12)),
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
    String displayName =
        !isPharma ? (order.customer ?? "Захиалагч") : (order.supplier ?? "Нийлүүлэгч");
    return OrderSummaryCard(
      name: displayName,
      isSupplier: isPharma,
      price: order.totalPrice.toString(),
      orderNo: order.orderNo,
      status: order.orderStatus,
      processText: order.orderProcess.name,
      processColor: order.orderProcess.color,
      createdOn: order.createdOn,
      onTap: () {
        if (isPharma) {
          goto(PharmOrderDetail(order: order));
          return;
        }
        goto(SellerOrderDetail(oId: order.id));
      },
      actionLabel: (isPharma && order.isAcceptable) ? 'Хүлээн авах' : null,
      onAction: (isPharma && order.isAcceptable)
          ? () async => await provider.confirmOrder(order.id)
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, OrderProvider provider) async {
    final confirmed = await confirmDialog(
      title: 'Захиалга устгах уу?',
    );
    if (!confirmed) return;
    await provider.deleteSellerOrder(orderId: order.id);
  }
}
