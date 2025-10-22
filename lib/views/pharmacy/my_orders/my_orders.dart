import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/pharmacy/my_orders/custom_drop.dart';
import 'package:pharmo_app/views/pharmacy/my_orders/order_widget.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});
  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  refresh() async {
    final order = context.read<MyOrderProvider>();
    await order.getBranches();
    await order.getSuppliers();
    await order.getMyorders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, _) {
        final orders = provider.orders;
        return DataScreen(
          empty: false,
          loading: false,
          onRefresh: () async => refresh(),
          appbar: SideAppBar(text: 'Захиалгууд'),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: white,
                surfaceTintColor: white,
                flexibleSpace: FlexibleSpaceBar(title: filterRow()),
              ),
            ],
            body: ListView.separated(
              itemBuilder: (_, idx) {
                if (orders.isEmpty) {
                  return NoResult();
                }
                return OrderWidget(order: orders[idx]);
              },
              separatorBuilder: (_, idx) => SizedBox(height: 10),
              itemCount: orders.isNotEmpty ? orders.length : 1,
            ),
          ),
        );
      },
    );
  }

  String status = '';
  Map<String, String> statuses = {
    "": "Төлөв",
    "N": "Шинэ",
    "M": "Бэлтгэж эхэлсэн",
    "P": "Бэлэн болсон",
    "O": "Хүргэлтэнд гарсан",
    "A": "Хүргэгдсэн",
  };
  MapEntry<String, String> s = MapEntry("", "Төлөв");
  String process = '';
  Map<String, String> processess = {
    "": "Явц",
    "W": "Төлбөр хүлээгдэж буй",
    "P": "Төлбөр төлөгдсөн",
    "S": "Цуцлагдсан",
    "R": "Буцаагдсан",
    "C": "Биелсэн",
  };
  String payType = '';
  Map<String, String> payTypes = {
    "": "Төлбөрийн хэлбэр",
    "C": "Бэлнээр",
    "L": "Зээлээр",
  };

  Branch branch = Branch(id: -1, name: 'Салбар сонгох');
  Supplier supplier = Supplier(id: -1, name: 'Нийлүүлэгч сонгох', stocks: []);
  Widget filterRow() {
    final order = context.read<MyOrderProvider>();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomDropdown<String>(
              items: statuses.keys.toList(),
              getLabel: (String key) => statuses[key] ?? '',
              value: status,
              onChanged: (String? newValue) async {
                setState(() {
                  status = newValue ?? '';
                });
                await order.filterOrders('0', process);
              },
              text: statuses[status] ?? 'Явц',
            ),
            CustomDropdown<String>(
              items: processess.keys.toList(),
              getLabel: (String key) => processess[key] ?? '',
              value: process,
              onChanged: (String? newValue) async {
                setState(() {
                  process = newValue ?? '';
                });
                await order.filterOrders('1', process);
              },
              text: processess[process] ?? 'Явц',
            ),
            CustomDropdown<String>(
              items: payTypes.keys.toList(),
              getLabel: (String key) => payTypes[key] ?? '',
              value: payType,
              onChanged: (String? newValue) async {
                setState(() {
                  payType = newValue ?? '';
                });
                await order.filterOrders('2', payType);
              },
              text: payTypes[process] ?? 'Явц',
            ),
            CustomDropdown<Branch>(
              items: order.branches,
              getLabel: (Branch s) => s.name,
              value: order.branches.isNotEmpty
                  ? order.branches.firstWhere(
                      (b) => b.id == branch.id,
                      orElse: () => order.branches.first,
                    )
                  : Branch(id: -1, name: 'Салбар сонгох'),
              onChanged: (Branch? value) async {
                setState(() {
                  branch = value!;
                });
                await order.filterOrders('3', value!.id.toString());
              },
              text: branch.name,
            ),
            CustomDropdown<Supplier>(
              items: order.suppliers,
              getLabel: (Supplier s) => s.name,
              value: order.suppliers.isNotEmpty
                  ? order.suppliers.firstWhere(
                      (b) => b.id == supplier.id,
                      orElse: () => order.suppliers.first,
                    )
                  : Supplier(
                      id: -1,
                      name: 'Нийлүүлэгч сонгох',
                      stocks: [],
                    ),
              onChanged: (Supplier? value) async {
                setState(() {
                  supplier = value!;
                });
                await order.filterOrders('4', value!.id.toString());
              },
              text: supplier.name,
            ),
          ],
        ),
      ),
    );
  }
}
