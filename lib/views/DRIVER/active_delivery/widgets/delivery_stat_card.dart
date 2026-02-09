
import 'package:pharmo_app/application/application.dart';

class DeliveryStatCard extends StatelessWidget {
  const DeliveryStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.withExnanded = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool withExnanded;

  @override
  Widget build(BuildContext context) {
    if (withExnanded) {
      return Expanded(child: _content());
    }
    return _content();
  }

  _content() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}