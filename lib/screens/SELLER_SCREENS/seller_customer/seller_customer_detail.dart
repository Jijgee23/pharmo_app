import 'package:flutter/material.dart';
import 'package:pharmo_app/models/partner.dart';

class PartnerDetail extends StatefulWidget {
  final Partner partner;
  const PartnerDetail({
    super.key,
    required this.partner,
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
                        'Харилцагчийн нэр: ${widget.partner.partnerDetails.name}'),
                    Text(
                        'Харилцагчийн дугаар: ${widget.partner.partnerDetails.name}'),
                    Text(
                        'Харилцагчийн имейл: ${widget.partner.partnerDetails.email}'),
                    Text(
                        'Харилцагчийн утас: ${widget.partner.partnerDetails.phone}'),
                    Text(
                        'Найдвартай харилцагч эсэх: ${widget.partner.isBad ? "Тийм" : "Үгүй"}'),
                    Text(
                        'Найдвахгүй харилцагчаар тэмдэглэгсэн тоо: ${widget.partner.isBad}'),
                    Text('Зээлийн үлдэгдэл: ${widget.partner.debt}'),
                    Text('Зээлийн хязгаар: ${widget.partner.debtLimit}'),
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
