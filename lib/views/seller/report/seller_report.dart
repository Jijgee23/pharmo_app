import 'package:pharmo_app/views/SELLER/report/report_widget.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/home/widgets/selected_filter.dart';

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
    return Consumer<ReportProvider>(
      builder: (context, rp, child) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    dateSelector(
                        date: rp.currentDate,
                        handle: () => _showCalendar(report)),
                    dateSelector(
                      date: rp.currentDate2,
                      handle: () => _showCalendar(
                        report,
                        isStart: false,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    mySheet(
                      isDismissible: true,
                      children: filters.map(
                        (filter) {
                          return SelectedFilter(
                            selected: filter.title == selectedFilter.title,
                            caption: filter.title,
                            onSelect: () {
                              selectedFilter = filter;
                              rp.getReports(selectedFilter.query);
                              setState(() {});
                            },
                          );
                        },
                      ).toList(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    side: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedFilter.title),
                      Icon(Icons.arrow_drop_down_rounded)
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (data != {}) {
                      return Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ...titles.map(
                                  (t) => text(
                                    t: t,
                                    color: colors[titles.indexOf(t)],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, idx) {
                                  final r = data[idx];
                                  return ReportWidget(
                                    date: maybeNull(
                                        r[selectedFilter.query].toString()),
                                    total: maybeNull(r['total'].toString()),
                                    count: maybeNull(r['count'].toString()),
                                  );
                                },
                                itemCount: (data as List).length,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return NoResult();
                  },
                )
              ],
            ),
          ),
        );
      },
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

  void _showCalendar(ReportProvider report, {bool isStart = true}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: report.currentDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      confirmText: 'Болсон',
      cancelText: 'Буцах',
      helpText: 'Эхлэх огноо сонгоно уу?',
    );
    if (pickedDate == null) return;
    report.setCurrentDate(pickedDate, isStart: isStart);
  }
}
