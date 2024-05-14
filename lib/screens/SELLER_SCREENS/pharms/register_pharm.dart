// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/address.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/utilities/varlidator.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPharmPage extends StatefulWidget {
  const RegisterPharmPage({super.key});

  @override
  State<RegisterPharmPage> createState() => _RegisterPharmPageState();
}

class _RegisterPharmPageState extends State<RegisterPharmPage> {
  List<Province> provinceList = [];
  List<District> districtList = [];
  List<Khoroo> khorooList = [];
  List<String> names = [];
  Province? selectedProvince;
  District? selectedDistrict;
  Khoroo? selectedKhoroo;
  int provinceId = 0;
  int districtId = 0;
  int khorooId = 0;
  String latitude = '';
  String longtitude = '';
  double latF = 0;
  double lonF = 0;
  late TextEditingController cNameController,
      cRdController,
      emailController,
      phoneController,
      detailedController;

  @override
  void initState() {
    getLocationData();
    getProvinceId();
    cNameController = TextEditingController();
    cRdController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    detailedController = TextEditingController();
    super.initState();
  }

  getLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble('Lat');
    double? long = prefs.getDouble('Lon');
    setState(() {
      latitude = lat!.toStringAsFixed(6);
      longtitude = long!.toStringAsFixed(6);
      latF = double.parse(latitude);
      lonF = double.parse(longtitude);
    });
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Эмийн сан бүртгэл'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.05, horizontal: size.width * 0.05),
          child: SingleChildScrollView(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              spacing: 10,
              children: [
                const Text(
                  'Байгууллага',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                CustomTextField(
                  controller: cRdController,
                  hintText: 'Байгууллагын РД',
                  validator: validateCRD,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    checkCompany(cRdController.text);
                  },
                ),
                CustomTextField(
                  controller: cNameController,
                  hintText: 'Байгууллагын нэр',
                ),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Имэйл хаяг',
                  validator: validateEmail,
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Утасны дугаар',
                  validator: validatePhone,
                  keyboardType: TextInputType.number,
                ),
                const Text(
                  'Хаяг',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: DropdownButtonFormField<Province>(
                    decoration: InputDecoration(
                      label: const Text('Аймаг/Хот сонгох'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    value: selectedProvince,
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
                        child: Text(
                          province.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                        provinceId = 0;
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
                  width: MediaQuery.of(context).size.width * 0.9,
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
                        provinceId = newValue!.aimag;
                        districtId = newValue.sum;
                        khorooId = newValue.id;
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
                const Text(
                  'Тайлбар',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: TextFormField(
                    minLines: 1,
                    controller: detailedController,
                    decoration: const InputDecoration(
                      labelText: 'Тайлбар',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                CustomButton(
                  text: 'Бүртгэх',
                  ontap: () {
                    if (cNameController.text.isEmpty) {
                      showFailedMessage(
                          message: 'Байгууллагын нэрээ оруулна уу.',
                          context: context);
                    }
                    if (cRdController.text.isEmpty) {
                      showFailedMessage(
                          message: 'Байгууллагын рд оруулна уу.',
                          context: context);
                    }
                    if (emailController.text.isEmpty) {
                      showFailedMessage(
                          message: 'Имейл хаяг оруулна уу.', context: context);
                    }
                    if (phoneController.text.isEmpty) {
                      showFailedMessage(
                          message: 'Утасны дугаар оруулна уу.',
                          context: context);
                    }
                    if (provinceId == 0) {
                      showFailedMessage(
                          message: 'Аймаг/Хот сонгоно уу.', context: context);
                    }
                    if (districtId == 0) {
                      showFailedMessage(
                          message: 'Сум/Дүүрэг сонгоно уу.', context: context);
                    }
                    if (provinceId == 0) {
                      showFailedMessage(
                          message: 'Баг/Хороо сонгоно уу.', context: context);
                    }
                    if (detailedController.text.isEmpty) {
                      showFailedMessage(
                          message: 'Тайлбар оруулна уу.', context: context);
                    }
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

  getProvinceId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}aimag_hot/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      List res = jsonDecode(utf8.decode(response.bodyBytes));
      provinceList.clear();
      if (response.statusCode == 200) {
        setState(() {
          for (int i = 0; i < res.length; i++) {
            provinceList.add(Province(id: res[i]['id'], name: res[i]['ner']));
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
        Uri.parse('${dotenv.env['SERVER_URL']}sum_duureg/?aimag=$provinceId'),
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
        Uri.parse('${dotenv.env['SERVER_URL']}bag_horoo/?sum=$districtId'),
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
            'lat': latF,
            'lon': lonF,
          },
        ),
      );
      if (response.statusCode == 200) {
        String cName = jsonDecode(utf8.decode(response.bodyBytes))['cName'];
        prefs.setInt(
            'pharmId', jsonDecode(utf8.decode(response.bodyBytes))['user']);
        prefs.setString('selectedPharmName', cName);
        showSuccessMessage(message: 'Амжилттай бүртгэгдлээ.', context: context);
        goto(const SellerHomePage(), context);
      } else {
        showFailedMessage(message: 'Бүртгэл амжилтгүй.', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Алдаа гарлаа.', context: context);
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
      showFailedMessage(
          context: context, message: 'Интернет холболтоо шалгана уу!');
    }
  }
}
