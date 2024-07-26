import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/shipment.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
  // String date = DateTime.now().toString().substring(0, 10);
  String searchText = '-с өмнөх';
  String counter = '1';
  bool isStartDate = true;
  final TextEditingController _countController =
      TextEditingController(text: '1');

  void getWidget(String filter, String type, JaggerProvider provider) {
    setState(() {
      if (filter == 'Түгээгчээр') {
        provider.getFilter(byDelman(provider, 12));
      } else if (filter == 'Огноогоор') {
        provider.getFilter(byDate());
      } else if (filter == 'Захиалгын тоогоор') {
        provider.changeType('ordersCnt');
        provider.getFilter(byNumber(type));
      } else if (filter == 'Явцын хувиар') {
        provider.changeType('progress');
        provider.getFilter(byNumber(type));
      } else if (filter == 'Зарлагын дүнгээр') {
        provider.changeType('expense');
        provider.getFilter(byNumber(type));
      }
    });
  }

  void setType(String filter, JaggerProvider provider) {
    setState(() {
      if (filter == 'Захиалгын тоогоор') {
        if (provider.operator == '=') {
          provider.changeType('ordersCnt');
        } else if (provider.operator == '=<') {
          provider.changeType('ordersCnt__gte');
        } else if (provider.operator == '=>') {
          provider.changeType('ordersCnt__lte');
        }
      } else if (filter == 'Явцын хувиар') {
        if (provider.operator == '=') {
          provider.changeType('progress');
        } else if (provider.operator == '=<') {
          provider.changeType('progress__gte');
        } else if (provider.operator == '=<') {
          provider.changeType('progress__lte');
        }
        //  provider.changeType('progress');
      } else if (filter == 'Зарлагын дүнгээр') {
        provider.changeType('expense');
      }
    });
  }

  void changeOperator(String opr, JaggerProvider provider) {
    setState(() {
      provider.changeOperator(opr);
    });
  }

  @override
  build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          appBar: _appBar(),
          body: body(provider),
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
    return SliverAppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.secondary),
            ),
            onPressed: provider.getShipmentHistory,
            child: const Text('Бүгд', style: TextStyle(color: Colors.white)),
          ),
          provider.selecterFilter,
        ],
      ),
    );
  }

  selectFilter() {
    return Consumer<JaggerProvider>(
      builder: (_, provider, child) => SliverAppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        title: Row(
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
                alignment: Alignment.center,
                items: provider.filters.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (a) {
                  provider.changeFilter(a!);
                  setType(a, provider);
                  getWidget(a, provider.type, provider);
                },
                hint: Text(provider.filter,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.cleanBlack)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  shipments(JaggerProvider provider) {
    return SliverFillRemaining(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: provider.shipments.isNotEmpty
            ? ListView.builder(
                itemCount: provider.shipments.length,
                itemBuilder: (context, index) {
                  final shipment = provider.shipments[index];
                  return shipWidget(
                      shipment, () => showDetail(shipment), index);
                },
              )
            : const Center(
                child: SizedBox(
                  child: Text('Үр дүр олдсонгүй'),
                ),
              ),
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
        //   date = picked.toString().substring(0, 10);
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

  byNumber(String para) {
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              items: provider.operators.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                var condition = provider.operator;
                var filter = provider.filter;
                changeOperator(newValue!, provider);
                if (filter == 'Захиалгын тоогоор') {
                  if (condition == '=') {
                    para = 'ordersCnt';
                  } else if (condition == '=<') {
                    para = 'ordersCnt__gte';
                  } else if (condition == '=>') {
                    para = 'ordersCnt__lte';
                  }
                } else if (filter == 'Явцаар') {
                  if (condition == '=') {
                    para = 'progress';
                  } else if (condition == '=<') {
                    para = 'progress__gte';
                  } else if (condition == '=>') {
                    para = 'progress__lte';
                  }
                } else if (filter == 'Зарлагын дүнгээр') {
                  if (condition == '=') {
                    para = 'expense';
                  } else if (condition == '=<') {
                    para = 'expense__gte';
                  } else if (condition == '=>') {
                    para = 'expense__lte';
                  }
                }
              },
              hint: Text(provider.operator),
            ),
          ),
          const SizedBox(width: 10),
          filterButton(() {
            provider.filterShipment(para, counter);
          })
        ],
      ),
    );
  }

  byDelman(JaggerProvider provider, int id) {
    return Row(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: DropdownButton(
            underline: const SizedBox(),
            items: <String>['Болд', 'Төмөр', 'Баj'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (v) {
              print(v);
              provider.changeDelman(v!);
            },
            hint: Text(provider.delman,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.cleanBlack)),
          ),
        ),
        const SizedBox(width: 10),
        filterButton(() => provider.filterShipment('delman', id.toString()))
      ],
    );
  }

  filterButton(VoidCallback onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.secondary),
      ),
      onPressed: onPressed,
      child: const Text(
        'Шүүх',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  _appBar() {
    return AppBar(
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left)),
      toolbarHeight: 30,
      title: const Text(
        'Түгээлтийн түүх',
        style: TextStyle(fontSize: 14),
      ),
      centerTitle: true,
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
                Text(shipment.ordersCnt.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showDetail(Shipment shipment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Түгээлтийн дэлгэрэнгүй'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Үүссэн огноо'),
                      Text('Эхлэсэн огноо'),
                      Text('Дуусах огноо'),
                      Text('Тоо ширхэг'),
                      Text('Явц'),
                      Text('Нийлүүлэгч'),
                      Text('Түгээгч'),
                      Text('Хугацаа'),
                      Text('Зарлагын дүн')
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(shipment.createdOn ?? '-'),
                      Text(shipment.startTime ?? '-'),
                      Text(shipment.endTime ?? '-'),
                      Text(shipment.ordersCnt != null
                          ? shipment.ordersCnt.toString()
                          : '-'),
                      Text(shipment.progress != null
                          ? shipment.progress.toString()
                          : '-'),
                      Text(shipment.supplier != null
                          ? shipment.delman.toString()
                          : '-'),
                      Text(shipment.delman != null
                          ? shipment.delman.toString()
                          : '-'),
                      Text(shipment.duration != null
                          ? shipment.duration.toString()
                          : '-'),
                      Text(shipment.expense != null
                          ? shipment.expense.toString()
                          : '-'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget button(String title, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 30,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.secondary,
        ),
        child: Text(title),
      ),
    );
  }
}
