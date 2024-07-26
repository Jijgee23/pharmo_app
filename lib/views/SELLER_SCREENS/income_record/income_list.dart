// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class IncomeList extends StatefulWidget {
  const IncomeList({super.key});

  @override
  State<IncomeList> createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {
  TextEditingController noteController = TextEditingController();
  TextEditingController amuontController = TextEditingController();
  late IncomeProvider incomeProvider;
  String date1 = DateTime.now().toString().substring(0, 10);
  String date2 = DateTime.now().toString().substring(0, 10);
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  bool invisible = false;
  @override
  void initState() {
    super.initState();
    incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    incomeProvider.getIncomeList(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<IncomeProvider>(
      builder: (_, income, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              title: const Text('Орлогын жагсаалт'),
              centerTitle: true,
              leading: const ChevronBack()),
          floatingActionButton: invisible
              ? const SizedBox()
              : FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  child: Image.asset(
                    'assets/icons/wallet.png',
                  ),
                  onPressed: () {
                    amuontController.clear();
                    noteController.clear();
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(
                            child: Text('Орлого бүртгэх'),
                          ),
                          content: SizedBox(
                            height: size.height * 0.2,
                            child: Column(
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Тайлбар',
                                  ),
                                  controller: noteController,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: amuontController,
                                  decoration: const InputDecoration(
                                    hintText: 'Дүн',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Цуцлах'),
                            ),
                            TextButton(
                              onPressed: () {
                                income.recordIncome(noteController.text,
                                    amuontController.text, context);
                                income.getIncomeList(context);
                                noteController.clear();
                                amuontController.clear();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Бүртгэх'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                setState(() {
                  invisible = true;
                });
              } else if (notification.direction == ScrollDirection.forward) {
                setState(() {
                  invisible = false;
                });
              }
              return true;
            },
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Text(date1,
                            style: const TextStyle(color: AppColors.primary)),
                      ),
                      const Icon(Icons.arrow_right_alt),
                      TextButton(
                        onPressed: () {
                          _selectDate2(context);
                        },
                        child: Text(date2,
                            style: const TextStyle(color: AppColors.primary)),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (date1 == date2) {
                            income.getIncomeListByDateSinlge(context, date1);
                          } else {
                            income.getIncomeListByDateRanged(
                                context, date1, date2);
                          }
                        },
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(AppColors.primary)),
                        child: const Text(
                          'Шүүх',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: income.incomeList.isEmpty
                      ? const NoResult()
                      : ListView.builder(
                          itemCount: income.incomeList.length,
                          itemBuilder: (context, index) {
                            final incomee = income.incomeList[index];
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade700),
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              child: ExpansionTile(
                                childrenPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                iconColor: AppColors.primary,
                                title: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          noteController.text = incomee.note!;
                                          amuontController.text =
                                              incomee.amount.toString();
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return editDialog(
                                                size, context, income, index);
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.green,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        mText(
                                            'Тайлбар: ${incomee.note.toString()}'),
                                        mText(
                                            'Дүн: ${incomee.amount.toString()}'),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  Column(
                                    children: [
                                      _infoRow(
                                          'Огноо',
                                          incomee.createdOn != null
                                              ? incomee.createdOn.toString()
                                              : '-'),
                                      _infoRow(
                                          'Хүргэлт',
                                          incomee.delman != null
                                              ? incomee.delman.toString()
                                              : '-'),
                                      _infoRow(
                                          'Нийлүүлэгч',
                                          incomee.supplier != null
                                              ? incomee.supplier.toString()
                                              : '-'),
                                      _infoRow(
                                          'Харилцагч',
                                          incomee.customer != null
                                              ? incomee.customer.toString()
                                              : '-'),
                                    ],
                                  ),
                                ],
                              ),
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

  Dialog editDialog(
      Size size, BuildContext context, IncomeProvider income, int index) {
    var decoration = const InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      hintStyle: TextStyle(fontSize: 14),
    );
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        height: size.height > 480 ? size.height * 0.34 : size.height * 0.3,
        width: 300,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Center(
              child: Text(
                'Шинэчлэх',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextField(
              controller: noteController,
              decoration: decoration,
            ),
            TextFormField(
                controller: amuontController,
                keyboardType: TextInputType.number,
                decoration: decoration),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                dialogButton(context, 'Буцах', Navigator.of(context).pop),
                dialogButton(
                  context,
                  'Хадгалах',
                  () {
                    income.updateIncome(income.incomeList[index].id,
                        noteController.text, amuontController.text, context);
                    income.getIncomeList(context);
                    noteController.clear();
                    amuontController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  dialogButton(BuildContext context, String title, VoidCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade700,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Text(title)),
      ),
    );
  }

  _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        mText(title),
        mText(
          value,
        ),
      ],
    );
  }

  _selectDate(BuildContext context) async {
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
        date1 = picked.toString().substring(0, 10);
        selectedDate = picked;
      });
    }
  }

  _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Огноо сонгох',
      cancelText: 'Буцах',
      confirmText: "Сонгох",
      initialDate: selectedDate2,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate2) {
      setState(() {
        date2 = picked.toString().substring(0, 10);
        selectedDate2 = picked;
      });
    }
  }

  Widget mText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
    );
  }
}

