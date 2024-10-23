// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/box.dart';
import 'package:pharmo_app/widgets/defaultBox.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
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

  incomeRecoord({required BuildContext contenxt}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Орлого бүртгэх',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: 'Тайлбар',
                    controller: noteController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: amuontController,
                    hintText: 'Дүн',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      button(
                          title: 'Цуцлах', ontap: () => Navigator.pop(context)),
                      button(
                        title: 'Бүртгэх',
                        ontap: () {
                          Future(() {
                            incomeProvider.recordIncome(noteController.text,
                                amuontController.text, context);
                          }).whenComplete(() {
                            incomeProvider.getIncomeList(context);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  button({required String title, required GestureTapCallback ontap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: ontap,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomeProvider>(
      builder: (_, income, child) {
        final incomes = income.incomeList;
        return Scaffold(
          // resizeToAvoidBottomInset: false,
          // appBar: const SideMenuAppbar(title: 'Орлогын жагсаалт'),
          backgroundColor: AppColors.primary,
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
                    incomeRecoord(contenxt: context);
                  },
                ),
          body: DefaultBox(
            title: 'Орлогын жагсаалт',
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Box(
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
                                  WidgetStatePropertyAll(AppColors.primary)),
                          child: const Text(
                            'Шүүх',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  income.incomeList.isEmpty
                      ? const NoResult()
                      : Box(
                          child: SingleChildScrollView(
                            child: Column(
                              children: incomes
                                  .map((i) => IncomeWidget(
                                        income: i,
                                        ontap: () {
                                          setState(() {
                                            noteController.text = i.note!;
                                            amuontController.text =
                                                i.amount.toString();
                                          });
                                          editDialog(context, income, i.id);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  editDialog(BuildContext context, IncomeProvider income, int id) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Орлого засах',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: noteController,
                      hintText: 'Тайлбар',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                        controller: amuontController,
                        keyboardType: TextInputType.number,
                        hintText: 'Дүн'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        button(
                            title: 'Цуцлах',
                            ontap: () => Navigator.pop(context)),
                        button(
                            title: 'Засах',
                            ontap: () {
                              Future(() {
                                income.updateIncome(id, noteController.text,
                                    amuontController.text, context);
                              }).whenComplete(() {
                                income.getIncomeList(context);
                                noteController.clear();
                                amuontController.clear();
                                Navigator.of(context).pop();
                              });
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

class IncomeWidget extends StatefulWidget {
  final Income income;
  final Function() ontap;
  const IncomeWidget({super.key, required this.income, required this.ontap});

  @override
  State<IncomeWidget> createState() => _IncomeWidgetState();
}

class _IncomeWidgetState extends State<IncomeWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() {
        expanded = !expanded;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // Animation duration
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [Constants.defaultShadow],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.income.note.toString(),
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.secondary)),
                Icon(
                  expanded
                      ? Icons.arrow_drop_up_rounded // Icon changes on toggle
                      : Icons.arrow_drop_down_rounded,
                ),
              ],
            ),
            row(title: 'Үнэ', value: widget.income.amount.toString()),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeInOut,
              child: expanded
                  ? Column(
                      key: const ValueKey(1),
                      children: [
                        row(
                            title: 'Огноо',
                            value: widget.income.createdOn.toString()),
                        row(
                            title: 'Нийлүүлэгч',
                            value: widget.income.supplier.toString()),
                        row(
                            title: 'Харилцагч',
                            value: widget.income.customer.toString()),
                        row(
                            title: 'Хүргэлт',
                            value: widget.income.delman.toString()),
                      ],
                    )
                  : const SizedBox(key: ValueKey(0)),
            ),
            InkWell(
              onTap: widget.ontap,
              child: const Text('Засах',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  row({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}
