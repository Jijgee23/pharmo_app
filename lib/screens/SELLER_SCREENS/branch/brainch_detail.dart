import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BranchDetails extends StatefulWidget {
  int? id;
  String? name;
  String? phone;
  String? address;
  String? managerName;
  String? managerEmail;
  String? managerPhone;
  BranchDetails(
      {super.key,
      this.id,
      this.name,
      this.phone,
      this.address,
      this.managerName,
      this.managerEmail,
      this.managerPhone});

  @override
  State<BranchDetails> createState() => _BranchDetailsState();
}

class _BranchDetailsState extends State<BranchDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Салбарын дэлгэрэнгүй\n мэдээлэл'),
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
                    Text('Салбарын дугаар: ${widget.id}'),
                    Text('Салбарын нэр: ${widget.name}'),
                    Text('Салбарын утас: ${widget.phone}'),
                    Text('Салбарын хаяг: ${widget.address}'),
                    Text('Менежерийн нэр: ${widget.managerName.toString()}'),
                    Text('Менежерийн имейл: ${widget.managerEmail}'),
                    Text('Менежерийн утас: ${widget.managerPhone}'),
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
