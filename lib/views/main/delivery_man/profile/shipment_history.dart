import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/profile/shipment_history_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

class ShipmentHistory extends StatefulWidget {
  const ShipmentHistory({super.key});

  @override
  State<ShipmentHistory> createState() => _ShipmentHistoryState();
}

class _ShipmentHistoryState extends State<ShipmentHistory> {
  bool fetching = false;

  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  late JaggerProvider jaggerProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setFetching(true);
      jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      jaggerProvider.getShipmentHistory();
      setFetching(false);
    });
  }

  DateTimeRange range = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) {
        return DataScreen(
          appbar: const SideAppBar(text: 'Түгээлтийн түүх'),
          loading: fetching,
          empty: false,
          child: Column(
            children: [
              searchBar(),
              Expanded(
                child: provider.history.isEmpty
                    ? Center(child: Text('Түүх олдсонгүй!'))
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
        );
      },
    );
  }

  Widget searchBar() {
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
                await jaggerProvider.getShipmentHistory(range: range),
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
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
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
        margin: EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        color: const Color.fromARGB(255, 121, 219, 222),
        child: Padding(
          padding: EdgeInsets.all(12),
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
              Wrap(
                spacing: 10,
                children: [
                  infoRow(
                      'Огноо', maybeNull(delivery.startedOn).substring(0, 10)),
                  infoRow('Эхэлсэн',
                      maybeNull(delivery.startedOn).substring(10, 19)),
                  infoRow(
                      'Дууссан', maybeNull(delivery.endedOn).substring(10, 19)),
                ],
              ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
