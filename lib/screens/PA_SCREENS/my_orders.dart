// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/screens/PA_SCREENS/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/custom_text_field_icon.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});
  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  final Map<String, String> _filters = {
    "": "",
    "0": "Статусаар шүүх",
    "1": "Явцаар шүүх",
    "2": "Төлбөрийн хэлбэрээр шүүх",
    "3": "Захиалсан салбараар шүүх",
    "4": "Нийлүүлэгчээр шүүх",
  };

  String _selectedItem = '';
  String _selectedFilter = '';
  String _selected = '';
  Map<String, String> _processess = {};
  final Map<String, String> _branches = {};
  final Map<String, String> _suppliers = {};

  @override
  void initState() {
    super.initState();
    getData();
    getBranches();
    getSuppliers();
  }

  getData() async {
    try {
      final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getMyorders();
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  getBranches() async {
    try {
      _branches[''] = '';
      final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getBranches();
      if (res['errorType'] == 1) {
        for (int i = 0; i < res['data'].length; i++) {
          _branches[res['data'][i]['id'].toString()] = res['data'][i]['name'].toString();
        }
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  getSuppliers() async {
    try {
      _suppliers[''] = '';
      final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getSuppliers();
      if (res['errorType'] == 1) {
        res['data'].forEach((key, value) {
          _suppliers[key.toString()] = value.toString();
        });
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  fillDropdown() async {
    try {
      _selectedItem = '';
      _processess.clear();
      setState(() {
        if (_selectedFilter == '0') {
          _processess = {
            "": "",
            "N": "Шинэ",
            "M": "Бэлтгэж эхэлсэн",
            "P": "Бэлэн болсон",
            "O": "Хүргэлтэнд гарсан",
            "D": "Хүргэгдсэн",
          };
        } else if (_selectedFilter == '1') {
          _processess = {
            "": "",
            "W": "Төлбөр хүлээгдэж буй",
            "P": "Төлбөр хүлээгдсэн",
            "S": "Цуцлагдсан",
            "R": "Буцаагдсан",
            "C": "Биелсэн",
          };
        } else if (_selectedFilter == '2') {
          _processess = {
            "": "",
            "C": "Бэлнээр",
            "L": "Зээлээр",
          };
        } else if (_selectedFilter == '3') {
          _processess = _branches;
        } else if (_selectedFilter == '4') {
          _processess = _suppliers;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  filterOrders() async {
    try {
      final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.filterOrders(_selectedFilter, _selectedItem);
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Миний захиалгууд',
      ),
      body: Consumer<MyOrderProvider>(builder: (context, provider, _) {
        final orders = (provider.orders.isNotEmpty) ? provider.orders : null;
        return Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: <Widget>[
                    const Text('Шүүх төрлөө сонгоно уу: '),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      onChanged: (String? value) async {
                        // setState(() => _selectedFilter = value!);
                        setState(() {
                          _selectedFilter = value!;
                          _selected = _filters[value]!;
                        });
                        await fillDropdown();
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _filters.keys.map<Widget>((String item) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _filters[item].toString(),
                              style: const TextStyle(color: Colors.blue),
                            ),
                          );
                        }).toList();
                      },
                      items: _filters.keys.map<DropdownMenuItem<String>>((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(_filters[item].toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: <Widget>[
                        Text(_selected),
                        DropdownButton<String>(
                          value: _selectedItem,
                          onChanged: (String? value) {
                            setState(() => _selectedItem = value!);
                            print(value);
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return _processess.keys.map<Widget>((String item) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _processess[item].toString(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              );
                            }).toList();
                          },
                          items: _processess.keys.map<DropdownMenuItem<String>>((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(_processess[item].toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        filterOrders();
                      },
                      icon: const Icon(
                        Icons.filter_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Шүүх',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: orders != null && orders.isNotEmpty
                  ? ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: InkWell(
                          onTap: () async => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyOrderDetail(
                                          orderId: orders[index].id,
                                        )))
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(text: 'Захиалгын дугаар : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                    TextSpan(text: orders[index].orderNo.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.red)),
                                  ]),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(text: 'Төлөв : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                      TextSpan(text: orders[index].status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.amber)),
                                    ]),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(text: 'Тоо ширхэг : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                      TextSpan(text: orders[index].totalCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                    ]),
                                  ),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(text: 'Нийт үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                      TextSpan(text: '${orders[index].totalPrice} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.red)),
                                    ]),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ));
                      })
                  : const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Түгээлтийн мэдээлэл олдсонгүй ...",
                        ),
                      ),
                    ),
            ),
          ),
        ]);
      }),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String title) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            content: SizedBox(
              height: 190,
              child: Form(
                key: provider.formKey,
                child: Column(children: [
                  CustomTextFieldIcon(
                    hintText: "Дүн оруулна уу...",
                    prefixIconData: const Icon(Icons.numbers_rounded),
                    validatorText: "Дүн оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.amount,
                    onChanged: provider.validateAmount,
                    errorText: provider.amountVal.error,
                    isNumber: true,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFieldIcon(
                    hintText: "Тайлбар оруулна уу...",
                    prefixIconData: const Icon(Icons.comment_outlined),
                    validatorText: "Тайлбар оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.note,
                    onChanged: provider.validateNote,
                    errorText: provider.noteVal.error,
                    isNumber: false,
                  ),
                ]),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хаах'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хадгалах'),
                onPressed: () async {
                  if (provider.formKey.currentState!.validate()) {
                    dynamic res = await provider.addExpenseAmount();
                    if (res['errorType'] == 1) {
                      showSuccessMessage(message: res['message'], context: context);
                      Navigator.of(context).pop();
                    } else {
                      showFailedMessage(message: res['message'], context: context);
                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _jaggerFeedbackDialog(BuildContext context, String title, int shipId, int itemId) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            content: SizedBox(
              height: 140,
              child: Form(
                key: provider.formKey,
                child: Column(children: [
                  CustomTextFieldIcon(
                    hintText: "Тайлбар оруулна уу...",
                    prefixIconData: const Icon(Icons.comment_outlined),
                    validatorText: "Тайлбар оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.feedback,
                    isNumber: false,
                    maxLine: 4,
                  ),
                ]),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хаах'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хадгалах'),
                onPressed: () async {
                  if (provider.formKey.currentState!.validate()) {
                    dynamic res = await provider.setFeedback(shipId, itemId);
                    if (res['errorType'] == 1) {
                      showSuccessMessage(message: res['message'], context: context);
                      Navigator.of(context).pop();
                    } else {
                      showFailedMessage(message: res['message'], context: context);
                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
