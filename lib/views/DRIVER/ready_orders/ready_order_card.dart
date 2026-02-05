import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';

class ReadyOrderCard extends StatelessWidget {
  final bool selected;
  final void Function()? onTap;
  final DeliveryOrder ord;
  const ReadyOrderCard({
    super.key,
    required this.selected,
    this.onTap,
    required this.ord,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.green.shade300 : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: selected ? 12 : 8,
                  offset: Offset(0, selected ? 4 : 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        selected ? Colors.green.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name with item count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ord.orderer?.name ?? 'Захиалагч',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: selected
                                    ? Colors.green.shade900
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 14,
                                  color: selected
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ord.items.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Order number and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Order number
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ord.orderNo,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Price
                          Text(
                            toPrice(ord.totalPrice),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
