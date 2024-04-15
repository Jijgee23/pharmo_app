import 'package:flutter/material.dart';

class PartnerDetail extends StatefulWidget {
  final String name;
  final String rd;
  final String email;
  final String phone;
  final bool isbad;
  final int basCount;
  final double debt;
  final double debtLimit;
  const PartnerDetail(
      {super.key,
      required this.name,
      required this.rd,
      required this.email,
      required this.phone,
      required this.isbad,
      required this.basCount,
      required this.debt,
      required this.debtLimit});

  @override
  State<PartnerDetail> createState() => _PartnerDetailState();
}

class _PartnerDetailState extends State<PartnerDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Харилцагчийн дэлгэрэнгүй\n мэдээлэл'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Харилцагчийн нэр: ${widget.name}'),
                    Text('Харилцагчийн дугаар: ${widget.rd}'),
                    Text('Харилцагчийн имейл: ${widget.email}'),
                    Text('Харилцагчийн утас: ${widget.phone}'),
                    Text(
                        'Найдвартай харилцагч эсэх: ${widget.isbad ? "Тийм" : "Үгүй"}'),
                    Text(
                        'Найдвахгүй харилцагчаар тэмдэглэгсэн тоо: ${widget.basCount}'),
                    Text('Зээлийн үлдэгдэл: ${widget.debt}'),
                    Text('Зээлийн хязгаар: ${widget.debtLimit}'),
                  ],
                ),
              ),
              const Expanded(
                child: Text(''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
