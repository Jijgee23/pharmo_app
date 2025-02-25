import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/shipment_history_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
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

  @override
  build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) {
        return DataScreen(
          appbar: const SideAppBar(text: 'Түгээлтийн түүх'),
          loading: fetching,
          empty: provider.history.isEmpty,
          child: Column(
            spacing: 20,
            children: [
              Container(color: neonBlue, height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 10,
                    children:
                        provider.history.map((del) => ShipmentBuilder(delivery: del)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  filterButton(VoidCallback onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
      ),
      onPressed: onPressed,
      child: const Text(
        'Шүүх',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ShipmentBuilder extends StatelessWidget {
  final Delivery delivery;
  const ShipmentBuilder({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => goto(ShipmentHistoryDetail(delivery: delivery)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: frenchGrey)),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(title: 'Эхлэсэн цаг:', value: maybeNull(delivery.startedOn)),
            row(title: 'Дууссан цаг:', value: maybeNull(delivery.endedOn)),
            row(title: 'Үүссэн огноо:', value: (maybeNull(delivery.created))),
            row(title: 'Явц:', value: (maybeNull('${delivery.progress}%'))),
            Row(
              children: [...delivery.zones.map((e) => Text(e.name))],
            )
          ],
        ),
      ),
    );
  }

  row({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade700)),
        Text(value, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold))
      ],
    );
  }

  formatTime(double duration) {
    int totalSeconds = duration.toInt();
    int hours = (totalSeconds ~/ 3600);
    int mins = ((totalSeconds % 3600) ~/ 60);
    int seconds = (totalSeconds % 60);
    return '${hours > 0 ? '${hours.toString()} цаг' : ''}  ${mins.toString()} минут ${seconds.toString()} секунд';
  }
}
