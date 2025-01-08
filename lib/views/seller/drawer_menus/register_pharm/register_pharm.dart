// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/address_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/views/pharmacy/index.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPharmPage extends StatefulWidget {
  const RegisterPharmPage({super.key});

  @override
  State<RegisterPharmPage> createState() => _RegisterPharmPageState();
}

class _RegisterPharmPageState extends State<RegisterPharmPage> {
  int provinceId = 0;
  int districtId = 0;
  int khorooId = 0;
  late HomeProvider homeProvider;
  late AddressProvider addressProvider;
  final TextEditingController cNameController = TextEditingController();
  final TextEditingController cRdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailedController = TextEditingController();
  final bd = BoxDecoration(
      borderRadius: BorderRadius.circular(10), color: Colors.white);

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    addressProvider = Provider.of<AddressProvider>(context, listen: false);
    addressProvider.getProvince();
    addressProvider.districts.clear();
    addressProvider.khoroos.clear();
  }

  @override
  Widget build(BuildContext context) {
    var a = const SizedBox(
      height: 10,
    );
    final style = TextStyle(fontSize: 14.0, color: Colors.grey.shade700);
    return Consumer2<HomeProvider, AddressProvider>(
      builder: (_, homeProvider, addressProvider, child) {
        return  DefaultBox(
            title: 'Эмийн сангийн бүртгэл',
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Box(
                    child: Column(
                      children: [
                        const Text(
                          'Байгууллага:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                        a,
                        CustomTextField(
                          controller: cRdController,
                          hintText: 'Байгууллагын РД',
                          validator: validateCRD,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            checkCompany(cRdController.text);
                          },
                        ),
                        a,
                        CustomTextField(
                          controller: cNameController,
                          hintText: 'Байгууллагын нэр',
                        ),
                        a,
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Имэйл хаяг',
                          validator: validateEmail,
                        ),
                        a,
                        CustomTextField(
                          controller: phoneController,
                          hintText: 'Утасны дугаар',
                          validator: validatePhone,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  Box(
                    child: Column(
                      children: [
                        const Text(
                          'Хаяг:',
                          style: TextStyle(fontSize: 16),
                        ),
                        a,
                        provinceSelection(context, addressProvider,
                            addressProvider.province, style),
                        a,
                        districtSelection(context, addressProvider,
                            addressProvider.district, style),
                        a,
                        khoroo(context, addressProvider, addressProvider.khoroo,
                            style),
                      ],
                    ),
                  ),
                  Box(
                    child: Column(
                      children: [
                        const Text(
                          'Тайлбар:',
                          style: TextStyle(fontSize: 16),
                        ),
                        a,
                        TextFormField(
                          onChanged: (value) {
                            homeProvider.detail = detailedController.text;
                          },
                          minLines: 1,
                          controller: detailedController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            labelText: 'Тайлбар',
                            labelStyle: style,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  a,
                  CustomButton(
                    text: 'Бүртгэх',
                    ontap: () {
                      if (emailController.text.isEmpty ||
                          cNameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          detailedController.text.isEmpty ||
                          provinceId == 0 ||
                          districtId == 0 ||
                          khorooId == 0) {
                        message(
                            'Бүртгэлийн хэсгийг гүйцээнэ үү!',
                           );
                      } else {
                        registerPharm(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        
      },
    );
  }

  provinceSelection(BuildContext context, AddressProvider addressProvider,
      String text, TextStyle style) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              decoration: bd,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: addressProvider.provinces
                      .map((e) => InkWell(
                            onTap: () {
                              addressProvider.getDistrictId(e.id, context);
                              addressProvider.setProvince(e.name);
                              addressProvider.setProvinceId(e.id);
                              Navigator.pop(context);
                              setState(() => provinceId = e.id);
                            },
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(e.name)),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: style),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }

  districtSelection(BuildContext context, AddressProvider addressProvider,
      String text, TextStyle style) {
    return GestureDetector(
      onTap: () {
        if (addressProvider.selectedProvince == 0) {
          message('Аймаг/Хот сонгоно уу.');
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  decoration: bd,
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: addressProvider.districts
                          .map((e) => InkWell(
                                onTap: () {
                                  addressProvider.getKhoroo(e.id, context);
                                  addressProvider.setDistrict(e.ner);
                                  addressProvider.setDistrictId(e.id);
                                  setState(() => districtId = e.id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Text(e.ner)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: style),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }

  khoroo(BuildContext context, AddressProvider addressProvider, String text,
      TextStyle style) {
    return GestureDetector(
      onTap: () {
        if (addressProvider.selectedDistrict == 0) {
          message('Сум/Дүүрэг сонгоно уу.');
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  decoration: bd,
                  child: SingleChildScrollView(
                    child: Column(
                      children: addressProvider.khoroos
                          .map((e) => InkWell(
                                onTap: () {
                                  addressProvider.setKhoroo(e.ner);
                                  addressProvider.setKhorooId(e.id);
                                  setState(() => khorooId = e.id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Text(e.ner)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: style),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }

  registerPharm(BuildContext context) async {
    try {
      // print('lat: ${homeProvider.currentLatitude}');
      // print('lon: ${homeProvider.currentLongitude}');
      // print('provinceId: $provinceId');
      // print('districtId: $districtId');
      // print('khorooId: $khorooId');
      // print('cNameController.text: ${cNameController.text}');
      // print('cRdController.text: ${cRdController.text}');
      // print('emailController.text: ${emailController.text}');
      // print('phoneController.text: ${phoneController.text}');
      // print('detailedController.text: ${detailedController.text}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}seller/reg_pharmacy/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, dynamic>{
            'cName': cNameController.text,
            'cRd': cRdController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'address': {
              'province': provinceId,
              'district': districtId,
              'khoroo': khorooId,
              'detailed': detailedController.text,
            },
            'lat': homeProvider.currentLatitude,
            'lon': homeProvider.currentLongitude,
          },
        ),
      );
      if (response.statusCode == 200) {
        var res = jsonDecode(utf8.decode(response.bodyBytes));
        homeProvider.selectedCustomerId = res['user'];
        homeProvider.selectedCustomerName = res['cName'];
        homeProvider.getSelectedUser(
            homeProvider.selectedCustomerId, homeProvider.selectedCustomerName);
        message('Амжилттай бүртгэгдлээ.');
        goto(const IndexPharma());
      } else {
        // showFailedMessage('Бүртгэл амжилтгүй.');
      }
    } catch (e) {
      //showFailedMessage('Алдаа гарлаа.');
    }
  }

  checkCompany(String? cRd) async {
    try {
      final response = await http.get(
        Uri.parse('https://info.ebarimt.mn/rest/merchant/info?regno=$cRd'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          cNameController.text = res['name'];
        });
      }
    } catch (e) {
      message('Интернет холболтоо шалгана уу!');
    }
  }
}
