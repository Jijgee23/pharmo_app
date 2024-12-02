import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/shipment.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:provider/provider.dart';

class ShipmentHistory extends StatefulWidget {
  const ShipmentHistory({super.key});

  @override
  State<ShipmentHistory> createState() => _ShipmentHistoryState();
}

class _ShipmentHistoryState extends State<ShipmentHistory> {
  late JaggerProvider jaggerProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      jaggerProvider.getShipmentHistory();
    });
  }

  DateTime selectedDate = DateTime.now();
  String searchText = '-с өмнөх';
  String counter = '1';
  bool isStartDate = true;
  final TextEditingController _countController =
      TextEditingController(text: '1');

  void getWidget(String filter, String type, JaggerProvider provider) {
    if (filter == 'Огноогоор') {
      provider.getFilter(byDate());
    } else if (filter == 'Захиалгын тоогоор') {
      provider.getFilter(byNumber(provider.type));
    } else if (filter == 'Явцын хувиар') {
      provider.getFilter(byNumber(provider.type));
    } else if (filter == 'Зарлагын дүнгээр') {
      provider.getFilter(byNumber(provider.type));
    }
  }

  @override
  build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) {
        // final shipmets = provider.shipments;
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: DefaultBox(
            title: 'Түгээлтийн түүх',
            child: Column(
              children: [
                Box(
                  child: Column(
                    children: [
                      selectFilter(),
                      filters(provider),
                    ],
                  ),
                ),
                Expanded(
                  child: Box(child: shipments(provider)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  body(JaggerProvider provider) {
    return CustomScrollView(
      slivers: [
        selectFilter(),
        filters(provider),
        shipments(provider),
      ],
    );
  }

  filters(JaggerProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.primary),
          ),
          onPressed: provider.getShipmentHistory,
          child: const Text(
            'Бүгд',
            style: TextStyle(color: Colors.white),
          ),
        ),
        provider.selecterFilter,
      ],
    );
  }

  selectFilter() {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Шүүх төрөл:',
            style: TextStyle(fontSize: 14, color: AppColors.cleanBlack),
          ),
          const SizedBox(width: 10),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButton(
              underline: const SizedBox(),
              dropdownColor: AppColors.cleanWhite,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              borderRadius: BorderRadius.circular(10),
              alignment: Alignment.center,
              items: provider.filters.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 12)),
                );
              }).toList(),
              onChanged: (a) {
                provider.changeFilter(a!);
                if (a == 'Захиалгын тоогоор') {
                  if (provider.operator == '=') {
                    provider.changeType('ordersCnt');
                  } else if (provider.operator == '=>') {
                    provider.changeType('ordersCnt__gte');
                  } else if (provider.operator == '=<') {
                    provider.changeType('ordersCnt__lte');
                  }
                } else if (a == 'Явцын хувиар') {
                  if (provider.operator == '=') {
                    provider.changeType('progress');
                  } else if (provider.operator == '=>') {
                    provider.changeType('progress__gte');
                  } else if (provider.operator == '=<') {
                    provider.changeType('progress__lte');
                  }
                } else if (a == 'Зарлагын дүнгээр') {
                  if (provider.operator == '=') {
                    provider.changeType('expense');
                  } else if (provider.operator == '=>') {
                    provider.changeType('expense__gte');
                  } else if (provider.operator == '=<') {
                    provider.changeType('expense__lte');
                  }
                }
                getWidget(a, provider.type, provider);
              },
              hint: Text(provider.filter,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.cleanBlack)),
            ),
          ),
        ],
      ),
    );
  }

  shipments(JaggerProvider provider) {
    return provider.shipments.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              children: provider.shipments
                  .map((ship) => !provider.isFetching
                      ? ShipmentBuilder(shipment: ship)
                      : shipSkeleton())
                  .toList(),
            ),
          )
        : const Center(
            child: SizedBox(
              child: Text('Үр дүр олдсонгүй'),
            ),
          );
  }

  _selectDate(BuildContext context, JaggerProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Огноо сонгох',
      cancelText: 'Буцах',
      confirmText: "Сонгох",
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        provider.selectDate(picked);
      });
    }
  }

  byDate() {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              InkWell(
                onTap: () => _selectDate(context, provider),
                child: Text(
                  provider.selectedDate.toString().substring(0, 10),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                searchText,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Switch(
            activeColor: AppColors.secondary,
            value: provider.isStartDate,
            onChanged: (v) {
              provider.toggleIsStartDate();
              searchText = provider.isStartDate ? '-с өмнөх' : '-с хойш';
            },
          ),
          const SizedBox(width: 10),
          filterButton(() {
            provider.filterShipment(
                provider.isStartDate == true ? 'end' : 'start',
                provider.selectedDate.toString().substring(0, 10));
          })
        ],
      ),
    );
  }

  byNumber(String type) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            height: 40,
            width: 60,
            child: Center(
              child: TextField(
                textAlign: TextAlign.center,
                controller: _countController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => counter = v),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                provider.operator,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: provider.operators
                              .map(
                                (e) => InkWell(
                                  onTap: () {
                                    provider.changeOperator(e);
                                    if (e == '=' &&
                                        provider.filter ==
                                            'Захиалгын тоогоор') {
                                      provider.changeType('ordersCnt');
                                    } else if (e == '=>' &&
                                        provider.filter ==
                                            'Захиалгын тоогоор') {
                                      provider.changeType('ordersCnt__lte');
                                    } else if (e == '=<' &&
                                        provider.filter ==
                                            'Захиалгын тоогоор') {
                                      provider.changeType('ordersCnt__gte');
                                    } else if (e == '=' &&
                                        provider.filter == 'Явцын хувиар') {
                                      provider.changeType('progress');
                                    } else if (e == '=>' &&
                                        provider.filter == 'Явцын хувиар') {
                                      provider.changeType('progress__lte');
                                    } else if (e == '=<' &&
                                        provider.filter == 'Явцын хувиар') {
                                      provider.changeType('progress__gte');
                                    } else if (e == '=' &&
                                        provider.filter == 'Зарлагын дүнгээр') {
                                      provider.changeType('expense');
                                    } else if (e == '=>' &&
                                        provider.filter == 'Зарлагын дүнгээр') {
                                      provider.changeType('expense__lte');
                                    } else if (e == '=<' &&
                                        provider.filter == 'Зарлагын дүнгээр') {
                                      provider.changeType('expense__gte');
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: Center(child: Text(e)),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
          filterButton(() {
            provider.filterShipment(provider.type, counter);
          })
        ],
      ),
    );
  }

  Widget shipSkeleton() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade300]),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [Constants.defaultShadow],
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    );
  }

  shipWidget(
    Shipment shipment,
    final VoidCallback onTap,
    final int index,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${index + 1}. ${shipment.createdOn!}'),
                Text(
                  shipment.expense != null ? shipment.expense.toString() : '-',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  filterButton(VoidCallback onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
      ),
      onPressed: onPressed,
      child: const Text(
        'Шүүх',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ShipmentBuilder extends StatefulWidget {
  final Shipment shipment;
  const ShipmentBuilder({super.key, required this.shipment});

  @override
  State<ShipmentBuilder> createState() => _ShipmentBuilderState();
}

class _ShipmentBuilderState extends State<ShipmentBuilder> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: AppColors.mainGrey,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   Constants.defaultShadow,
        // ],
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: InkWell(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(
                title: 'Эхлэсэн цаг:',
                value: (widget.shipment.startTime != null)
                    ? widget.shipment.startTime!
                    : '-'),
            row(
                title: 'Дууссан цаг:',
                value: (widget.shipment.endTime != null)
                    ? widget.shipment.endTime!
                    : '-'),
            row(
                title: 'Үүссэн огноо:',
                value: (widget.shipment.createdOn != null)
                    ? widget.shipment.createdOn!.substring(0, 10)
                    : '-'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              child: isExpanded
                  ? Column(
                      children: [
                        row(
                            title: 'Хугацаа:',
                            value: (widget.shipment.duration != null)
                                ? formatTime(widget.shipment.duration!)
                                : '-'),
                        row(
                            title: 'Зарлага:',
                            value: (widget.shipment.expense != null)
                                ? '${widget.shipment.expense!.toString()}₮'
                                : '-'),
                        row(
                            title: 'Явц:',
                            value: (widget.shipment.progress != null)
                                ? '${widget.shipment.progress!.toString()}%'
                                : '-'),
                        row(
                            title: 'Тоо ширхэг:',
                            value: (widget.shipment.ordersCnt != null)
                                ? widget.shipment.ordersCnt!.toString()
                                : '-'),
                      ],
                    )
                  : const SizedBox(),
            ),
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: !isExpanded
                    ? const Center(child: Icon(Icons.arrow_drop_down_rounded))
                    : const Center(child: Icon(Icons.arrow_drop_up_rounded)))
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
        Text(value,
            style: const TextStyle(
                color: AppColors.secondary, fontWeight: FontWeight.bold))
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
