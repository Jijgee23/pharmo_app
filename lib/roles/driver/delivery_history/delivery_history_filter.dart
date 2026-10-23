import 'package:flutter/material.dart';

/// What the search box matches.
enum DeliverySearch {
  deliveryNo('Түгээлтийн дугаараар', 'Түгээлтийн дугаар', 'delivery_no'),
  orderNo('Захиалгын дугаараар', 'Захиалгын дугаар', 'order_no');

  /// [label] names the choice; [hint] is the short form the search box shows.
  final String label, hint, param;
  const DeliverySearch(this.label, this.hint, this.param);
}

/// How far a delivery got: every order handled, or some left over.
enum DeliveryProgress {
  complete('Бүрэн (100%)'),
  partial('Дутуу');

  final String label;
  const DeliveryProgress(this.label);
}

/// The filters GET delivery/history/ takes. A deliveryman (D/VS) only ever
/// gets his own deliveries, so there is no deliveryman filter here.
class DeliveryHistoryFilter {
  final DeliverySearch searchBy;
  final String search;

  /// Whole days, matched against when the delivery started.
  final DateTimeRange? dates;

  /// A zone the delivery covered: its id and name.
  final int? zoneId;
  final String? zoneName;
  final DeliveryProgress? progress;

  /// Newest first unless set.
  final bool oldestFirst;

  const DeliveryHistoryFilter({
    this.searchBy = DeliverySearch.deliveryNo,
    this.search = '',
    this.dates,
    this.zoneId,
    this.zoneName,
    this.progress,
    this.oldestFirst = false,
  });

  static const _keep = Object();

  /// Pass `null` to clear a field; leave it out to keep it.
  DeliveryHistoryFilter copyWith({
    DeliverySearch? searchBy,
    String? search,
    Object? dates = _keep,
    Object? zoneId = _keep,
    Object? zoneName = _keep,
    Object? progress = _keep,
    bool? oldestFirst,
  }) {
    T? pick<T>(Object? v, T? current) => identical(v, _keep) ? current : v as T?;
    return DeliveryHistoryFilter(
      searchBy: searchBy ?? this.searchBy,
      search: search ?? this.search,
      dates: pick(dates, this.dates),
      zoneId: pick(zoneId, this.zoneId),
      zoneName: pick(zoneName, this.zoneName),
      progress: pick(progress, this.progress),
      oldestFirst: oldestFirst ?? this.oldestFirst,
    );
  }

  /// Everything but the search box cleared.
  DeliveryHistoryFilter cleared() => DeliveryHistoryFilter(searchBy: searchBy, search: search);

  /// How many filters beyond the search box are set.
  int get activeCount =>
      [dates, zoneId, progress].where((f) => f != null).length + (oldestFirst ? 1 : 0);

  /// Query parameters for GET delivery/history/.
  Map<String, String> toQuery() {
    final query = <String, String>{
      'ordering': oldestFirst ? 'started_on' : '-started_on',
    };
    final text = search.trim();
    if (text.isNotEmpty) query[searchBy.param] = text;
    final range = dates;
    if (range != null) {
      query['started_on__gte'] = '${_day(range.start)}T00:00:00';
      query['started_on__lte'] = '${_day(range.end)}T23:59:59';
    }
    if (zoneId != null) query['zone'] = '$zoneId';
    switch (progress) {
      case DeliveryProgress.complete:
        query['progress__gte'] = '100';
      case DeliveryProgress.partial:
        query['progress__lte'] = '99';
      case null:
        break;
    }
    return query;
  }

  static String _day(DateTime d) =>
      '${d.year}-${'${d.month}'.padLeft(2, '0')}-${'${d.day}'.padLeft(2, '0')}';
}
