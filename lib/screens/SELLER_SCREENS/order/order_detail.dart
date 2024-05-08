// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/order_list.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderDetailPage extends StatefulWidget {
  final int customerId;
  final int orderId;
  const OrderDetailPage(
      {super.key, required this.customerId, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<OrderItem> orderDetails = <OrderItem>[];

  @override
  void initState() {
    getOrderListPageByCustomerId(widget.customerId, widget.orderId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Захиалгын барааны жагсаалт',
          style: TextStyle(fontSize: size.height * 0.02),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            orderDetails.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: orderDetails.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              orderDetails[index].itemName,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue),
                            ),
                            subtitle: Text(
                              'Тоо хэмжээ: ${orderDetails[index].itemQty}',
                              style: const TextStyle(color: Colors.green),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Нэгж үнэ: ${orderDetails[index].itemPrice}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                Text(
                                  'Нийт үнэ: ${orderDetails[index].itemTotalPrice}',
                                  style: const TextStyle(color: Colors.red),
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

  getOrderListPageByCustomerId(int customerId, int orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}seller/order_history/?pharmacyId=$customerId&orderId=$orderId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map orderDetList = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> orderItemList = orderDetList['items'];
        orderDetails.clear();
        setState(() {
          for (int i = 0; i < orderItemList.length; i++) {
            orderDetails.add(OrderItem.fromJson(orderItemList[i]));
          }
        });
      } else {
        showFailedMessage(message: 'Амжилтгүй боллоо.', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }
}
