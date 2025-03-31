import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/shipment_history_detail.dart';
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
  build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) {
        return DataScreen(
          appbar: const SideAppBar(text: 'Түгээлтийн түүх'),
          loading: fetching,
          empty: false,
          child: Column(
            spacing: 20,
            children: [
              searchBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 5,
                    children: [
                      ...provider.history.map(
                        (del) => ShipmentBuilder(
                          delivery: del,
                          idx: provider.history.indexOf(del),
                        ),
                      ),
                      SizedBox(height: 50)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget searchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async {
            final r = await showCalendar();
            if (r != null) {
              setState(() {
                range = r;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            decoration: BoxDecoration(
              color: primary.withAlpha(100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                  '${range.start.toString().substring(0, 10)} => ${range.end.toString().substring(0, 10)}'),
            ),
          ),
        ),
        InkWell(
          onTap: () async =>
              await jaggerProvider.getShipmentHistory(range: range),
          child: Container(
            padding: EdgeInsets.all(7.5),
            height: 40,
            width: Sizes.width * .25,
            decoration: BoxDecoration(
              color: primary.withAlpha(100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(child: Text('Шүүх')),
          ),
        )
      ],
    );
  }

  Future<DateTimeRange?> showCalendar() {
    final date = showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      confirmText: 'Болсон',
      cancelText: 'Буцах',
      saveText: 'Хадгалах',
      helpText: 'Огноо сонгох',
      builder: (context, child) {
        return Theme(
          data: ThemeData(),
          child: child!,
        );
      },
    );
    return date;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: idx.isOdd ? white : atnessGrey,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (idx.isOdd) BoxShadow(color: frenchGrey, blurRadius: 3)
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(title: 'Түгээлтийн дугаар', value: delivery.id.toString()),
            row(
                title: 'Огноо:',
                value: maybeNull(delivery.startedOn).substring(0, 10)),
            row(
                title: 'Эхлэсэн цаг',
                value: maybeNull(delivery.startedOn).substring(10, 19)),
            row(
                title: 'Дууссан цаг',
                value: maybeNull(delivery.endedOn).substring(10, 19)),
            row(title: 'Явц:', value: (maybeNull('${delivery.progress}%'))),
            if (delivery.zones.isNotEmpty)
              row(
                  title: 'Бүсүүд',
                  value: delivery.zones.map((z) => '${z.name} ').join())
          ],
        ),
      ),
    );
  }

  row({required String title, String? value}) {
    if (value != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.cleanBlack,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      );
    } else {
      return null;
    }
  }

  formatTime(double duration) {
    int totalSeconds = duration.toInt();
    int hours = (totalSeconds ~/ 3600);
    int mins = ((totalSeconds % 3600) ~/ 60);
    int seconds = (totalSeconds % 60);
    return '${hours > 0 ? '${hours.toString()} цаг' : ''}  ${mins.toString()} минут ${seconds.toString()} секунд';
  }
}
