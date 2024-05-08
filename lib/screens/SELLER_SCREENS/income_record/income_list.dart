// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/income.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IncomeList extends StatefulWidget {
  const IncomeList({super.key});

  @override
  State<IncomeList> createState() => _IncomeListState();
}

class _IncomeListState extends State<IncomeList> {
  String firstDate = DateTime.now().toString().substring(0, 10);
  TextEditingController noteController = TextEditingController();
  TextEditingController amuontController = TextEditingController();
  List<Income> displayList = <Income>[];
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
                        recordIncome();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Бүртгэх'),
                    ),
                  ],
                );
              },
            );
          }),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _datePicker();
                      },
                    );
                  },
                  child: Text(firstDate),
                ),
                DropdownButton(
                  hint: const Text('Шүүх'),
                  items: [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('$firstDate-ны өдрийн'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('$firstDate-ны өдрөөс өмнө'),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text('$firstDate-ны өдрөөс хойш'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == '1') {
                      filter('createdOn__date', firstDate);
                    }
                    if (value == '2') {
                      filter('createdOn__date__lt', firstDate);
                    }
                    if (value == '3') {
                      filter('createdOn__date__gt', firstDate);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: displayList.isEmpty
                ? const Center(
                    child: Text('Хоосон'),
                  )
                : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: AppColors.secondary,
                        child: ListTile(
                          onTap: () {
                            showBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return _details(displayList[index]);
                              },
                            );
                          },
                          title: mText(
                              'Тайлбар: ${displayList[index].note.toString()}'),
                          subtitle: mText(
                              'Дүн: ${displayList[index].amount.toString()}'),
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
                                          updateIncome(displayList[index].id);
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
          ),
        ],
      ),
    );
  }

  Widget _datePicker() {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.8,
      height: size.height * 0.8,
      child: Card(
          child: Column(
        children: [
          Expanded(
            child: AppBar(
              title: const Text('Сонгох'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.check,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: CalendarDatePicker2(
              onDisplayedMonthChanged: (value) {},
              config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single),
              value:const [],
              onValueChanged: (value) {
                setState(() {
                  firstDate = value.toString().substring(1, 11);
                });
              },
            ),
          ),
        ],
      )),
    );
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

  getIncomeList() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> resList = res['results'];
        displayList.clear();
        setState(() {
          displayList = resList.map((item) => Income.fromJson(item)).toList();
        });
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  filter(String type, String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/?$type=$date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> resList = res['results'];
        displayList.clear();
        setState(() {
          displayList = resList.map((item) => Income.fromJson(item)).toList();
        });
      } else {
        showFailedMessage(
            context: context, message: 'Интернет холболтоо шалгана уу!');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Серверийн алдаа');
    }
  }

  recordIncome() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'note': noteController.text,
          'amount': amuontController.text,
        }),
      );
      if (response.statusCode == 201) {
        showSuccessMessage(context: context, message: 'Амжилттай бүртгэгдлээ');
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
        Uri.parse('${dotenv.env['SERVER_URL']}income_record/$id/'),
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
      if (response.statusCode == 200) {
        showSuccessMessage(context: context, message: 'Амжилттай');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }
}
