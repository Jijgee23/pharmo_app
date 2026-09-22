import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/order_card/order_status_chip.dart';
import 'package:pharmo_app/views/order_history/order_card/user_tag.dart';

/// Shared card shell used by [OrderCard] (order history) and
/// [DeliveryOrderCard] (driver delivery flow) — same layout, different
/// underlying order models, so callers adapt their model into these params.
class OrderSummaryCard extends StatelessWidget {
  final String name;
  final bool isSupplier;
  final String price;
  final String orderNo;
  final OrderStatus status;
  final String processText;
  final Color processColor;
  final String? createdOn;
  final VoidCallback onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OrderSummaryCard({
    super.key,
    required this.name,
    this.isSupplier = false,
    required this.price,
    required this.orderNo,
    required this.status,
    required this.processText,
    required this.processColor,
    this.createdOn,
    required this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserTag(name: name, isSupplier: isSupplier),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          toPrice(price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          '#$orderNo',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OrderStatusChip(status),
                              const SizedBox(height: 8),
                              IconedText(
                                icon: Icons.sync_outlined,
                                text: processText,
                                color: processColor,
                              ),
                              const SizedBox(height: 4),
                              if (createdOn != null)
                                IconedText(
                                  icon: Icons.calendar_today_outlined,
                                  text: createdOn!.length > 10
                                      ? createdOn!.substring(0, 10)
                                      : createdOn!,
                                  color: Colors.grey.shade600,
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: succesColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            actionLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
