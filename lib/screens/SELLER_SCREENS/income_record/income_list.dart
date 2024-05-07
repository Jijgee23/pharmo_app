// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IncomeList extends StatefulWidget {
  const IncomeList({super.key});

  @override
  State<IncomeList> createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {
  TextEditingController noteController = TextEditingController();
  TextEditingController amuontController = TextEditingController();
  List<MyData> incomeList = <MyData>[];
  getIncomeList() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.get(
        Uri.parse('http://192.168.88.39:8000/api/v1/income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> resList = res['results'];
        setState(() {
          incomeList = resList.map((item) => MyData.fromJson(item)).toList();
        });
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  updateIncome(int id) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.patch(
        Uri.parse('http://192.168.88.39:8000/api/v1/income_record/$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'note': noteController.text,
            'amount': amuontController.text,
          },
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        showSuccessMessage(context: context, message: 'Амжилттай');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  @override
  void initState() {
    getIncomeList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Орлогын жагсаалт'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: incomeList.length,
        itemBuilder: (context, index) {
          return Card(
            color: AppColors.secondary,
            child: ListTile(
              onTap: () {
                showBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return _details(incomeList[index]);
                  },
                );
              },
              title: mText('Тайлбар: ${incomeList[index].note.toString()}'),
              subtitle: mText('Дүн: ${incomeList[index].amount.toString()}'),
              trailing: IconButton(
                onPressed: () {
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
                            child: const Text('Буцах'),
                          ),
                          TextButton(
                            onPressed: () {
                              updateIncome(incomeList[index].id);
                              Navigator.of(context).pop();
                              initState();
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
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _details(MyData data) {
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
                mText('Дугаар: ${data.id.toString()}'),
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
      style: const TextStyle(color: Colors.white),
    );
  }
}

class MyData {
  final int id;
  final String? note;
  final double amount;
  final DateTime createdOn;
  final int delman;
  final int? customer;
  final int supplier;

  MyData({
    required this.id,
    this.note,
    required this.amount,
    required this.createdOn,
    required this.delman,
    this.customer,
    required this.supplier,
  });

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      id: json['id'],
      note: json['note'],
      amount: json['amount']?.toDouble() ?? 0.0,
      createdOn: DateTime.parse(json['createdOn']),
      delman: json['delman'],
      customer: json['customer'],
      supplier: json['supplier'],
    );
  }
}
