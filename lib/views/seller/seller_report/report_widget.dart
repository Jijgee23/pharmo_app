import 'package:flutter/material.dart';
import 'package:pharmo_app/models/seller_report.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class ReportWidget extends StatefulWidget {
  final SellerReport report;
  final int index;
  const ReportWidget({super.key, required this.report, required this.index});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    List<dynamic> data = [
      report.day,
      report.total.toString(),
      report.count.toString()
    ];
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: Sizes.smallFontSize,
                  horizontal: Sizes.smallFontSize),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              width: Sizes.bigFontSize * 2.5,
              child: Center(child: SmallText((widget.index + 1).toString()))),
          ...data.map((d) => text(d))
        ],
      ),
    );
  }

  Widget text(String t) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.smallFontSize,
      ),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      width: Sizes.width / 3 - (Sizes.mediulFontSize * 2.5),
      child: Center(child: SmallText(t)),
    );
  }
}
