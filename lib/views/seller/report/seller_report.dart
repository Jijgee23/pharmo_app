import 'package:pharmo_app/views/SELLER/report/report_widget.dart';
import 'package:pharmo_app/application/application.dart';

class Reportfilter {
  String title;
  String query;
  Reportfilter({
    required this.title,
    required this.query,
  });
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
          backgroundColor: Colors.grey.shade50, // Зөөлөн дэвсгэр өнгө
          appBar: SideAppBar(
            title: Text('Борлуулагчийн тайлан'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Огноо сонгох хэсэг
                Row(
                  children: [
                    _buildDateBox(
                        'Эхлэх', rp.currentDate, () => _showCalendar(report)),
                    const SizedBox(width: 12),
                    _buildDateBox('Дуусах', rp.currentDate2,
                        () => _showCalendar(report, isStart: false)),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Шүүлтүүр сонгох товч
                _buildFilterButton(rp),
                const SizedBox(height: 24),

                // 3. Хүснэгтийн толгой
                _buildTableHeader(),

                // 4. Дата жагсаалт
                Expanded(
                  child: data is List && data.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final r = data[idx];
                            return ReportWidget(
                              date: r[selectedFilter.query].toString(),
                              total: toPrice(r['total']), // toPrice ашиглав
                              count: '${r['count']} ш',
                            );
                          },
                        )
                      : const Center(child: NoResult()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateBox(String label, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: primary),
                  const SizedBox(width: 8),
                  Text(getDate(date),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(ReportProvider rp) {
    return InkWell(
      onTap: () => mySheet(
        isDismissible: true,
        children: filters
            .map((f) => SelectedFilter(
                  selected: f.title == selectedFilter.title,
                  caption: f.title,
                  onSelect: () {
                    setState(() => selectedFilter = f);
                    rp.getReports(selectedFilter.query);
                  },
                ))
            .toList(),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Тайлангийн төрөл: ${selectedFilter.title}',
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.tune_rounded,
              color: primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              'Огноо',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Дүн',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Тоо',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
    await report.getReports(selectedFilter.query);
  }
}
