import 'package:pharmo_app/application/application.dart';

class ReportWidget extends StatelessWidget {
  final String date;
  final String total;
  final String count;

  const ReportWidget({
    super.key,
    required this.date,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            flex: 2,
            child: Text(
              total,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 13,
              ),
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
