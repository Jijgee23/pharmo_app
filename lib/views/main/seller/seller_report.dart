import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/report_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/seller/report_widget.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:provider/provider.dart';

class SellerReportPage extends StatefulWidget {
  const SellerReportPage({super.key});

  @override
  State<SellerReportPage> createState() => _SellerReportState();
}

class _SellerReportState extends State<SellerReportPage> {
  late ReportProvider report;
  @override
  initState() {
    report = Provider.of<ReportProvider>(context, listen: false);
    report.getReports(query);
    super.initState();
  }

  List<String> titles = ['Огноо', 'Дүн', 'Тоо ширхэг'];

  List<String> dateTypes = ['Өдрөөр', 'Сараар', 'Улирлаар', 'Жилээр'];

  String selectedType = 'Өдрөөр';
  String query = 'day';
  setType(String n, String q) {
    setState(() {
      selectedType = n;
      query = q;
    });
  }

  List<String> queries = ['day', 'month', 'quarter', 'year'];

  Duration duration = const Duration(milliseconds: 500);
  List<Color> colors = [
    theme.primaryColor,
    theme.colorScheme.onPrimary,
    theme.colorScheme.secondary
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(builder: (context, rp, child) {
      dynamic data = rp.report;
      return Scaffold(
        appBar: SideAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              dateSelector(date: rp.currentDate, handle: () => _showCalendar(report)),
              dateSelector(date: rp.currentDate2, handle: () => _showCalendar2(report)),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(Sizes.smallFontSize),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                typeSelector(rp),
                Column(
                  children: [
                    Row(children: [
                      ...titles.map((t) => text(t: t, color: colors[titles.indexOf(t)])),
                    ]),
                    if ((data != {}))
                      ...data.map((r) => ReportWidget(
                          date: maybeNull(r[query].toString()),
                          total: maybeNull(r['total'].toString()),
                          count: maybeNull(r['count'].toString())))
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget typeSelector(ReportProvider rp) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(bottom: Sizes.mediumFontSize),
      decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(Sizes.smallFontSize * 3),
          border: Border.all(color: Colors.black, width: 2)),
      duration: duration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...dateTypes.map((d) => typeWidget(d, queries[dateTypes.indexOf(d)], rp)),
        ],
      ),
    );
  }

  Widget typeWidget(String title, String que, ReportProvider rp) {
    bool selected = title == selectedType;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        setType(title, que);
        await rp.getReports(query);
      },
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(
            horizontal: Sizes.smallFontSize, vertical: Sizes.mediumFontSize),
        decoration: BoxDecoration(
            color: selected ? theme.colorScheme.onPrimary : theme.primaryColor,
            borderRadius: BorderRadius.circular(Sizes.smallFontSize * 3)),
        width: Sizes.width * (selected ? .25 : 0.2),
        duration: duration,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: Sizes.smallFontSize + 2),
        ),
      ),
    );
  }

  Widget text({required String t, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.smallFontSize,
      ),
      decoration: BoxDecoration(color: color ?? Theme.of(context).primaryColor),
      width: (Sizes.width - Sizes.smallFontSize * 2) / 3,
      child: Center(child: SmallText(t)),
    );
  }

  Widget dateSelector({required DateTime date, required Function() handle}) {
    return InkWell(
      onTap: handle,
      child: Row(
        children: [
          const Icon(
            Icons.edit_calendar,
            color: Colors.white,
          ),
          const SizedBox(width: Sizes.smallFontSize),
          Text(
            getDate(date),
            style: const TextStyle(fontSize: Sizes.mediumFontSize),
          ),
        ],
      ),
    );
  }

  void _showCalendar(ReportProvider report) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: report.currentDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      confirmText: 'Болсон',
      cancelText: 'Буцах',
      helpText: 'Эхлэх огноо сонгоно уу?',
    );

    if (pickedDate != null && pickedDate != report.currentDate) {
      report.setCurrentDate(pickedDate);
    }
  }

  void _showCalendar2(ReportProvider report) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: report.currentDate2,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      confirmText: 'Болсон',
      cancelText: 'Буцах',
      helpText: 'Дуусах огноо сонгоно уу?',
    );

    if (pickedDate != null && pickedDate != report.currentDate2) {
      report.setCurrentDate2(pickedDate);
    }
  }
}
