// ignore_for_file: use_build_conte
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
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
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(
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
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(
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
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(
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
            "P": "Төлбөр төлөгдсөн",
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
        message(message: res['message'], context: context);
      } else {
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  confirmOrder(int orderId) async {
    try {
      final orderProvider =
          Provider.of<MyOrderProvider>(context, listen: false);
      dynamic res = await orderProvider.confirmOrder(orderId, context);
      if (res['errorType'] == 1) {
        message(message: res['message'], context: context);
      } else {
        message(message: res['message'], context: context);
      }
    } catch (e) {
      message(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SideMenuAppbar(title: 'Миний захиалгууд'),
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
                        ? RefreshIndicator(
                            onRefresh: () async {
                              getData();
                            },
                            child: Scrollbar(
                              thickness: 1,
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade700,
                                            blurRadius: 5,
                                          )
                                        ]),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
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
                                                onTap: () {
                                                  provider
                                                      .confirmOrder(
                                                          orders[index].id,
                                                          context)
                                                      .then((e) => getData());
                                                },
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
                                  );
                                },
                              ),
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
}
