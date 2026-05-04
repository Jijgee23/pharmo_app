import 'package:pharmo_app/application/application.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketPreview extends StatelessWidget {
  final DeliveryOrder order;
  const TicketPreview({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Authenticator.security;
    final delmanName = user != null ? user.name : "";
    final customerName =
        order.orderer?.name ?? order.customer?.name ?? order.user?.name ?? 'Тодорхойгүй';
    final dateStr =
        order.createdOn.length >= 10 ? order.createdOn.substring(0, 10) : order.createdOn;

    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final delivery = jagger.delivery;
        final now = DateTime.now();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'PHARMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Захиалгын хуудас',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),

              // Order meta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    _infoRow('Захиалга', '#${order.orderNo}'),
                    _infoRow('Захиалгын огноо', dateStr),
                    _infoRow('Захиалагч', customerName),
                    _infoRow('Төлбөр', order.paymentType.name),
                    _infoRow('Түгээлт', "$delmanName (Түгээгч)"),
                    _infoRow('Түгээлтийн бүс', order.zone.name),
                    _infoRow('НӨАТ', toPrice(order.totalPrice * 0.1)),
                    if (delivery != null) _infoRow('Түгээлтийн дугаар', delivery.id.toString()),
                    _infoRow('Баримтын огноо', "${now.yyyyMMdd} | ${now.hhMMss}"),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text('Baraa',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          width: 28,
                          child: Text('Too',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 4),
                        SizedBox(
                          width: 72,
                          child: Text('Une',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...order.items.map((item) {
                      final qtyNum = num.tryParse((item.qty).toString())?.toDouble() ?? 0;
                      final total = num.tryParse((item.totalPrice).toString())?.toDouble() ?? 0;
                      final unit = qtyNum > 0 ? total / qtyNum : 0.0;
                      final rawName = (item.name).toString();
                      final name = rawName.replaceAll(RegExp(r'[^ -~Ѐ-ӿ]'), '');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                (item.qty).toString(),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 72,
                              child: Text(
                                toPrice(unit),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Totals
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _infoRow("Нийт тоо", '${order.totalCount.toStringAsFixed(0)} ш'),
                    _infoRow("Нийт үнэ", toPrice(order.totalPrice)),
                    if (order.payments.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      ...order.payments.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.payType,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(toPrice(p.amount), style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    _infoRow('Хүлээлгэн өгсөн:', delmanName),
                    _infoRow('Хүлээн авсан:', "__________________"),
                    _infoRow('Бүргүүлэх дүн:', order.totalPrice.toString()),
                  ],
                ),
              ),

              // QR code
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: QrImageView(
                    data: '#${order.orderNo}|$customerName|${toPrice(order.totalPrice)}|$dateStr',
                    version: QrVersions.auto,
                    size: 100,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: const Text(
                  'Баярлалаа!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}
