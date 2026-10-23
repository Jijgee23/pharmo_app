import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/report/month_picker.dart';
import 'package:pharmo_app/roles/seller/report/report_widget.dart';
import 'package:pharmo_app/widgets/filter/filter_widgets.dart';

/// «2026.10».
String _monthLabel(DateTime d) => '${d.year}.${'${d.month}'.padLeft(2, '0')}';

class SellerReportPage extends StatefulWidget {
  const SellerReportPage({super.key});

  @override
  State<SellerReportPage> createState() => _SellerReportState();
}

class _SellerReportState extends State<SellerReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ReportProvider>().getReports());
  }

  Future<void> _pickMonth(ReportProvider rp, {required bool isStart}) async {
    final picked = await showMonthPicker(
      title: isStart ? 'Эхлэх сар' : 'Дуусах сар',
      initial: isStart ? rp.start : rp.end,
      // seller/report/ takes no year before 2020.
      first: DateTime(2020),
      last: DateTime.now(),
    );
    if (picked != null) await rp.setMonth(picked, isStart: isStart);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, rp, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: SideAppBar(title: Text('Борлуулалтын тайлан')),
          body: RefreshIndicator(
            onRefresh: rp.getReports,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              children: [
                // 1. Хугацаа (сараар)
                Row(
                  children: [
                    MonthButton(
                      label: 'Эхлэх сар',
                      month: rp.start,
                      onTap: () => _pickMonth(rp, isStart: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: grey400),
                    ),
                    MonthButton(
                      label: 'Дуусах сар',
                      month: rp.end,
                      onTap: () => _pickMonth(rp, isStart: false),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16),
                const SizedBox(height: 16),

                // 2. Бүлэглэх
                _sectionTitle('Бүлэглэх'),
                _choices([
                  for (final g in ReportGrouping.values)
                    FilterChoice(g.label, rp.grouping == g, () => rp.setGrouping(g)),
                ]),
                const SizedBox(height: 12),

                // 3. Захиалгын явц
                _sectionTitle('Захиалгын явц'),
                _choices([
                  FilterChoice('Бүгд', rp.selectedProcesses.isEmpty, rp.clearProcesses),
                  for (final p in ReportProvider.processes)
                    FilterChoice(
                      p.name,
                      rp.selectedProcesses.contains(p),
                      () => rp.toggleProcess(p),
                      color: p.color,
                    ),
                ]),
                const SizedBox(height: 20),

                // 4. Нийт дүн
                ReportSummary(
                  total: rp.total,
                  count: rp.count,
                  period: _periodLabel(rp),
                ).paddingSymmetric(horizontal: 16),
                const SizedBox(height: 16),

                // 5. Хүснэгт
                _table(rp).paddingSymmetric(horizontal: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _periodLabel(ReportProvider rp) {
    final start = _monthLabel(rp.start);
    final end = _monthLabel(rp.end);
    return start == end ? start : '$start – $end';
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: grey600),
    ).paddingOnly(left: 16, right: 16, bottom: 8);
  }

  // One row of choices, scrolled sideways when it does not fit.
  Widget _choices(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(spacing: 8, children: children),
    );
  }

  Widget _table(ReportProvider rp) {
    if (rp.rows.isEmpty) {
      if (rp.loading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final filtered = rp.selectedProcesses.isNotEmpty;
      return EmptyState(
        compact: true,
        icon: Icons.bar_chart_rounded,
        title: 'Тайлангийн мэдээлэл алга',
        message: filtered
            ? 'Сонгосон хугацаа, явцад борлуулалт бүртгэгдээгүй байна.'
            : 'Сонгосон хугацаанд борлуулалт бүртгэгдээгүй байна.',
        actionLabel: filtered ? 'Бүх явцыг харах' : null,
        actionIcon: Icons.filter_alt_off_outlined,
        onAction: filtered ? rp.clearProcesses : null,
      );
    }
    final top = rp.rows.map((r) => r.total).reduce((a, b) => a > b ? a : b);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tableHeader(rp.grouping.column),
          // Kept on screen while a new selection loads, with a bar to say so.
          SizedBox(
            height: 2,
            child: rp.loading ? const LinearProgressIndicator() : null,
          ),
          for (final (i, r) in rp.rows.indexed) ...[
            if (i > 0) const Divider(height: 1),
            ReportWidget(
              date: r.period,
              total: toPrice(r.total),
              count: '${r.count}',
              share: top > 0 ? r.total / top : 0,
            ),
          ],
        ],
      ),
    );
  }

  Widget _tableHeader(String period) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey.shade800,
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(period, style: style)),
          const Expanded(flex: 3, child: Text('Дүн', textAlign: TextAlign.right, style: style)),
          const Expanded(
            flex: 1,
            child: Text('Захиалга', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// The range's sales total and order count, over the period it covers.
class ReportSummary extends StatelessWidget {
  final double total;
  final int count;
  final String period;

  const ReportSummary({
    super.key,
    required this.total,
    required this.count,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.primaryColor;
    final label = TextStyle(fontSize: 12, color: white.withValues(alpha: 0.8));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, tint.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16, color: white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(period, style: label),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text('Нийт борлуулалт', style: label),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        toPrice(total),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text('Захиалга', style: label),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final DateTime month;

  const MonthButton({
    super.key,
    this.onTap,
    required this.label,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _monthLabel(month),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
