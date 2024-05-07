import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/orderList.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/order_detail.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderhistoryListPage extends StatefulWidget {
  final int customerId;
  const OrderhistoryListPage({super.key, required this.customerId});

  @override
  State<OrderhistoryListPage> createState() => _OrderhistoryListPageState();
}

class _OrderhistoryListPageState extends State<OrderhistoryListPage> {
  List<OrderList> orderList = <OrderList>[];

  @override
  void initState() {
    getOrderListPageByCustomerId(widget.customerId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Захиалгын түүхүүд'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            orderList.isEmpty
                ? Center(
                    child: SizedBox(
                      width: size.width * 0.8,
                      child: const Text(
                        'Тухайн харилцагчийн захиалгийн жагсаалт хоосон байна.',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              goto(
                                  OrderDetailPage(
                                    customerId: widget.customerId,
                                    orderId: orderList[index].id,
                                  ),
                                  context);
                            },
                            title: Text(
                                'ЗД: ${orderList[index].orderNo.toString()}'),
                            subtitle: Text(
                                'Нийт дүн: ${orderList[index].totalPrice}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Нийт барааны тоо: ${orderList[index].totalCount}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                Text(
                                  'Огноо: ${orderList[index].createdOn}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  getOrderListPageByCustomerId(int customerId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.39:8000/api/v1/seller/order_history/?pharmacyId=$customerId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> ordList = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          for (int i = 0; i < ordList.length; i++) {
            orderList.add(OrderList.fromJson((ordList[i])));
          }
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }
}
