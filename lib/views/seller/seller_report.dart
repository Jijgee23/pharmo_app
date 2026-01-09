import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/controller/providers/report_provider.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/seller/report_widget.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:provider/provider.dart';

class Reportfilter {
  String title;
  String query;
  Reportfilter({required this.title, required this.query});
}

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
    report.getReports(selectedFilter.query);
    super.initState();
  }

  List<String> titles = ['Огноо', 'Дүн', 'Тоо ширхэг'];

  List<Reportfilter> filters = [
    Reportfilter(title: 'Өдрөөр', query: 'day'),
    Reportfilter(title: 'Сараар', query: 'month'),
    Reportfilter(title: 'Улирлаар', query: 'quarter'),
    Reportfilter(title: 'Жилээр', query: 'year'),
  ];

  late Reportfilter selectedFilter = filters.first;

  Duration duration = const Duration(milliseconds: 500);

  List<Color> colors = [
    theme.primaryColor,
    theme.colorScheme.onError,
    theme.colorScheme.secondary
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(builder: (context, rp, child) {
      dynamic data = rp.report;
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Борлуулагчийн тайлан',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: black,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(Sizes.smallFontSize),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    dateSelector(
                        date: rp.currentDate,
                        handle: () => _showCalendar(report)),
                    dateSelector(
                        date: rp.currentDate2,
                        handle: () => _showCalendar2(report)),
                  ],
                ),
                Card(
                  elevation: 0,
                  color: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.smallFontSize),
                    side: BorderSide(color: Colors.grey, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButton<Reportfilter>(
                      value: selectedFilter,
                      underline: const SizedBox(),
                      hint: const Text('Филтер сонгох'),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: Sizes.mediumFontSize,
                        color: theme.primaryColor,
                      ),
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.black,
                      dropdownColor: white,
                      alignment: Alignment.center,
                      selectedItemBuilder: (context) => filters
                          .map((filter) => Row(
                                children: [
                                  Text(
                                    filter.title,
                                    style: const TextStyle(
                                      fontSize: Sizes.mediumFontSize,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                      items: filters
                          .map(
                            (filter) => DropdownMenuItem<Reportfilter>(
                              value: filter,
                              child: Text(filter.title),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(
                        () {
                          selectedFilter = val!;
                          rp.getReports(selectedFilter.query);
                        },
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        ...titles.map((t) =>
                            text(t: t, color: colors[titles.indexOf(t)])),
                      ],
                    ),
                    Builder(builder: (context) {
                      if (data != {}) {
                        return Column(
                          children: [
                            ...data.map((r) => ReportWidget(
                                date: maybeNull(
                                    r[selectedFilter.query].toString()),
                                total: maybeNull(r['total'].toString()),
                                count: maybeNull(r['count'].toString())))
                          ],
                        );
                      }
                      return NoResult();
                    })
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
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
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey, width: 2),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: handle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            const Icon(
              Icons.edit_calendar,
              color: Colors.black,
            ),
            const SizedBox(width: Sizes.smallFontSize),
            Text(
              getDate(date),
              style: const TextStyle(
                fontSize: Sizes.mediumFontSize,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
