import 'package:pharmo_app/application/app_lite.dart';

/// One row of the report table: the period, its total with a bar sized by
/// [share], and the order count.
class ReportWidget extends StatelessWidget {
  final String date;
  final String total;
  final String count;

  /// This row's total against the largest one in the table, 0–1.
  final double share;

  const ReportWidget({
    super.key,
    required this.date,
    required this.total,
    required this.count,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Огноо
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          // Дүн
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                Text(
                  total,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: share.clamp(0, 1),
                    minHeight: 4,
                    color: tint,
                    backgroundColor: tint.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
          // Тоо ширхэг
          Expanded(
            flex: 1,
            child: Text(
              count,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
