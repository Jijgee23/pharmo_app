// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_field_icon.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});
  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  final Map<String, String> _filters = {
    "": "Шүүлтүүр сонгох",
    "0": "Статус",
    "1": "Явц",
    "2": "Төлбөрийн хэлбэр",
    "3": "Захиалсан салбар",
    "4": "Нийлүүлэгч",
  };

  String _selectedItem = '';
  String _selectedFilter = '';
  String selected = '';
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
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getMyorders();
      if (res['errorType'] == 1) {
        // showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  getBranches() async {
    try {
      _branches[''] = '';
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getBranches();
      if (res['errorType'] == 1) {
        for (int i = 0; i < res['data'].length; i++) {
          _branches[res['data'][i]['id'].toString()] =
              res['data'][i]['name'].toString();
        }
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  getSuppliers() async {
    try {
      _suppliers[''] = '';
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.getSuppliers();
      if (res['errorType'] == 1) {
        res['data'].forEach((key, value) {
          _suppliers[key.toString()] = value.toString();
        });
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  fillDropdown() async {
    try {
      _selectedItem = '';
      _processess.clear();
      setState(() {
        if (_selectedFilter == '0') {
          _processess = {
            "": "Сонгох",
            "N": "Шинэ",
            "M": "Бэлтгэж эхэлсэн",
            "P": "Бэлэн болсон",
            "O": "Хүргэлтэнд гарсан",
            "D": "Хүргэгдсэн",
          };
        } else if (_selectedFilter == '1') {
          _processess = {
            "": "Сонгох",
            "W": "Төлбөр хүлээгдэж буй",
            "P": "Төлбөр хүлээгдсэн",
            "S": "Цуцлагдсан",
            "R": "Буцаагдсан",
            "C": "Биелсэн",
          };
        } else if (_selectedFilter == '2') {
          _processess = {
            "": "Сонгох",
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
      debugPrint(e.toString());
    }
  }

  filterOrders() async {
    try {
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res =
          await orderProvider.filterOrders(_selectedFilter, _selectedItem);
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  confirmOrder(int orderId) async {
    try {
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.confirmOrder(orderId);
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Миний захиалгууд', style: Constants.headerTextStyle),
      ),
      body: Consumer<MyOrderProvider>(
        builder: (context, provider, _) {
          final orders = (provider.orders.isNotEmpty) ? provider.orders : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //const Text('Шүүх төрлөө сонгоно уу:'),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(224, 224, 224, 1),
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            value: _selectedFilter,
                            onChanged: (String? value) async {
                              setState(() {
                                _selectedFilter = value!;
                                selected = _filters[value]!;
                              });
                              await fillDropdown();
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return _filters.keys.map<Widget>(
                                (String item) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _filters[item].toString(),
                                      style: const TextStyle(
                                          color: AppColors.main, fontSize: 14),
                                    ),
                                  );
                                },
                              ).toList();
                            },
                            items: _filters.keys
                                .map<DropdownMenuItem<String>>((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(_filters[item].toString()),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //  Text('$_selected сонгоно уу:'),
                    _selectedFilter != ''
                        ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromRGBO(
                                                224, 224, 224, 1),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: DropdownButton<String>(
                                        value: _selectedItem,
                                        underline: const SizedBox(),
                                        onChanged: (String? value) {
                                          setState(
                                              () => _selectedItem = value!);
                                        },
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return _processess.keys
                                              .map<Widget>((String item) {
                                            return Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _processess[item].toString(),
                                                style: const TextStyle(
                                                    color: AppColors.main,
                                                    fontSize: 14),
                                              ),
                                            );
                                          }).toList();
                                        },
                                        items: _processess.keys
                                            .map<DropdownMenuItem<String>>(
                                          (String item) {
                                            return DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                _processess[item].toString(),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                      ),
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
                                    backgroundColor: AppColors.main,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: orders != null && orders.isNotEmpty
                        ? Scrollbar(
                            thickness: 1,
                            child: ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                var order = orders[index];
                                return InkWell(
                                  onTap: () {
                                    print(order.process);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        )),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    margin: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Захиалгын дугаар:'),
                                                Text('Захиалгын төлөв:'),
                                                Text('Тоо ширхэг:'),
                                                Text('Нийт үнэ:'),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  orders[index]
                                                      .orderNo
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red),
                                                ),
                                                Text(
                                                    orders[index]
                                                        .status
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .mainDark)),
                                                Text(
                                                    orders[index]
                                                        .totalCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                                Text(
                                                  '${orders[index].totalPrice} ₮',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        (orders[index].process ==
                                                    'Бэлэн болсон' ||
                                                orders[index].process ==
                                                    'Түгээлтэнд гарсан')
                                            ? InkWell(
                                                onTap: () =>
                                                    provider.confirmOrder(
                                                        orders[index].id),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: AppColors.main,
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: const Center(
                                                    child: Text(
                                                      'Батлагаажуулах',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const NoResult()),
              ),
            ],
          );
        },
      ),
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
                  const SizedBox(height: 15),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хадгалах'),
                onPressed: () async {
                  if (provider.formKey.currentState!.validate()) {
                    dynamic res = await provider.addExpenseAmount(context);
                    if (res['errorType'] == 1) {
                      showSuccessMessage(
                          message: res['message'], context: context);
                      Navigator.of(context).pop();
                    } else {
                      showFailedMessage(
                          message: res['message'], context: context);
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

  Future<void> _jaggerFeedbackDialog(
      BuildContext context, String title, int shipId, int itemId) {
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
                    await provider.setFeedback(shipId, itemId, context);
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
