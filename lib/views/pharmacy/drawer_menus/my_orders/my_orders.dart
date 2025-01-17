import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_order_detail.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/ui_help/container.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/ui_help/col.dart';

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

  getOrders() async {
    final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    await orderProvider.getMyorders();
    await getBranches();
    await getSuppliers();
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
        message(
          res['message'],
        );
      }
    } catch (e) {
      message(
        'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
      );
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
        message(
          res['message'],
        );
      }
    } catch (e) {
      message(
        'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
      );
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
    final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    await orderProvider.filterOrders(_selectedFilter, _selectedItem);
  }

  confirmOrder(int orderId) async {
    final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    dynamic res = await orderProvider.confirmOrder(orderId);
    print(res['message']);
    message(res['message']);
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, _) {
        final orders = (provider.orders.isNotEmpty) ? provider.orders : null;
        return Scaffold(
          appBar: AppBar(
            leading: const ChevronBack(),
            title: appBarTitle(),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: Sizes.smallFontSize / 2,
                right: Sizes.smallFontSize / 2,
                left: Sizes.smallFontSize / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                orders != null && orders.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async => getOrders(),
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
                    : const NoResult(),
              ],
            ),
          ),
        );
      },
    );
  }

  Row appBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        dropContainer(
          child: DropdownButton<String>(
            style: filterStyle(),
            isDense: true,
            padding: EdgeInsets.symmetric(vertical: Sizes.smallFontSize),
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
                      child: filterText(_filters[item].toString()));
                },
              ).toList();
            },
            items: _filters.keys.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: filterText(_filters[item].toString()),
              );
            }).toList(),
          ),
        ),
        if (_selectedFilter != '')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              dropContainer(
                child: DropdownButton<String>(
                  isDense: true,
                  padding: EdgeInsets.symmetric(vertical: Sizes.smallFontSize),
                  style: filterStyle(),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  value: _selectedItem,
                  underline: const SizedBox(),
                  onChanged: (String? value) {
                    setState(() => _selectedItem = value!);
                    filterOrders();
                  },
                  items: _processess.keys.map<DropdownMenuItem<String>>(
                    (String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: filterText(_processess[item].toString()),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget filterText(String text) {
    return Text(
      text,
      style: filterStyle(),
    );
  }

  TextStyle filterStyle() {
    return TextStyle(
      fontSize: Sizes.smallFontSize + 1,
      color: theme.colorScheme.onPrimary,
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
      ),
      child: Ctnr(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleContainer(
                    child: Col(t1: 'Дугаар', t2: order.orderNo.toString())),
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
                    onTap: () => confirmOrder(order.id),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: const Center(
                            child: Row(
                              children: [
                                Text(
                                  'Хүлээн авсан',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: Sizes.smallFontSize,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: Sizes.smallFontSize),
                                Icon(Icons.check,
                                    color: white, size: Sizes.mediumFontSize)
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
      width: Sizes.width * 0.375,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(Sizes.smallFontSize),
      ),
      padding:const EdgeInsets.symmetric(horizontal: Sizes.smallFontSize),
      child: Center(child: child),
    );
  }
}
