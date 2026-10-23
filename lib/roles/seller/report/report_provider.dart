import 'package:pharmo_app/application/application.dart';

/// How GET seller/report/ buckets the totals. [key] is both the `by` value
/// sent and the field each row is labelled by.
enum ReportGrouping {
  day('day', 'Өдрөөр', 'Өдөр'),
  month('month', 'Сараар', 'Сар'),
  quarter('quarter', 'Улирлаар', 'Улирал'),
  year('year', 'Жилээр', 'Жил');

  final String key, label, column;

  const ReportGrouping(this.key, this.label, this.column);
}

/// One bucket of the report: its period, the sales total and the number of
/// orders.
class ReportRow {
  final String period;
  final double total;
  final int count;

  const ReportRow(this.period, this.total, this.count);

  factory ReportRow.fromJson(Map<String, dynamic> json, ReportGrouping by) => ReportRow(
        json[by.key]?.toString() ?? '',
        parseDouble(json['total']),
        parseInt(json['count']),
      );
}

class ReportProvider extends ChangeNotifier {
  /// The processes seller/report/ filters by, in the order the API wants
  /// them sent so the same selection always makes the same request.
  static const processes = [
    OrderProcess.newOrder,
    OrderProcess.packing,
    OrderProcess.packed,
    OrderProcess.onDelivery,
    OrderProcess.delivered,
    OrderProcess.accepted,
    OrderProcess.closed,
    OrderProcess.returned,
  ];

  static DateTime get _thisMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// First and last month of the range, both inclusive; the API reads only
  /// their year and month.
  DateTime start = DateTime(_thisMonth.year, _thisMonth.month - 1);
  DateTime end = _thisMonth;
  ReportGrouping grouping = ReportGrouping.day;

  /// Empty means every process.
  Set<OrderProcess> selectedProcesses = {};

  List<ReportRow> rows = [];
  bool loading = false;

  // Bumped by every fetch, so an older answer arriving late is dropped.
  int _request = 0;

  double get total => rows.fold(0, (sum, r) => sum + r.total);
  int get count => rows.fold(0, (sum, r) => sum + r.count);

  void reset() {
    _request++;
    start = DateTime(_thisMonth.year, _thisMonth.month - 1);
    end = _thisMonth;
    grouping = ReportGrouping.day;
    selectedProcesses = {};
    rows = [];
    loading = false;
    notifyListeners();
  }

  String get _endpoint {
    final process = processes.where(selectedProcesses.contains).map((p) => p.code).join(',');
    return 'seller/report/?year=${start.year}&month=${start.month}'
        '&year2=${end.year}&month2=${end.month}&by=${grouping.key}'
        '${process.isEmpty ? '' : '&process=$process'}';
  }

  Future<void> getReports() async {
    final request = ++_request;
    final by = grouping;
    loading = true;
    notifyListeners();
    try {
      final r = await api(Api.get, _endpoint);
      if (request != _request || r == null) return;
      if (r.statusCode == 200) {
        rows = [for (final row in convertData(r) as List) ReportRow.fromJson(row, by)];
      } else {
        rows = [];
        messageWarning(apiErrorMessage(apiBody(r)) ?? wait);
      }
    } catch (e) {
      debugPrint(e.toString());
      if (request == _request) messageError(wait);
    } finally {
      if (request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  /// Sets the first ([isStart]) or last month of the range, moving the other
  /// end along when it would otherwise be crossed, and refetches.
  Future<void> setMonth(DateTime month, {required bool isStart}) async {
    month = DateTime(month.year, month.month);
    if (month.isAfter(_thisMonth)) {
      messageWarning('Ирээдүйн сар сонгох боломжгүй');
      return;
    }
    if (isStart) {
      start = month;
      if (end.isBefore(month)) end = month;
    } else {
      end = month;
      if (start.isAfter(month)) start = month;
    }
    await getReports();
  }

  Future<void> setGrouping(ReportGrouping value) async {
    if (value == grouping) return;
    grouping = value;
    await getReports();
  }

  /// Adds or removes [process]; picking every one is the same as none.
  Future<void> toggleProcess(OrderProcess process) async {
    final next = {...selectedProcesses};
    if (!next.remove(process)) next.add(process);
    selectedProcesses = next.length == processes.length ? {} : next;
    await getReports();
  }

  Future<void> clearProcesses() async {
    if (selectedProcesses.isEmpty) return;
    selectedProcesses = {};
    await getReports();
  }
}
