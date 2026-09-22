import 'package:intl/intl.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_history_detail.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_summary_card.dart';

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
                final value = await pickdate(context, initial: isStart ? driver.start : driver.end);
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
        child: DeliverySummaryCard(
          delivery: delivery,
          thirdInfoLabel: 'Захиалга',
          thirdInfoValue: delivery.orders.length.toString(),
        ),
      ),
    );
  }
}
