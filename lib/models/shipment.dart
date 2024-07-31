class Shipment {
  int id;
  String? startTime;
  String? endTime;
  double? lon;
  double? lat;
  int? ordersCnt;
  int? progress;
  String? createdOn;
  int? supplier;
  int? delman;
  double? duration;
  double? expense;
  Shipment(
      this.id,
      this.startTime,
      this.endTime,
      this.lon,
      this.lat,
      this.ordersCnt,
      this.progress,
      this.createdOn,
      this.supplier,
      this.delman,
      this.duration,
      this.expense);
  Shipment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        lon = json['lon'],
        lat = json['lat'],
        ordersCnt = json['ordersCnt'],
        progress = json['progress'],
        createdOn = json['createdOn'],
        supplier = json['supplier'],
        delman = json['delman'],
        duration = json['duration'],
        expense = json['expense'];
}
