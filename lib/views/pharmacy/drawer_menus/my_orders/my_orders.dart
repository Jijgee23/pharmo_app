// ignore_for_file: use_build_conte
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_order_detail.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/defaultBox.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/col.dart';

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
      backgroundColor: AppColors.primary,
      body: Consumer<MyOrderProvider>(
        builder: (context, provider, _) {
          final orders = (provider.orders.isNotEmpty) ? provider.orders : null;
          return DefaultBox(
            title: 'Захиалгууд',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Box(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dropContainer(
                        child: DropdownButton<String>(
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                                        color: AppColors.primary, fontSize: 14),
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
                      const SizedBox(
                        height: 10,
                      ),
                      _selectedFilter != ''
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    dropContainer(
                                      child: DropdownButton<String>(
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.primary),
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        value: _selectedItem,
                                        underline: const SizedBox(),
                                        onChanged: (String? value) {
                                          setState(
                                              () => _selectedItem = value!);
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
                                InkWell(
                                  onTap: () => filterOrders(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12.5),
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        'Шүүх',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: Box(
                      // margin: const EdgeInsets.symmetric(
                      //     horizontal: 10, vertical: 10),
                      child: orders != null && orders.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: () async {
                                getData();
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  children: orders
                                      .map(
                                        (order) => orderWidget(
                                            order: order, provider: provider),
                                      )
                                      .toList(),
                                ),
                              ),
                            )
                          : const NoResult()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget orderWidget(
      {required MyOrderModel order, required MyOrderProvider provider}) {
    return InkWell(
      onTap: () => goto(
          MyOrderDetail(
            id: order.id,
            order: order,
            orderNo: order.orderNo.toString(),
            process: getProcessNumber(order.process!),
          ),
          context),
      child: Box(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Col(t1: 'Дугаар', t2: order.orderNo.toString()),
                Col(t1: 'Дүн', t2: toPrice(order.totalPrice.toString())),
                Col(
                    t1: 'Огноо',
                    t2: order.createdOn.toString().substring(0, 10))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Төлөв',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      order.status!,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            (order.process == 'Бэлэн болсон' ||
                    order.process == 'Түгээлтэнд гарсан')
                ? InkWell(
                    onTap: () {
                      provider
                          .confirmOrder(order.id, context)
                          .then((e) => getData());
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: const Center(
                            child: Row(
                              children: [
                                Text(
                                  'Батлагаажуулах',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  dropContainer({required Widget child}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            boxShadow: [Constants.defaultShadow],
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: child);
  }
}
