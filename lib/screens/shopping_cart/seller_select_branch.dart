import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectSellerBranchPage extends StatefulWidget {
  const SelectSellerBranchPage({super.key});
  @override
  State<SelectSellerBranchPage> createState() => _SelectSellerBranchPageState();
}

class _SelectSellerBranchPageState extends State<SelectSellerBranchPage> {
  List<Branch> sellerBranchList = <Branch>[];
  String _selectedRadioValue = '';
  int _selectedIndex = -1;
  int _selectedAddress = 0;
  String? _basketId = '';
  String? customerID = '';

  @override
  void initState() {
    getCustomerBranch();
    getBasketId();
    super.initState();
  }

  getBasketId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('http://192.168.88.39:8000/api/v1/get_basket/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      setState(() {
        _basketId = res['id'].toString();
      });
    }
  }

  getCustomerBranch() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      String? customerId = prefs.getString('customerId');
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'customerId': customerId}));
      sellerBranchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          customerID = customerId;
          for (int i = 0; i < res.length; i++) {
            sellerBranchList.add(Branch.fromJson(res[i]));
          }
        });
        await prefs.setInt('branchId', res[0]['id']);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа.', context: context);
    }
  }

  createSellerOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      String? customerId = prefs.getString('customerId');
      setState(() {
        customerID = customerId;
      });
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/seller/order/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            'user': customerId,
            'address': _selectedAddress,
            'basket': _basketId,
          },
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        showSuccessMessage(
            message: 'Захиалга амжилттай  үүслээ.', context: context);
      } else {
        showFailedMessage(
            message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {}),
        appBar: const CustomAppBar(
          title: 'Төлбөрийн хэлбэр',
        ),
        body: Container(
          margin: const EdgeInsets.all(15),
          child: Column(children: [
            Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Салбар сонгоно уу : '))),
            Expanded(
              child: ListView.builder(
                itemCount: sellerBranchList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          _selectedAddress = sellerBranchList[index].id;
                          print(_selectedAddress);
                        });
                      },
                      tileColor: _selectedIndex == index ? Colors.grey : null,
                      leading: const Icon(Icons.home),
                      title: Text(sellerBranchList[index].name.toString()),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Column(children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Төлбөрийн хэлбэр сонгоно уу : ')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'L',
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Бэлнээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Radio(
                        value: 'C',
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Зээлээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(
                onPressed: () {
                  if (_selectedIndex == -1) {
                    showFailedMessage(
                        message: 'Салбар сонгоно уу.', context: context);
                  } else {
                    createSellerOrder();
                  }
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  'Захиалга үүсгэх',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
