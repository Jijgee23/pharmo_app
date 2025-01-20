import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class ReportWidget extends StatelessWidget {
  final String date;
  final String total;
  final String count;
  const ReportWidget(
      {super.key,
      required this.date,
      required this.total,
      required this.count});

  @override
  Widget build(BuildContext context) {
    List<dynamic> data = [date, total, count];
    return Row(children: data.map((d) => text(d)).toList());
  }

  Widget text(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Sizes.smallFontSize),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      width: (Sizes.width - Sizes.smallFontSize * 2) / 3,
      child: Center(child: SmallText(t)),
    );
  }
}
