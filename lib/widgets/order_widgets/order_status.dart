import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';

class OrderStatus extends StatelessWidget {
  final String process;
  const OrderStatus({super.key, required this.process});

  @override
  Widget build(BuildContext context) {
    List<String> processes = [
      'Шинэ',
      'Бэлтгэж эхэлсэн',
      'Бэлэн болсон',
      'Түгээлтэнд гарсан',
      'Хүргэгдсэн'
    ];
    return Column(
      children: [
         Text(
          'Захиалгын төлөв',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...processes.map(
              (p) => CustomStep(
                title: p,
                idx: processes.indexOf(p),
                process: process,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomStep extends StatelessWidget {
  final String title;
  final int idx;
  final String process;
  const CustomStep({
    super.key,
    required this.title,
    required this.idx,
    required this.process,
  });

  @override
  Widget build(BuildContext context) {
    bool reached =
        (getProcessNumber(process) == idx || getProcessNumber(process) >= idx);
    return AnimatedContainer(
      width: MediaQuery.of(context).size.width * .17,
      duration: const Duration(seconds: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            reached ? 'assets/icons/check.png' : 'assets/icons/circle.png',
            height: 25,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: reached ? AppColors.succesColor : AppColors.cleanBlack),
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
