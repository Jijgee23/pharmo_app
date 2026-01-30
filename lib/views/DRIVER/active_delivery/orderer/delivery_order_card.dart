import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_detail.dart';
import 'package:pharmo_app/views/DRIVER/widgets/status_changer.dart';

class DeliveryOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final int delId;

  const DeliveryOrderCard({
    super.key,
    required this.order,
    required this.delId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, provider, child) {
        bool isSeller = LocalBase.security!.role == 'S';
        return _buildOrderCard(context, provider, isSeller);
      },
    );
  }

  Widget _buildOrderCard(
      BuildContext context, JaggerProvider provider, bool isSeller) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => goto(DeliveryDetail(order: order, delId: delId)),
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
              _buildHeader(context),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  String getName() {
    if (order.orderer != null && order.orderer!.name != 'null') {
      return order.orderer!.name;
    } else if (order.customer != null && order.customer!.name != 'null') {
      return order.customer!.name;
    } else {
      return order.user!.name;
    }
  }

  Widget _buildHeader(BuildContext context) {
    // Худалдагч бол 'Customer' нэр, Худалдан авагч бол 'Supplier' нэр харуулна
    String displayName = getName();
    // IconData headerIcon =
    //     isSeller ? Icons.person_outline : Icons.home_work_outlined;

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
                  Icon(Icons.person_outline, color: primary, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primary,
                      ),
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

  Widget _buildBody(BuildContext context) {
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
                    if (order.status != null)
                      _buildStatusChip(status(order.status)),
                    const SizedBox(height: 8),
                    if (order.process != null)
                      _buildInfoRow(
                        Icons.sync_outlined,
                        process(order.process),
                        Colors.blue,
                      ),
                    const SizedBox(height: 4),
                    if (order.createdOn != null)
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        order.createdOn.length > 10
                            ? order.createdOn.substring(0, 10)
                            : order.createdOn,
                        Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () async => await Get.bottomSheet(
                  StatusChanger(
                    delId: delId,
                    orderId: order.id,
                    status: order.status,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: succesColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Төлөв өөрчлөх',
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
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
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
}
