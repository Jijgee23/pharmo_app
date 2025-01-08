class SellerReport {
  String? day;
  double? total;
  int? count;
  SellerReport({
    this.day,
    this.total,
    this.count,
  });
  factory SellerReport.fromJson(Map<String, dynamic> json) {
    return SellerReport(
      day: json['day'] as String?,
      total: (json['total'] ?? 0).toDouble(),
      count: (json['count'] ?? 0) as int,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'total': total ?? 0,
      'count': count ?? 0,
    };
  }
}
