import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/views/delivery_man/delivery_history/shipment_history_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';

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

  void init() {
    LoadingService.run(() async {
      final driver = context.read<DriverProvider>();
      await driver.getShipmentHistory();
    });
  }

  DateTimeRange range = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          appBar: const SideAppBar(text: 'Түгээлтийн түүх'),
          body: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                searchBar(provider),
                Expanded(
                  child: provider.history.isEmpty
                      ? Center(child: Column(children: [NoResult()]))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 10),
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
            ),
          ),
        );
      },
    );
  }

  Widget searchBar(DriverProvider driver) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final r = await showCalendar();
                if (r != null) {
                  setState(() {
                    range = r;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${range.start.toString().substring(0, 10)} - ${range.end.toString().substring(0, 10)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () async =>
                await driver.getShipmentHistory(range: range),
            icon: Icon(Icons.filter_list, color: Colors.white),
            label: Text('Шүүх',
                style: TextStyle(
                    fontSize: 16, color: white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTimeRange?> showCalendar() {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      confirmText: 'Болсон',
      cancelText: 'Буцах',
      saveText: 'Хадгалах',
      helpText: 'Огноо сонгох',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary, // Гол өнгө
              onPrimary: Colors.white, // Текст өнгө
              surface: Colors.white, // Арын фон
              onSurface: Colors.black, // Ерөнхий текстийн өнгө
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primary, // Товчны өнгө
              ),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
  }
}

class ShipmentBuilder extends StatelessWidget {
  final Delivery delivery;
  final int idx;
  const ShipmentBuilder({super.key, required this.delivery, required this.idx});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (delivery.orders.isNotEmpty) {
          goto(ShipmentHistoryDetail(delivery: delivery));
        } else {
          message('Захиалга олдсонгүй!');
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        elevation: 0,
        color: white,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Түгээлтийн дугаар: ${delivery.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              SizedBox(height: 5),
              infoRow('Огноо', maybeNull(delivery.startedOn).substring(0, 10)),
              infoRow(
                  'Эхэлсэн', maybeNull(delivery.startedOn).substring(10, 19)),
              infoRow('Дууссан', maybeNull(delivery.endedOn).substring(10, 19)),
              SizedBox(height: 8),
              Text(
                'Явц: ${maybeNull('${delivery.progress}%')}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: (parseDouble(delivery.progress)) / 100,
                color: primary,
                backgroundColor: Colors.grey.shade300,
              ),
              if (delivery.zones.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'Бүсүүд: ${delivery.zones.map((z) => z.name).join(', ')}',
                  style: TextStyle(
                    color: Colors.accents.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
