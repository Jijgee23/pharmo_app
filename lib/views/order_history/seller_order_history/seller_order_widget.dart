import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/pharm_order_history/pharm_order_detail.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_detail.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        bool isSeller = LocalBase.security!.role == 'S';
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: LocalBase.security!.role == 'S'
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
                  child: _buildOrderCard(context, provider, isSeller),
                )
              : _buildOrderCard(context, provider, isSeller),
        );
      },
    );
  }

  Widget _buildOrderCard(
      BuildContext context, MyOrderProvider provider, bool isSeller) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSeller) {
            goto(SellerOrderDetail(oId: parseInt(order.id)));
          } else {
            goto(PharmOrderDetail(order: order));
          }
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
              _buildHeader(context, isSeller),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              _buildBody(context, provider, isSeller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSeller) {
    // Худалдагч бол 'Customer' нэр, Худалдан авагч бол 'Supplier' нэр харуулна
    String displayName = isSeller
        ? (order.customer ?? "Захиалагч")
        : (order.supplier ?? "Нийлүүлэгч");
    IconData headerIcon =
        isSeller ? Icons.person_outline : Icons.home_work_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(headerIcon, color: primary, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                toPrice(order.totalPrice.toString()),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700),
              ),
              Text(
                '#${order.orderNo}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, MyOrderProvider provider, bool isSeller) {
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
                    if (order.status != null) _buildStatusChip(order.status!),
                    const SizedBox(height: 8),
                    if (order.process != null)
                      _buildInfoRow(
                          Icons.sync_outlined, order.process!, Colors.blue),
                    const SizedBox(height: 4),
                    if (order.createdOn != null)
                      _buildInfoRow(
                          Icons.calendar_today_outlined,
                          order.createdOn!.length > 10
                              ? order.createdOn!.substring(0, 10)
                              : order.createdOn!,
                          Colors.grey.shade600),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          // Хэрэв PharmOrder (Худалдан авагч) бол "Хүлээн авах" товчийг харуулна
          if (!isSeller &&
              (order.process == 'Бэлэн болсон' ||
                  order.process == 'Түгээлтэнд гарсан')) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () => _confirmOrder(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: succesColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Хүлээн авах',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Туслах функцууд (Status Chip, Info Row, Dialogs...)
  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('хүлээгдэж')) return Colors.orange;
    if (status.contains('баталгаажсан')) return Colors.blue;
    if (status.contains('хүргэгдсэн')) return Colors.green;
    return Colors.grey;
  }

  // Actions
  Future<void> _confirmOrder(
      BuildContext context, MyOrderProvider provider) async {
    dynamic res = await provider.confirmOrder(order.id);
    message(res['message']);
  }

  void _showDeleteDialog(BuildContext context, MyOrderProvider provider) {
    // Дээрх SellerOrderWidget-ийн dialog кодыг энд ашиглана
  }
}
