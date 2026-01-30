import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/delivery_history/delivery_history_detail.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:intl/intl.dart';

class ShipmentHistory extends StatefulWidget {
  const ShipmentHistory({super.key});

  @override
  State<ShipmentHistory> createState() => _ShipmentHistoryState();
}

class _ShipmentHistoryState extends State<ShipmentHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future init() async {
    await LoadingService.run(() async {
      final driver = context.read<DriverProvider>();
      await driver.getShipmentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          appBar: const SideAppBar(text: 'Түгээлтийн түүх'),
          backgroundColor: grey50,
          body: Column(
            spacing: 10,
            children: [
              searchBar(provider),
              Expanded(
                child: provider.history.isEmpty
                    ? Center(child: Column(children: [NoResult()]))
                    : ListView.builder(
                        itemCount: provider.history.length,
                        itemBuilder: (context, index) {
                          return ShipmentBuilder(
                            delivery: provider.history[index],
                            idx: index,
                          );
                        },
                      ),
              ),
            ],
          ).paddingAll(10),
        );
      },
    );
  }

  Widget searchBar(DriverProvider driver) {
    return Row(
      spacing: 10,
      children: [
        dateButton(true),
        dateButton(false),
      ],
    );
  }

  Widget dateButton(bool isStart) {
    return Consumer<DriverProvider>(
      builder: (context, driver, child) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isStart ? 'Эхлэх' : 'Дууусах',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = await pickdate(context,
                    initial: isStart ? driver.start : driver.end);
                if (value == null) return;
                driver.updateDate(value, isStart: isStart);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: primary),
                ),
              ),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_sharp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(
                            isStart ? driver.start : driver.end,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShipmentBuilder extends StatelessWidget {
  final Delivery delivery;
  final int idx;
  const ShipmentBuilder({super.key, required this.delivery, required this.idx});

  @override
  Widget build(BuildContext context) {
    // Явцын хувь
    double progressValue = (parseDouble(delivery.progress)) / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (delivery.orders.isNotEmpty) {
            goto(ShipmentHistoryDetail(delivery: delivery));
          } else {
            message('Захиалга олдсонгүй!');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              // Дээд хэсэг: ID болон Огноо
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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

                    // Цагийн мэдээллүүд
                    Row(
                      children: [
                        _buildTimeInfo('Эхэлсэн',
                            maybeNull(delivery.startedOn).substring(10, 16)),
                        _buildTimeDivider(),
                        _buildTimeInfo('Дууссан',
                            maybeNull(delivery.endedOn).substring(10, 16)),
                        _buildTimeDivider(),
                        _buildTimeInfo(
                            'Захиалга', delivery.orders.length.toString(),
                            isLast: true),
                      ],
                    ),
                  ],
                ),
              ),

              // Явцын хэсэг (Progress Section)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.orange),
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
        ),
      ),
    );
  }

  // Цаг харуулах жижиг widget
  Widget _buildTimeInfo(String label, String value, {bool isLast = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            isLast ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // Хуваагч зураас
  Widget _buildTimeDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }
}
