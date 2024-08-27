// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/qr_code.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectBranchPage extends StatefulWidget {
  const SelectBranchPage({super.key});
  @override
  State<SelectBranchPage> createState() => _SelectBranchPageState();
}

class _SelectBranchPageState extends State<SelectBranchPage> {
  List<Sector> _branchList = <Sector>[];
  String _selectedRadioValue = '';
  int _selectedIndex = -1;
  int _selectedAddress = 0;
  final radioColor = const MaterialStatePropertyAll(AppColors.primary);
  late HomeProvider homeProvider;

  @override
  void initState() {
    getData();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
  }

  void getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}branch'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': bearerToken,
          });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _branchList = (res).map((data) => Sector.fromJson(data)).toList();
        });
      } else {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  void createOrder() async {
    try {
      if (_selectedRadioValue == '') {
        showFailedMessage(
            message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
        return;
      }
      if (_selectedIndex == -1) {
        showFailedMessage(message: 'Салбар сонгоно уу!', context: context);
        return;
      }
      final basketProvider =
          Provider.of<BasketProvider>(context, listen: false);
      dynamic resCheck = await basketProvider.checkQTYs();
      if (resCheck['errorType'] == 1) {
        if (_selectedRadioValue == 'L') {
          dynamic res = await basketProvider.createQR(
              basket_id: basketProvider.basket.id,
              branch_id: _selectedAddress,
              pay_type: _selectedRadioValue,
              note: '');
          if (res['errorType'] == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const QRCode()));
          } else {
            showFailedMessage(message: res['message'], context: context);
          }
        } else {
          dynamic res = await basketProvider.createOrder(
              basket_id: basketProvider.basket.id,
              branch_id: _selectedAddress,
              note: '');
          if (res['errorType'] == 1) {
            String order = res['data']['orderNo'].toString();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => OrderDone(orderNo: order)));
          } else {
            showFailedMessage(message: res['message'], context: context);
          }
        }
      } else {
        showFailedMessage(message: resCheck['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var bd = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey),
    );
    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Төлбөрийн хэлбэр'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(children: [
            Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Салбар сонгоно уу : '))),
            Expanded(
              child: ListView.builder(
                  itemCount: _branchList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: bd,
                      child: ListTile(
                        onTap: () async {
                          setState(() {
                            _selectedIndex = index;
                            _selectedAddress = _branchList[index].id;
                          });
                        },
                        leading: Icon(
                          Icons.home,
                          color: _selectedIndex == index
                              ? AppColors.succesColor
                              : AppColors.primary,
                        ),
                        title: Text(_branchList[index].name.toString()),
                        subtitle: Text(_branchList[index].address != null
                            ? _branchList[index].address!["address"]
                            : ''),
                      ),
                    );
                  }),
            ),
            Container(
              decoration: bd,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Төлбөрийн хэлбэр сонгоно уу : ')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: 'L',
                      fillColor: radioColor,
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
                      fillColor: radioColor,
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
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(
                onPressed: () {
                  createOrder();
                },
                icon: Image.asset(
                  'assets/icons/checkout.png',
                  height: 24,
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
