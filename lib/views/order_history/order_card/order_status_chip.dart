import 'package:pharmo_app/application/application.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
