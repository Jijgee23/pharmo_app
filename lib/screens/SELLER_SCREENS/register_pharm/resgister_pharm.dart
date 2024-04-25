import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/address.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class RegisterPharm extends StatefulWidget {
  const RegisterPharm({super.key});

  @override
  State<RegisterPharm> createState() => _RegisterPharmState();
}

class _RegisterPharmState extends State<RegisterPharm> {
  List<Province> provinceList = [];
  List<District> districtList = [];
  List<Khoroo> khorooList = [];
  List<String> names = [];

  late TextEditingController cNameController,
      cRdController,
      emailController,
      phoneController,
      detailedController;

  @override
  void initState() {
    getProvinceId();
    cNameController = TextEditingController();
    cRdController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    detailedController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose your controllers when they are no longer needed
    cNameController.dispose();
    cRdController.dispose();
    emailController.dispose();
    phoneController.dispose();
    detailedController.dispose();
    super.dispose();
  }

  getProvinceId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('http://192.168.88.39:8000/api/v1/aimag_hot/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      List res = jsonDecode(utf8.decode(response.bodyBytes));
      provinceList.clear();
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          for (int i = 0; i < res.length; i++) {
            provinceList.add(Province(id: res[i]['id'], name: res[i]['ner']));
            print(provinceList[i].name);
          }
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  getDistrictId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.39:8000/api/v1/sum_duureg/?aimag=$provinceId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      List res = jsonDecode(utf8.decode(response.bodyBytes));
      districtList.clear();
      if (response.statusCode == 200) {
        setState(() {
          for (int i = 0; i < res.length; i++) {
            districtList.add(District(
                id: res[i]['id'], ner: res[i]['ner'], aimag: res[i]['aimag']));
          }
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  getKhoroo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(
            'http://192.168.88.39:8000/api/v1/bag_horoo/?sum=$districtId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      List res = jsonDecode(utf8.decode(response.bodyBytes));
      khorooList.clear();
      if (response.statusCode == 200) {
        setState(() {
          for (int i = 0; i < res.length; i++) {
            khorooList.add(Khoroo(
                id: res[i]['id'],
                ner: res[i]['ner'],
                sum: res[i]['sum'],
                aimag: res[i]['aimag']));
          }
        });
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  registerPharm() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/seller/reg_pharmacy/'),
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
            }
          },
        ),
      );
      if (response.statusCode == 200) {
        showSuccessMessage(message: 'Амжилттай бүртгэгдлээ.', context: context);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SellerHomePage()));
      } else {
        showFailedMessage(message: 'Бүртгэл амжилтгүй.', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
    }
  }

  Province? selectedProvince;
  District? selectedDistrict;
  Khoroo? selectedKhoroo;
  int provinceId = 0;
  int districtId = 0;
  int khorooId = 0;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('$provinceId, $districtId, $khorooId');
          },
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Эмийн сан бүртгэл'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.05, horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Wrap(
              direction: Axis.vertical,
              spacing: 20,
              children: [
                CustomTextField(
                  controller: cNameController,
                  hintText: 'Байгууллагын нэр',
                ),
                CustomTextField(
                  controller: cRdController,
                  hintText: 'Байгууллагын РД',
                ),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Имэйл хаяг',
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Утасны дугаар',
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: DropdownButtonFormField<Province>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    value: selectedProvince,
                    hint: const Text('Аймаг/Хот сонгох'),
                    onChanged: (Province? newValue) {
                      setState(() {
                        selectedProvince = newValue;
                        provinceId = newValue!.id;
                      });
                      getDistrictId();
                    },
                    items: provinceList
                        .map<DropdownMenuItem<Province>>((Province province) {
                      return DropdownMenuItem<Province>(
                        value: province,
                        child: Text(province.name),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: DropdownButtonFormField<District>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    value: selectedDistrict,
                    hint: const Text('Сум/Дүүрэг сонгох'),
                    onChanged: (District? newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                        districtId = newValue!.id;
                      });
                      getKhoroo();
                    },
                    items: districtList
                        .map<DropdownMenuItem<District>>((District district) {
                      return DropdownMenuItem<District>(
                        value: district,
                        child: Text(district.ner),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: DropdownButtonFormField<Khoroo>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    value: selectedKhoroo,
                    hint: const Text('Баг/Хороо сонгох'),
                    onChanged: (Khoroo? newValue) {
                      setState(() {
                        selectedKhoroo = newValue;
                        khorooId = newValue!.id;
                      });
                    },
                    items: khorooList
                        .map<DropdownMenuItem<Khoroo>>((Khoroo khoroo) {
                      return DropdownMenuItem<Khoroo>(
                        value: khoroo,
                        child: Text(khoroo.ner),
                      );
                    }).toList(),
                  ),
                ),
                CustomTextField(
                  controller: detailedController,
                  hintText: 'Тайлбар',
                ),
                CustomButton(
                  text: 'Бүртгэх',
                  ontap: () {
                    registerPharm();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
