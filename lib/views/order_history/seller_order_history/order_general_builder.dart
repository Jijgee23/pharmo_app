import 'package:pharmo_app/application/application.dart';
import 'package:get/get.dart';
class OrderGeneralBuilder extends StatelessWidget {
  final OrderModel order;
  const OrderGeneralBuilder({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          spacing: 16,
          children: [
            // Date and Time Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Огноо',
                      value: order.createdOn.toString().substring(0, 10),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.access_time_outlined,
                      label: 'Цаг',
                      value: order.createdOn.toString().substring(11, 16),
                    ),
                  ),
                ],
              ),
            ),

            // Order Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Захиалгын мэдээлэл',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ModernDetailRow(
                    'Захиалгын дугаар',
                    order.orderNo.toString(),
                  ),
                  DividerBuidler(),
                  ModernDetailRow('Төлөв', order.status),
                  DividerBuidler(),
                  ModernDetailRow('Явц', order.process),
                  DividerBuidler(),
                  ModernDetailRow('Нийт үнэ', toPrice(order.totalPrice),
                      valueColor: Colors.green.shade700),
                  DividerBuidler(),
                  ModernDetailRow('Тайлбар', order.noteText.toString()),
                  DividerBuidler(),
                  ModernDetailRow('Төлбөрийн хэлбэр', order.payType.toString()),
                  DividerBuidler(),
                  ModernDetailRow('Тоо ширхэг', order.totalCount.toString()),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Хэрэглэгч мэдээлэл',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ModernDetailRow('Захиалагч', order.customer),
                  DividerBuidler(),
                  ModernDetailRow('Нийлүүлэгч', order.supplier),
                  DividerBuidler(),
                  ModernDetailRow('Хаяг', order.address),
                ],
              ),
            ),
          ],
        ),
      ).paddingAll(10),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
