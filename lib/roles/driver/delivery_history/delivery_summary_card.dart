import 'package:pharmo_app/application/application.dart';

/// Shared "delivery summary" card: id/date header, three time-info slots,
/// progress bar and zones. Used both as a list row (ShipmentBuilder, third
/// slot = order count) and as the detail page's header (ShipmentHistoryDetail,
/// third slot = the delivery man's name).
class DeliverySummaryCard extends StatelessWidget {
  final Delivery delivery;
  final String thirdInfoLabel;
  final String thirdInfoValue;

  const DeliverySummaryCard({
    super.key,
    required this.delivery,
    required this.thirdInfoLabel,
    required this.thirdInfoValue,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = (parseDouble(delivery.progress)) / 100;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${delivery.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      maybeNull(delivery.startedOn).substring(0, 10),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _timeInfo('Эхэлсэн', maybeNull(delivery.startedOn).substring(10, 16)),
                    _timeDivider(),
                    _timeInfo('Дууссан', maybeNull(delivery.endedOn).substring(10, 16)),
                    _timeDivider(),
                    _timeInfo(thirdInfoLabel, thirdInfoValue, isLast: true),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Түгээлтийн явц',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${delivery.progress}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    color: progressValue == 1.0 ? Colors.green : primary,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                if (delivery.zones.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Бүс: ${delivery.zones.map((z) => z.name).join(', ')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeInfo(String label, String value, {bool isLast = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isLast ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _timeDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }
}
