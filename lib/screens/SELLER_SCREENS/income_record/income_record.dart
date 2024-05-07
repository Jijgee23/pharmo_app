import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/custom_button.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IncomeRecord extends StatefulWidget {
  const IncomeRecord({super.key});

  @override
  State<IncomeRecord> createState() => _IncomeRecordState();
}

class _IncomeRecordState extends State<IncomeRecord> {
  TextEditingController amuontCntrllr = TextEditingController();
  TextEditingController noteCntrllr = TextEditingController();
  recordIncome() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
        Uri.parse('http://192.168.88.39:8000/api/v1/income_record/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'note': noteCntrllr.text,
          'amount': amuontCntrllr.text,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        showSuccessMessage(context: context, message: 'Амжилттай бүртгэгдлээ');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Орлого бүртгэх'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        color: Colors.amber,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              controller: noteCntrllr,
              hintText: 'Орлогын тайлбар',
            ),
            CustomTextField(
              controller: amuontCntrllr,
              hintText: 'Орлогын дүн',
              keyboardType: TextInputType.number,
            ),
            CustomButton(
                text: 'Бүртгэх',
                ontap: () {
                  recordIncome();
                }),
          ],
        ),
      ),
    );
  }
}
