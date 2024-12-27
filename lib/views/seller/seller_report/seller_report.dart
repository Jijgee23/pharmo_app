import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/screen_size.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';

class SellerReport extends StatefulWidget {
  const SellerReport({super.key});

  @override
  State<SellerReport> createState() => _SellerReportState();
}

class _SellerReportState extends State<SellerReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      title: const SmallText('Тайлан'),
      leading: ChevronBack(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  _body() {
    return Container(
      padding: EdgeInsets.all(ScreenSize.smallFontSize),
      child: Column(
        children: [
          ReportWidget(
            report: 'Demo',
          )
        ],
      ),
    );
  }
}

class ReportWidget extends StatefulWidget {
  final dynamic report;
  const ReportWidget({super.key, this.report});

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() {
        isExpanded = !isExpanded;
      }),
      child: AnimatedContainer(
        padding:
            EdgeInsets.all(ScreenSize.smallFontSize + (isExpanded ? 10 : 2)),
        duration: Durations.medium4,
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(ScreenSize.smallFontSize),
          gradient: const LinearGradient(
            colors: [
              Colors.purpleAccent,
              Colors.red,
            ],
          ),
        ),
        child: SmallText(widget.report.toString()),
      ),
    );
  }
}
