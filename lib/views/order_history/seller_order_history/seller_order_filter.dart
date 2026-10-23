import 'package:flutter/material.dart';
import 'package:pharmo_app/application/enum/enums.dart';

/// What the search box matches.
enum SellerOrderSearch {
  customer('Харилцагчийн нэрээр', 'customer__name__icontains', TextInputType.text),
  orderNo('Захиалгын дугаараар', 'orderNo', TextInputType.number);

  final String label, param;
  final TextInputType keyboard;

  const SellerOrderSearch(this.label, this.param, this.keyboard);
}

/// The filters GET seller/order/ takes. Status, process and payment type go
/// out as the Order model's letter codes (OrderStatus.value,
/// OrderProcess.code, PayType.value).
class SellerOrderFilter {
  final SellerOrderSearch searchBy;
  final String search;

  /// Whole days; `start` is sent as the first day's 00:00:00 and `end` as the
  /// last day's 23:59:59.
  final DateTimeRange? dates;
  final OrderStatus? status;
  final OrderProcess? process;
  final PayType? payType;

  /// true: paid through QPay; false: everything else.
  final bool? qpay;

  /// Inclusive bounds on the order total (₮) and on its item count.
  final int? minTotal, maxTotal, minCount, maxCount;

  const SellerOrderFilter({
    this.searchBy = SellerOrderSearch.customer,
    this.search = '',
    this.dates,
    this.status,
    this.process,
    this.payType,
    this.qpay,
    this.minTotal,
    this.maxTotal,
    this.minCount,
    this.maxCount,
  });

  static const _keep = Object();

  /// Pass `null` to clear a field; leave it out to keep it.
  SellerOrderFilter copyWith({
    SellerOrderSearch? searchBy,
    String? search,
    Object? dates = _keep,
    Object? status = _keep,
    Object? process = _keep,
    Object? payType = _keep,
    Object? qpay = _keep,
    Object? minTotal = _keep,
    Object? maxTotal = _keep,
    Object? minCount = _keep,
    Object? maxCount = _keep,
  }) {
    T? pick<T>(Object? v, T? current) => identical(v, _keep) ? current : v as T?;
    return SellerOrderFilter(
      searchBy: searchBy ?? this.searchBy,
      search: search ?? this.search,
      dates: pick(dates, this.dates),
      status: pick(status, this.status),
      process: pick(process, this.process),
      payType: pick(payType, this.payType),
      qpay: pick(qpay, this.qpay),
      minTotal: pick(minTotal, this.minTotal),
      maxTotal: pick(maxTotal, this.maxTotal),
      minCount: pick(minCount, this.minCount),
      maxCount: pick(maxCount, this.maxCount),
    );
  }

  /// Everything but the search box cleared.
  SellerOrderFilter cleared() => SellerOrderFilter(searchBy: searchBy, search: search);

  /// How many filters beyond the search box are set (a range counts once).
  int get activeCount =>
      [dates, status, process, payType, qpay].where((f) => f != null).length +
      (minTotal != null || maxTotal != null ? 1 : 0) +
      (minCount != null || maxCount != null ? 1 : 0);

  /// Query parameters for GET seller/order/.
  Map<String, String> toQuery() {
    final query = <String, String>{};
    final text = search.trim();
    if (text.isNotEmpty) query[searchBy.param] = text;
    final range = dates;
    if (range != null) {
      query['start'] = '${_day(range.start)}T00:00:00';
      query['end'] = '${_day(range.end)}T23:59:59';
    }
    if (status != null) query['status'] = status!.value;
    if (process != null) query['process'] = process!.code;
    if (payType != null) query['payType'] = payType!.value;
    if (qpay != null) query['qp'] = '$qpay';
    // The API only has strict bounds (__gt / __lt); totals and counts are
    // whole numbers, so widening by one keeps the typed values included.
    if (minTotal != null) query['totalPrice__gt'] = '${minTotal! - 1}';
    if (maxTotal != null) query['totalPrice__lt'] = '${maxTotal! + 1}';
    if (minCount != null) query['totalCount__gt'] = '${minCount! - 1}';
    if (maxCount != null) query['totalCount__lt'] = '${maxCount! + 1}';
    return query;
  }

  /// "2026.10.01 – 2026.10.21", or a single date for a one-day range.
  String? get datesLabel {
    final range = dates;
    if (range == null) return null;
    final start = _day(range.start).replaceAll('-', '.');
    final end = _day(range.end).replaceAll('-', '.');
    return start == end ? start : '$start – $end';
  }

  static String _day(DateTime d) =>
      '${d.year}-${'${d.month}'.padLeft(2, '0')}-${'${d.day}'.padLeft(2, '0')}';
}
