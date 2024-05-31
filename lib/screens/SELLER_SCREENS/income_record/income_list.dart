// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/income_provider.dart';
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
  @override
  void initState() {
    super.initState();
    incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    incomeProvider.getIncomeList(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<IncomeProvider>(builder: (_, income, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Орлогын жагсаалт'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.add,
            color: AppColors.secondary,
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
        body: Column(
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
                        income.getIncomeListByDateRanged(context, date1, date2);
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
                  ? const Center(
                      child: Text('Хоосон'),
                    )
                  : ListView.builder(
                      itemCount: income.incomeList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              showBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return _details(income.incomeList[index]);
                                },
                              );
                            },
                            title: mText(
                                'Тайлбар: ${income.incomeList[index].note.toString()}'),
                            subtitle: mText(
                                'Дүн: ${income.incomeList[index].amount.toString()}'),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  noteController.text =
                                      income.incomeList[index].note!;
                                  amuontController.text = income
                                      .incomeList[index].amount
                                      .toString();
                                });
                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Center(
                                        child: Text('Засах'),
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
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Буцах'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            income.updateIncome(
                                                income.incomeList[index].id,
                                                noteController.text,
                                                amuontController.text,
                                                context);
                                            income.getIncomeList(context);
                                            noteController.clear();
                                            amuontController.clear();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Хадгалах'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
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

  Widget _details(Income data) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      width: double.infinity,
      height: size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mText('Тайлбар: ${data.note.toString()}'),
                mText('Дүн: ${data.amount.toString()}'),
                mText('Огноо: ${data.createdOn.toString()}'),
                mText('Хүргэлт: ${data.delman.toString()}'),
                mText('Нийлүүлэгч: ${data.supplier.toString()}'),
                mText('Харилцагч: ${data.customer.toString()}'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black),
    );
  }
}
