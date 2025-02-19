class Promotion {
  int? id;
  String? name;
  String? description;
  bool? isActive;
  bool? hasGift;
  String promoType;
  String? startDate;
  String? endDate;
  double? total;
  double? procent;
  Promotion(this.id, this.name, this.description, this.isActive, this.hasGift,
      this.promoType, this.startDate, this.endDate, this.total, this.procent);
  Promotion.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['desc'],
        isActive = json['is_active'],
        hasGift = json['has_gift'],
        promoType = json['promo_type'],
        startDate = json['start_date'],
        endDate = json['end_date'],
        total = json['total'],
        procent = json['procent'];
}
