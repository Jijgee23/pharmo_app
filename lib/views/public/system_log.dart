import 'package:pharmo_app/application/application.dart';

class SystemLog extends StatefulWidget {
  const SystemLog({super.key});

  @override
  State<SystemLog> createState() => _SystemLogState();
}

class _SystemLogState extends State<SystemLog> {
  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  void _fetchLogs() {
    Future.microtask(() => context.read<LogProvider>().getLogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: SideAppBar(
        text: 'Системийн лог', // Таны SideAppBar эсвэл AppBar-тай нийцүүлсэн
      ),
      body: Consumer<LogProvider>(
        builder: (context, value, child) {
          if (value.logs.isEmpty) {
            return const Center(child: Text('Лог олдсонгүй'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: value.logs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              final item = value.logs[i];
              return _buildLogCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(Log item) {
    final dateParts = item.date.split('T');
    final date = dateParts[0];
    final time = dateParts.length > 1 ? dateParts[1].substring(0, 5) : '--:--';

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline хэсэг
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Картын хэсэг
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.desc,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTag(Icons.calendar_today, date),
                      _buildInfoTag(Icons.access_time, time),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
