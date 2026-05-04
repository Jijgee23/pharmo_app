import 'package:pharmo_app/application/application.dart';

class OrderItemCard extends StatelessWidget {
  final int orderId;
  final dynamic item;
  final void Function() ontap;
  const OrderItemCard({
    super.key,
    required this.orderId,
    required this.item,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      orderId: orderId,
      qty: item['itemQty'] ?? 0,
      itemName: item['itemName'],
      totalPrice: item['itemTotalPrice'],
      ontap: ontap,
      iQty: item['iQty'],
    );
  }
}

class ItemCard extends StatelessWidget {
  final int orderId;
  final String itemName;
  final double? iQty;
  final double totalPrice, qty;
  final void Function() ontap;

  const ItemCard({
    super.key,
    required this.orderId,
    required this.qty,
    required this.itemName,
    required this.totalPrice,
    required this.ontap,
    this.iQty,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (iQty != null)
                        Text(
                          'Анх захиалсан: $iQty',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Тоо: $qty',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  toPrice(totalPrice),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
