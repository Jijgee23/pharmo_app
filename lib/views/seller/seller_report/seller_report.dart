import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/report_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/seller_report/report_widget.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
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
    report.getReports();
    super.initState();
  }

  // DateTime currentDate = DateTime.now();
  List<String> titles = ['Огноо', 'Дүн', 'Тоо ширхэг'];
  bool isNormalView = true;
  setIsNormalView(bool n) {
    setState(() {
      isNormalView = n;
    });
  }

  setTitle(String n) {
    setState(() {
      title = n;
    });
  }

  String title = 'Өдрөөр';

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      theme.primaryColor,
      theme.colorScheme.onPrimary,
      theme.colorScheme.secondary
    ];
    return Consumer<ReportProvider>(
      builder: (context, rp, child) => Scaffold(
        appBar: AppBar(
          title: Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary)),
          centerTitle: true,
          leading: ChevronBack(color: Theme.of(context).primaryColor),
        ),
        body: Container(
          padding: EdgeInsets.all(Sizes.smallFontSize),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Sizes.mediumFontSize),
            child: Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextButton(
                          text: rp.currentDate.toString().substring(0, 10),
                          onTap: () => _showCalendar(rp)),
                      CustomTextButton(
                          text: rp.currentDate2.toString().substring(0, 10),
                          onTap: () => _showCalendar2(rp)),
                      Button(text: 'Шүүх', onTap: () => filter(rp))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextButton(
                          text: 'Сараар', onTap: () => getByQuery(rp, 'month')),
                      CustomTextButton(
                          text: 'Улирлаар',
                          onTap: () => getByQuery(rp, 'quarter')),
                      CustomTextButton(
                          text: 'Жилээр', onTap: () => getByQuery(rp, 'year')),
                    ],
                  ),
                ),
                SizedBox(height: Sizes.bigFontSize),
                // if (isNormalView == true)
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: Sizes.smallFontSize,
                          horizontal: Sizes.smallFontSize),
                      width: Sizes.bigFontSize * 2.5,
                    ),
                    ...titles.map(
                        (t) => text(t: t, color: colors[titles.indexOf(t)]))
                  ]),
                if (rp.sellerReport.isNotEmpty && isNormalView)
                  ...rp.sellerReport.map((r) => ReportWidget(
                      report: r, index: rp.sellerReport.indexOf(r))),
                if (isNormalView == false)
                  Row(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: Sizes.smallFontSize,
                              horizontal: Sizes.smallFontSize),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          width: Sizes.bigFontSize * 2.5,
                          child: Center(child: SmallText((1).toString()))),
                      text2(rp.date),
                      text2(toPrice(rp.total.toString())),
                      text2(rp.count.toString()),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget text2(String t) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.smallFontSize,
      ),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      width: Sizes.width / 3 - (Sizes.mediumFontSize * 2.5),
      child: Center(child: SmallText(t)),
    );
  }

  filter(ReportProvider rp) async {
    setTitle('Өдрөөр');
    setIsNormalView(true);
    await rp.getReports();
  }

  getByQuery(ReportProvider rp, String q) async {
    if (rp.query == 'month') {
      setTitle('Сараар');
    } else if (rp.query == 'year') {
      setTitle('Жилээр');
    } else {
      setTitle('Улирлаар');
    }
    setIsNormalView(false);
    rp.setQuery(q);
    await rp.getReportsByQuery();
  }

  Widget text({required String t, Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.smallFontSize,
      ),
      decoration: BoxDecoration(color: color ?? Theme.of(context).primaryColor),
      width: Sizes.width / 3 - (Sizes.mediumFontSize * 2.5),
      child: Center(child: SmallText(t)),
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
      helpText: 'Огноо сонгоно уу?',
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
      helpText: 'Огноо сонгоно уу?',
    );

    if (pickedDate != null && pickedDate != report.currentDate2) {
      report.setCurrentDate2(pickedDate);
    }
  }
}
