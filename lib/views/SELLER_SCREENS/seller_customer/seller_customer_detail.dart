import 'package:flutter/material.dart';
import 'package:pharmo_app/models/customer.dart';

class PartnerDetail extends StatefulWidget {
  final Customer customer;
  const PartnerDetail({
    super.key,
    required this.customer,
  });

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
                    Text(
                        'Харилцагчийн нэр: ${widget.customer.customer.name}'),
                    Text(
                        'Харилцагчийн дугаар: ${widget.customer.customer.name}'),
                    Text(
                        'Харилцагчийн имейл: ${widget.customer.customer.email}'),
                    Text(
                        'Харилцагчийн утас: ${widget.customer.customer.phone}'),
                    Text(
                        'Найдвартай харилцагч эсэх: ${widget.customer.isBad ? "Тийм" : "Үгүй"}'),
                    Text(
                        'Найдвахгүй харилцагчаар тэмдэглэгсэн тоо: ${widget.customer.isBad}'),
                    Text('Зээлийн үлдэгдэл: ${widget.customer.debt}'),
                    Text('Зээлийн хязгаар: ${widget.customer.debtLimit}'),
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
